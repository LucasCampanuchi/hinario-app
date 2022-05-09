import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/controllers/verse.controller.dart';
import 'package:mobx/mobx.dart';

import '../../../../../models/book.model.dart';
import '../../verses_page/store/verses.store.dart';

part 'search_bible.store.g.dart';

class SearchBibleStore = _SearchBibleStoreBase with _$SearchBibleStore;

abstract class _SearchBibleStoreBase with Store {
  final VerseController _verseController = VerseController();

  TextEditingController text = TextEditingController();

  @observable
  List<dynamic>? listVerses = [];

  void setSearch(
    SearchBibleStore controller,
    BuildContext context,
  ) {
    controller.search(context);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @action
  Future<void> search(BuildContext context) async {
    listVerses = await _verseController.listVerseByText(text.text);
  }

  @action
  Future<void> setVerse(
    BuildContext context,
    dynamic verse,
  ) async {
    VersesStore versesStore = GetIt.I.get<VersesStore>();
    await versesStore.list(
      context,
      BookModel(
        id: verse['id'],
        testamentReferenceId: verse['testamentReferenceId'],
        bookReferenceId: verse['bookReferenceId'],
        name: verse['name'],
      ),
      verse['chapter'],
      verse['verse'],
    );

    await Future.delayed(const Duration(milliseconds: 100));

    Navigator.of(context).pop();
  }
}
