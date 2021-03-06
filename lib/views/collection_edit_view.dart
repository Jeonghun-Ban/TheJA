import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theja/blocs/collection/collection.dart';
import 'package:theja/items/items.dart';
import 'package:theja/models/models.dart';
import 'package:theja/utils/collection_db_helper.dart';

class CollectionEditView extends StatefulWidget {
  _CollectionEditView createState() => _CollectionEditView();
}

class _CollectionEditView extends State<CollectionEditView> {
  @override
  void initState() {
    super.initState();
    CollectionDBHelper.db.get().then(
          (collectionList) => BlocProvider.of<CollectionBloc>(context).add(
            GetCollections(collectionList),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionBloc, List<Collection>>(
      builder: (context, collectionList) {
        return ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            setState(
              () {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Collection item = collectionList.removeAt(oldIndex);
                collectionList.insert(newIndex, item);
              },
            );
          },
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: List.generate(
            collectionList.length,
            (index) {
              return CollectionCard(
                collectionList,
                index,
                Key('$index'),
              );
            },
          ),
        );
      },
    );
  }
}
