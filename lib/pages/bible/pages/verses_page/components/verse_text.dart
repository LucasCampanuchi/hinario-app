import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../models/verse.model.dart';

class VerseText extends StatelessWidget {
  final VerseModel verse;

  const VerseText({
    Key? key,
    required this.verse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Column(
            children: [
              Html(
                data:
                    '<p><span>${verse.verse! == 1 ? '' : verse.verse} </span>${verse.text!}</p>',
                style: {
                  "p": Style(
                    fontFamily: 'Roboto',
                    fontSize: const FontSize(18),
                    color: Colors.black54,
                  ),
                  "span": Style(
                    fontFamily: 'Roboto',
                    fontSize: const FontSize(18),
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
    );
  }
}
