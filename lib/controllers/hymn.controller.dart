import 'package:hinario_flutter/services/hymn.service.dart';

import '../models/hymn.model.dart';

class HymnController {
  final HymnService _hymnService = HymnService();

  Future<HymnModel?> getHymnByNumber(String number) async {
    try {
      List<Map<String, Object?>> hymn = await _hymnService.getHymnByNumber(
        number,
      );

      if (hymn.isNotEmpty) {
        return HymnModel.fromJson(hymn[0]);
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<List<HymnModel>?> listHymnByText(String text) async {
    try {
      List<Map<String, Object?>> hymns = await _hymnService.getHymnByText(
        text,
      );

      return List.from(hymns)
          .map(
            (hymn) => HymnModel.fromJson(
              hymn,
            ),
          )
          .toList();
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }
}
