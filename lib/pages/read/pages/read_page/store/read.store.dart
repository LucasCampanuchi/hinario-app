import 'dart:io';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hinario_flutter/controllers/shared_preferences.controller.dart';
import 'package:mobx/mobx.dart';

import '../../../../../utils/file_from_address.dart';
import '../../../../../utils/message.dart';
part 'read.store.g.dart';

class ReadStore = _ReadStoreBase with _$ReadStore;

abstract class _ReadStoreBase with Store {
  final SharedPreferencesController _sharedPreferencesController =
      SharedPreferencesController();

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
  void setPage(
    int page,
    String nameFile,
  ) {
    currentPage = page;

    pdfViewController?.setPage(page);
  }

  @action
  void savePage(int p, String nameFile) {
    _sharedPreferencesController.insertData(
      nameFile.replaceAll('.pdf', ''),
      p.toString(),
    );
  }

  @action
  Future<void> setFile(
    String u,
    String name,
  ) async {
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

  @action
  Future<void> jumpLastPage(String nameFile) async {
    final page = await _sharedPreferencesController.readData(
      nameFile.replaceAll('.pdf', ''),
    );

    if (page != null) {
      setPage(int.parse(page), nameFile);
    }
  }
}
