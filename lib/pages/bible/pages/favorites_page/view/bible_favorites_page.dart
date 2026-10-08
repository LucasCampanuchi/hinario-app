import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../models/bible_verse_annotation.model.dart';
import '../../../../../models/book.model.dart';
import '../../../../../services/bible_verse_annotation_service.dart';
import '../../verses_page/store/verses.store.dart';

class BibleFavoritesPage extends StatefulWidget {
  const BibleFavoritesPage({super.key});

  @override
  State<BibleFavoritesPage> createState() => _BibleFavoritesPageState();
}

class _BibleFavoritesPageState extends State<BibleFavoritesPage> {
  final BibleVerseAnnotationService _service = BibleVerseAnnotationService();
  final VersesStore _versesStore = GetIt.I.get<VersesStore>();
  late Future<List<BibleVerseAnnotation>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = _service.favorites();
  }

  void _reload() => setState(() => _favorites = _service.favorites());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Versículos favoritos')),
    body: SafeArea(
      top: false,
      child: FutureBuilder<List<BibleVerseAnnotation>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? <BibleVerseAnnotation>[];
          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Você ainda não favoritou nenhum versículo.\n\nToque e segure um versículo para selecioná-lo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text('${item.bookName} ${item.chapter}:${item.verse}'),
                  subtitle: Text(
                    item.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: item.hasMarking
                      ? Icon(
                          Icons.format_paint,
                          color: item.colorValue == null
                              ? Colors.black45
                              : Color(item.colorValue!),
                        )
                      : null,
                  onTap: () async {
                    await _versesStore.list(
                      context,
                      BookModel(id: item.bookId, name: item.bookName),
                      item.chapter,
                      item.verse,
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          );
        },
      ),
    ),
  );
}
