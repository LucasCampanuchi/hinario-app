import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/verse_font_size.store.dart';

void showModalFontSize(
  BuildContext context,
) {
  final VerseFontSizeStore _verseFontSizeStore =
      GetIt.I.get<VerseFontSizeStore>();

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext cxt) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tamanho da fonte',
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Observer(
                    builder: (_) => Slider(
                      value: _verseFontSizeStore.fontSize,
                      min: 14,
                      max: 24,
                      onChanged: _verseFontSizeStore.adjustFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
