import 'dart:io';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobx/mobx.dart';

import '../../../../../utils/file_from_address.dart';
import '../../../../../utils/message.dart';
part 'read.store.g.dart';

class ReadStore = _ReadStoreBase with _$ReadStore;

abstract class _ReadStoreBase with Store {
  @observable
  File? file;

  @observable
  bool isLoading = false;

  @observable
  bool isError = false;

  @observable
  int pages = 0;

  @observable
  int currentPage = 0;

  @observable
  PDFViewController? pdfViewController;

  @action
  void setPdfViewController(PDFViewController controller) {
    pdfViewController = controller;
  }

  @action
  void setPage(int page) {
    currentPage = page;
    pdfViewController?.setPage(page);
  }

  @action
  Future<void> setFile(String u) async {
    isLoading = true;
    isError = false;

    try {
      file = await createFileOfPdfUrl(u);
    } catch (e) {
      message('Erro ao carregar pdf');
      isError = true;
    }

    isLoading = false;
  }
}
