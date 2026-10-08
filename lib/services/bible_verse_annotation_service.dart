import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_verse_annotation.model.dart';

class BibleVerseAnnotationService {
  static const _key = 'bible_verse_annotations_v1';

  Future<Map<int, BibleVerseAnnotation>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(_key);
    if (source == null || source.isEmpty) return <int, BibleVerseAnnotation>{};

    try {
      final items = jsonDecode(source) as List<dynamic>;
      return <int, BibleVerseAnnotation>{
        for (final item in items)
          (item as Map<String, dynamic>)['verse_id'] as int:
              BibleVerseAnnotation.fromJson(item),
      };
    } catch (_) {
      return <int, BibleVerseAnnotation>{};
    }
  }

  Future<void> save(Map<int, BibleVerseAnnotation> annotations) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key,
      jsonEncode(annotations.values.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<BibleVerseAnnotation>> favorites() async {
    final annotations = await load();
    final values = annotations.values.where((item) => item.favorite).toList()
      ..sort((a, b) {
        final book = a.bookName.compareTo(b.bookName);
        if (book != 0) return book;
        final chapter = a.chapter.compareTo(b.chapter);
        return chapter != 0 ? chapter : a.verse.compareTo(b.verse);
      });
    return values;
  }
}
