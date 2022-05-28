import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/controllers/hymn.controller.dart';
import 'package:mobx/mobx.dart';

import '../../../../../models/hymn.model.dart';

part 'keyboard.store.g.dart';

class KeyBoardStore = _KeyBoardStore with _$KeyBoardStore;

abstract class _KeyBoardStore with Store {
  @observable
  String num = '';

  @action
  void typeText(String text) {
    if (num == '') {
      num += text;
    } else {
      if (num.substring(0, 1) != 'C-' && num.substring(0, 1) != 'S-') {
        if (text != "C-" && text != "S-") {
          num += text;
        }
      } else if (num.contains("C-")) {
        if (text != "S-") {
          num += text;
        }
      } else if (num.contains("S-")) {
        if (text != "C-") {
          num += text;
        }
      }
    }
  }

  @action
  void clean() {
    num = '';
  }

  @action
  Future<void> set(BuildContext context) async {
    HymnController hymnController = HymnController();

    HymnModel? hymn = await hymnController.getHymnByNumber(num);
    if (hymn != null) {
      Navigator.pushNamed(
        context,
        '/hymnview',
        arguments: {
          'hymn': hymn,
        },
      );
    } else {
      SnackBar snackBar = SnackBar(
        elevation: 3.0,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Hino não encontrado',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    clean();
  }
}
