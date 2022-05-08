import 'package:hinario_flutter/controllers/book.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:mobx/mobx.dart';
part 'chapter.store.g.dart';

class ChapterStore = _ChapterStoreBase with _$ChapterStore;

abstract class _ChapterStoreBase with Store {
  final BookController _bookController = BookController();

  @observable
  int? qtdeChapters = 0;

  @action
  Future<void> list(BookModel book) async {
    qtdeChapters = await _bookController.getCountChapterByBook(book.id!);
  }
}
