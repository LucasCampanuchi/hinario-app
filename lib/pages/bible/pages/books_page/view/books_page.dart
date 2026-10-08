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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    controller.list();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livros', style: GoogleFonts.roboto()),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => controller.setOrder(!controller.ordened),
                  child: const Icon(Icons.sort_by_alpha_rounded, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Procurar livro...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar pesquisa',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  final books = controller.listBooks ?? [];
                  final query = _query.toLowerCase();
                  final filteredBooks = books
                      .where(
                        (book) =>
                            book.name.toString().toLowerCase().contains(query),
                      )
                      .toList();

                  if (filteredBooks.isEmpty) {
                    return const Center(
                      child: Text('Nenhum livro encontrado.'),
                    );
                  }

                  return ListView.builder(
                    controller: controller.pageController,
                    padding: const EdgeInsets.only(top: 2),
                    itemCount: filteredBooks.length,
                    itemBuilder: (_, index) =>
                        ButtonBook(book: filteredBooks[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
