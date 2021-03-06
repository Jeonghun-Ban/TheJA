import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'package:theja/models/models.dart';
import 'package:theja/auth/keys.dart';
import 'package:theja/strings.dart';

class BusInfoParser {
  final SecretLoader secretLoader;
  BusInfoParser._({this.secretLoader = const SecretLoader()});
  static final BusInfoParser bus = BusInfoParser._();

  Future<List<Vehicle>> searchStation(String keyword) async {
    final apiKey = await _apiKey();
    String xmlString = await fetchDocument(Strings.searchStationUri +
        "?serviceKey=" +
        apiKey +
        "&keyword=" +
        keyword);
    var raw = xml.parse(xmlString);
    var elements = raw.findAllElements("busStationList");

    List<Vehicle> busList = List<Vehicle>();
    elements.forEach((element) {
      Vehicle bus = new Bus(
        stationId: int.parse(element.findElements("stationId").first.text),
        stationName: element.findElements("stationName").first.text,
      );
      busList.add(bus);
    });
    return busList;
  }

  Future<List<Vehicle>> searchVehicle(String stationId) async {
    final apiKey = await _apiKey();
    String xmlString = await fetchDocument(Strings.searchRouteUri +
        "?serviceKey=" +
        apiKey +
        "&stId=" +
        stationId +
        "&");
    var raw = xml.parse(xmlString);
    var elements = raw.findAllElements("itemList");

    List<Vehicle> busList = List<Vehicle>();
    elements.forEach((element) {
      Vehicle bus = new Bus(
        routeId: int.parse(element.findElements("busRouteId").first.text),
        routeName: element.findElements("rtNm").first.text,
        stationId: int.parse(element.findElements("stId").first.text),
        stationName: element.findElements("stNm").first.text,
      );
      busList.add(bus);
    });
    return busList;
  }

  Future<Map<int, String>> getArr(String stationId, String routeId) async {
    final apiKey = await _apiKey();
    String xmlString = await fetchDocument(Strings.searchRouteUri +
        "?serviceKey=" +
        apiKey +
        "&stId=" +
        stationId +
        "&");
    var raw = xml.parse(xmlString);
    var elements = raw.findAllElements("itemList");

    Map<int, String> arr = Map<int, String>();
    for (var element in elements) {
      if (element.findElements("busRouteId").first.text == routeId) {
        arr[0] = (element.findElements("arrmsg1").first.text);
        arr[1] = (element.findElements("arrmsg2").first.text);
        break;
      }
    }
    return arr;
  }

  Future<String> fetchDocument(String uri) async {
    http.Response response = await http.get(uri);
    return response.body;
  }

  Future<String> _apiKey() async {
    try {
      final secret = await secretLoader.load();
      return secret.thejaApiKey;
    } catch (exception) {
      print(exception);
      return "";
    }
  }
}
