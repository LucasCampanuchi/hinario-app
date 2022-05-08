import 'package:flutter/material.dart';
import 'package:hinario_flutter/models/book.model.dart';

class ButtonChapter extends StatelessWidget {
  final BookModel book;
  final int text;
  final int qtdeChapters;

  const ButtonChapter({
    Key? key,
    required this.text,
    required this.book,
    required this.qtdeChapters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          'versespage',
          arguments: {
            'book': book,
            'qtdeChapters': qtdeChapters,
            'chapter': text,
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 0.3,
            ),
          ),
          width: size.width * 0.20,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$text',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
