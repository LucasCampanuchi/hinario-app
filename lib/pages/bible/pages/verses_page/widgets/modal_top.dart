import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/verses.store.dart';

void modalChapter(
  BuildContext context,
  VersesStore controller,
) {
  double paddingTop = MediaQuery.of(
    context,
  ).padding.top;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 100),

    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    //barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (ctx, _, __) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: paddingTop + 55,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(ctx).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      10,
                    ),
                    bottomRight: Radius.circular(
                      10,
                    ),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height / 2,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 1; i <= controller.chapters; i++)
                          InkWell(
                            onTap: () {
                              controller.setChapter(i);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width / 5,
                                minHeight: 40,
                              ),
                              child: Text(
                                '$i',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
