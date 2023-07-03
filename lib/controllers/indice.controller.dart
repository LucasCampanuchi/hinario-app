import 'package:hinario_flutter/services/indice.service.dart';

class IndiceController {
  final IndiceService _indiceService = IndiceService();

  Future<List<String>?> getHymnByNumber(String number) async {
    try {
      List<Map<String, Object?>> hymn = await _indiceService.getHymnByNumber(
        number,
      );

      if (hymn.isNotEmpty) {
        return List.from(hymn)
            .map(
              (hymn) => hymn['indice'].toString(),
            )
            .toList();
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }
}
