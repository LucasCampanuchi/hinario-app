import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/models/hymn.model.dart';

import '../utils/test_number.dart';

class HymnView extends StatelessWidget {
  final HymnModel hymn;

  const HymnView({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hymn.name,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          'score',
          arguments: {
            'hymn': hymn,
          },
        ),
        child: const Icon(Icons.music_note),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              for (String item in hymn.text.split('\n\n'))
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
                              fontSize: 20,
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
    );
  }
}
