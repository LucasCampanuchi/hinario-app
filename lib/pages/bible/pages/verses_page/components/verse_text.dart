import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/bible/pages/verses_page/store/verse_font_size.store.dart';

import '../../../../../models/verse.model.dart';
import 'chapter_title.dart';

class VerseText extends StatefulWidget {
  final VerseModel verse;

  const VerseText({
    Key? key,
    required this.verse,
  }) : super(key: key);

  @override
  State<VerseText> createState() => _VerseTextState();
}

class _VerseTextState extends State<VerseText> {
  final VerseFontSizeStore _verseFontSizeStore =
      GetIt.I.get<VerseFontSizeStore>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Observer(
      builder: (_) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                if (widget.verse.verse == 1)
                  Row(
                    children: [
                      ChapterTitle(
                        text: (widget.verse.chapter).toString(),
                      ),
                    ],
                  ),
                Html(
                  data:
                      '<p><span>${widget.verse.verse! == 1 ? '' : widget.verse.verse} </span>${widget.verse.text!}</p>',
                  style: {
                    "p": Style(
                      fontFamily: 'Roboto',
                      fontSize: FontSize(
                        _verseFontSizeStore.fontSize,
                      ),
                      color: Colors.black54,
                    ),
                    "span": Style(
                      fontFamily: 'Roboto',
                      fontSize: FontSize(
                        _verseFontSizeStore.fontSize,
                      ),
                      color: const Color.fromRGBO(173, 173, 173, 1),
                      margin: const EdgeInsets.only(left: 8),
                    ),
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black12,
            height: 0.4,
            width: size.width * 0.95,
          )
        ],
      ),
    );
  }
}
