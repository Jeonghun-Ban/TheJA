import 'package:flutter/material.dart';
import 'package:theja/data.dart';
import 'package:theja/models/models.dart';
import 'package:theja/widgets/widgets.dart';

class CollectionView extends StatefulWidget {
  _CollectionView createState() => _CollectionView();
}

class _CollectionView extends State<CollectionView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
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
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final Collection item = collectionList.removeAt(oldIndex);
        collectionList.insert(newIndex, item);
      },
    );
  }
}
