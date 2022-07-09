import 'package:hinario_flutter/services/new_hymn.service.dart';

import '../models/new_hymn.model.dart';

class NewHymnController {
  final NewHymnService _newHymnService = NewHymnService();

  Future<List<NewHymnModel>?> getAll() async {
    try {
      List<Map<String, Object?>> hymns = await _newHymnService.getAll();

      return List.from(hymns)
          .map(
            (hymn) => NewHymnModel.fromJson(
              hymn,
            ),
          )
          .toList();
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }
}
