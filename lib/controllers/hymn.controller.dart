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
    } catch (e) {
      print(e);
    }
    return null;
  }
}
