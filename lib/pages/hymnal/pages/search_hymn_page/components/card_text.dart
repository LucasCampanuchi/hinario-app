import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hinario_flutter/models/hymn.model.dart';
import 'package:hinario_flutter/pages/hymnal/pages/search_hymn_page/store/search_hymn.store.dart';

class CardText extends StatelessWidget {
  final SearchHymnStore controller;
  final HymnModel hymn;

  const CardText({
    Key? key,
    required this.hymn,
    required this.controller,
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
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/hymnview',
                    arguments: {
                      'hymn': hymn,
                    },
                  );

                  controller.clear();
                },
                child: Html(
                  data: '<p><span>${hymn.number}</span></br>${hymn.text}</p>',
                  style: {
                    "p": Style(
                      margin: const EdgeInsets.only(top: 10),
                      fontFamily: 'Roboto',
                      fontSize: const FontSize(18),
                      color: Colors.black54,
                      maxLines: 4,
                    ),
                    "span": Style(
                      fontFamily: 'Roboto',
                      fontSize: const FontSize(18),
                      color: Colors.black,
                      margin: const EdgeInsets.only(left: 8),
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
