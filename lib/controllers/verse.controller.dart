// ignore_for_file: empty_catches

import '../models/verse.model.dart';
import '../services/verse.service.dart';

class VerseController {
  final VerseService _verseService = VerseService();

  Future<List<VerseModel>?> listVerseByBook(int bookId) async {
    try {
      List<Map<String, Object?>> verses =
          await _verseService.getVerseByBook(bookId);
      return List.from(
        verses
            .map(
              (verse) => VerseModel.fromJson(
                verse,
              ),
            )
            .toList(),
      );
    } catch (e) {}
    return null;
  }

  Future<List<dynamic>?> listVerseByText(String text) async {
    try {
      List<Map<String, Object?>> verses =
          await _verseService.getVerseByText(text);

      return verses;
    } catch (e) {}
    return null;
  }
}
