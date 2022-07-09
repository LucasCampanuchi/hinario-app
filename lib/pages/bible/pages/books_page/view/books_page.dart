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
  final BooksStore controller = GetIt.I.get<BooksStore>();

  @override
  void initState() {
    controller.list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Livros',
          style: GoogleFonts.roboto(),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => controller.setOrder(!controller.ordened),
                  child: const Icon(
                    Icons.sort_by_alpha_rounded,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: controller.pageController,
        child: Observer(
          builder: (_) {
            return Column(
              children: [
                const SizedBox(
                  height: 10,
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
