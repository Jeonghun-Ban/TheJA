import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:theja/models/models.dart';

final String collectionTable = 'collection';
final String collectionColumnId = 'id';
final String collectionColumnName = 'name';

final String vehicleTable = 'vehicle';
final String vehicleColumnId = 'id';
final String vehicleColumnName = 'name';
final String vehicleColumnStation = 'station';
final String vehicleColumnStationId = 'station_id';
final String vehicleColumnType = 'type';

final String relationTable = 'relation';

class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    var dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'sqlite.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $collectionTable(
        $collectionColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $collectionColumnName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $vehicleTable(
        $vehicleColumnId INTEGER PRIMARY KEY,
        $vehicleColumnName TEXT,
        $vehicleColumnStation TEXT,
        $vehicleColumnStationId INTEGER,
        $vehicleColumnType INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $relationTable(
        collection_id INTEGER,
        vehicle_id INTEGER,
        FOREIGN KEY(collection_id) REFERENCES $collectionTable(id),
        FOREIGN KEY(vehicle_id) REFERENCES $vehicleTable(id)
      )
    ''');
  }

  Future<Collection> insertCollection(Collection collection) async {
    var db = await database;

    collection.id = await db.insert(collectionTable, collection.toMap());
    return collection;
  }

  Future<List<Collection>> getCollections() async {
    var db = await database;

    var collections = await db.query(collectionTable,
        columns: [collectionColumnId, collectionColumnName]);

    List<Collection> collectionList = List<Collection>();
    collections.forEach((element) {
      Collection collection = Collection.fromMap(element);
      collectionList.add(collection);
    });

    return collectionList;
  }

  Future<int> deleteCollection(int id) async {
    var db = await database;

    return await db.delete(
      collectionTable,
      where: '$collectionColumnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCollection(Collection collection) async {
    var db = await database;

    return await db.update(
      collectionTable,
      collection.toMap(),
      where: '$collectionColumnId = ?',
      whereArgs: [collection.id],
    );
  }

  Future<int> insertVehicle(Vehicle vehicle, int collectionId) async {
    var db = await database;

    int vehicleId = vehicle.id;
    String vehicleKeyString = vehicle.toMap().keys.toString();
    List<dynamic> vehicleValueList = vehicle.toMap().values.toList();

    await db.rawInsert('''
      INSERT INTO $vehicleTable $vehicleKeyString
      SELECT ?, ?, ?, ?, ? WHERE NOT EXISTS(
        SELECT 1 FROM $vehicleTable WHERE $vehicleColumnId == $vehicleId
      );
    ''', vehicleValueList);

    int isVehicleExist = await db.rawInsert('''
      INSERT INTO $relationTable (collection_id, vehicle_id)
      SELECT $collectionId, $vehicleId WHERE NOT EXISTS(
        SELECT 1 FROM $relationTable 
        WHERE collection_id == $collectionId AND vehicle_id == $vehicleId
      );
    ''');

    return isVehicleExist;
  }

  Future<List<Vehicle>> getVehicles(int collectionId) async {
    var db = await database;

    var vehicles = await db.rawQuery('''
      SELECT * FROM $vehicleTable JOIN $relationTable
      ON $vehicleTable.id == $relationTable.vehicle_id
      WHERE $relationTable.collection_id == $collectionId;
    ''');

    List<Vehicle> vehicleList = List<Vehicle>();
    vehicles.forEach((element) {
      Vehicle vehicle = Vehicle.fromMap(element);
      vehicleList.add(vehicle);
    });

    return vehicleList;
  }

  Future<int> deleteVehicle(int collectionId, int vehicleId) async {
    var db = await database;

    return await db.delete(
      relationTable,
      where: 'collection_id = ? AND vehicle_id = ?',
      whereArgs: [collectionId, vehicleId],
    );
  }
}
