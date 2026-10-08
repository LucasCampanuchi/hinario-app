import 'package:hinario_flutter/models/book.model.dart';

class BibleModel {
  final BookModel book;
  final int chapter;
  final int verse;

  BibleModel({
    required this.book,
    required this.chapter,
    required this.verse,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['book'] = book.toJson();
    data['chapter'] = chapter;
    data['verse'] = verse;
    return data;
  }

  BibleModel.fromJson(Map<String, dynamic> json)
      : book = BookModel.fromJson(json['book']),
        chapter = json['chapter'],
        verse = json['verse'];
}
