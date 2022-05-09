import 'package:flutter/material.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:mobx/mobx.dart';
part 'home.store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  @action
  Future<void> setRoute(
    BuildContext context,
    String route,
  ) async {
    if (route == '/verses') {
      Navigator.pushNamed(
        context,
        route,
        arguments: {
          'book': BookModel(
            id: 1,
            bookReferenceId: 1,
            testamentReferenceId: 1,
            name: 'Gênesis',
          ),
          'chapter': 1,
        },
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
