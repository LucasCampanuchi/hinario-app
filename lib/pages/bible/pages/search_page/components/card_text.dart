import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';

import '../store/search_bible.store.dart';

class CardText extends StatelessWidget {
  final dynamic verse;

  const CardText({
    Key? key,
    required this.verse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchBibleStore controller = GetIt.I.get<SearchBibleStore>();
    final Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => controller.setVerse(context, verse),
                child: Html(
                  data:
                      '<p><span>${verse['name']!} ${verse['chapter']!}:${verse['verse']!}</span></br>${verse['text']!}</p>',
                  style: {
                    "p": Style(
                      fontFamily: 'Roboto',
                      fontSize: FontSize(18),
                      color: Colors.black54,
                    ),
                    "span": Style(
                      fontFamily: 'Roboto',
                      fontSize: FontSize(18),
                      color: Colors.black,
                      margin: Margins.only(
                        right: 8,
                      ),
                    ),
                  },
                ),
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
    );
  }
}
