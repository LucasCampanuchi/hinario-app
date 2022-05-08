import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/book.model.dart';
import '../../verses_page/store/verses.store.dart';

class ButtonBook extends StatelessWidget {
  final BookModel book;

  const ButtonBook({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VersesStore controller = GetIt.I.get<VersesStore>();
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        controller.list(context, book, 1);
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 0.3,
          ),
        ),
        width: size.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  book.name ?? 'Nome não disponível',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
