import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/button_book.dart';
import '../store/books.store.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final controller = GetIt.I.get<BooksStore>();

  @override
  void initState() {
    controller.list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Observer(
          builder: (_) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: controller.ordened,
                      onChanged: (bool? value) => controller.setOrder(value!),
                    ),
                    Text(
                      'A-Z',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                for (var book in controller.listBooks!) ButtonBook(book: book)
              ],
            );
          },
        ),
      ),
    );
  }
}
