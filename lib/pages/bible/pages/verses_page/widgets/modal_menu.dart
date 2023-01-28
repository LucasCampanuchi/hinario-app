import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/models/book.model.dart';

import '../store/verses.store.dart';

void modalMenu(
  BuildContext context,
  VersesStore controller,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.1),
    builder: (BuildContext cxt) {
      return Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Align(
          alignment: Alignment.topRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(
                    15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Pesquisa',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (controller.listHistoryBook.isNotEmpty) ...[
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Histórico',
                          style: GoogleFonts.roboto(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        for (var book in controller.listHistoryBook)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                controller.list(
                                  context,
                                  BookModel.fromJson(
                                    jsonDecode(book['book']),
                                  ),
                                  int.parse(
                                    book['chapter'],
                                  ),
                                  int.parse(
                                    book['verse'],
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '${BookModel.fromJson(jsonDecode(book['book'])).name} ${book['chapter']}:${book['verse']}',
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
