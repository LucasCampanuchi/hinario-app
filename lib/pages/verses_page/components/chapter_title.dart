import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChapterTitle extends StatelessWidget {
  final String text;

  const ChapterTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 20,
        bottom: 20,
      ),
      child: Text(
        'Capítulo $text',
        style: GoogleFonts.roboto(
          color: Colors.black26,
          fontWeight: FontWeight.w400,
          fontSize: 35,
        ),
      ),
    );
  }
}
