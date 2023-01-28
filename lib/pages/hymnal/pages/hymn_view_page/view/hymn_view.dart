import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/models/hymn.model.dart';

import '../utils/test_number.dart';

class HymnView extends StatefulWidget {
  final HymnModel hymn;

  const HymnView({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  State<HymnView> createState() => _HymnViewState();
}

class _HymnViewState extends State<HymnView> {
  double _fontSize = 20;
  final double _baseFontSize = 20;
  double _fontScale = 1;
  double _baseFontScale = 1;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hymn.name,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 1) {
                Navigator.pushNamed(context, '/searchhymn');
              } else if (value == 2) {
                Navigator.pushNamed(context, '/configuration');
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Row(
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
                  value: 1,
                ),
                /* PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Ajustes',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  value: 2,
                ), */
              ];
            },
          ),
        ],
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          'score',
          arguments: {
            'hymn': hymn,
          },
        ),
        child: const Icon(Icons.music_note),
      ), */
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onScaleStart: (ScaleStartDetails scaleStartDetails) {
              _baseFontScale = _fontScale;
            },
            onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
              // don't update the UI if the scale didn't change
              if (scaleUpdateDetails.scale == 1.0) {
                return;
              }
              setState(() {
                _fontScale =
                    (_baseFontScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
                _fontSize = _fontScale * _baseFontSize;
              });
            },
            child: Column(
              children: [
                for (String item in widget.hymn.text.split('\n\n'))
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: SizedBox(
                          width: size.width - 56,
                          child: Text(
                            (item),
                            style: GoogleFonts.roboto(
                                fontWeight: testNumber(item.split(' ')[0])
                                    ? FontWeight.w400
                                    : FontWeight.bold,
                                fontSize: _fontSize,
                                color: Colors.black45),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
