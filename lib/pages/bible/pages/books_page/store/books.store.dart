import 'package:hinario_flutter/controllers/book.controller.dart';
import 'package:hinario_flutter/models/book.model.dart';
import 'package:mobx/mobx.dart';
part 'books.store.g.dart';

class BooksStore = _BooksStoreBase with _$BooksStore;

abstract class _BooksStoreBase with Store {
  final BookController _bookController = BookController();

  @observable
  List<BookModel>? listBooks = [];

  @observable
  List<BookModel>? listBooksReceived = [];

  @observable
  bool ordened = false;

  @action
  Future<void> list() async {
    listBooks = await _bookController.getAll();

    if (ordened) {
      order(listBooks!);
    }
  }

  @action
  void order(List<BookModel> list) {
    list.sort((a, b) => a.name!.compareTo(b.name!));
  }

  @action
  Future<void> setOrder(bool o) async {
    listBooks = await _bookController.getAll();

    if (o) {
      order(listBooks!);
    }

    ordened = !ordened;
  }
}
