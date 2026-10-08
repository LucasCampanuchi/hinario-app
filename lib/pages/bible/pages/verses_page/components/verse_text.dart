import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/bible/pages/verses_page/store/verse_font_size.store.dart';

import '../../../../../models/verse.model.dart';
import 'chapter_title.dart';

class VerseText extends StatefulWidget {
  final VerseModel verse;
  final bool selected;
  final bool favorite;
  final Color? markingColor;
  final bool hasNote;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const VerseText({
    Key? key,
    required this.verse,
    this.selected = false,
    this.favorite = false,
    this.markingColor,
    this.hasNote = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<VerseText> createState() => _VerseTextState();
}

class _VerseTextState extends State<VerseText> {
  final VerseFontSizeStore _verseFontSizeStore = GetIt.I
      .get<VerseFontSizeStore>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Observer(
      builder: (_) => Material(
        color: widget.selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
            : widget.markingColor?.withOpacity(0.28) ?? Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (widget.verse.verse == 1)
                      Row(
                        children: [
                          ChapterTitle(text: (widget.verse.chapter).toString()),
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Html(
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
                                margin: Margins.only(left: 8),
                              ),
                            },
                          ),
                        ),
                        if (widget.favorite)
                          const Padding(
                            padding: EdgeInsets.only(top: 18),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        if (widget.hasNote)
                          const Padding(
                            padding: EdgeInsets.only(top: 18, left: 4),
                            child: Icon(
                              Icons.sticky_note_2_outlined,
                              color: Colors.black45,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.black12,
                height: 0.4,
                width: size.width * 0.95,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
