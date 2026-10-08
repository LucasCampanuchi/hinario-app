import 'dart:convert';

import '../models/playlist.model.dart';

class PlaylistShareService {
  static const _prefix = 'HINARIO_PLAYLIST_V1:';

  const PlaylistShareService._();

  static String createShareCode(Playlist playlist) {
    final data = <String, dynamic>{
      'id': playlist.id,
      'title': playlist.title,
      'description': playlist.description,
      'cifra_ids': playlist.cifraIds,
    };
    return '$_prefix${base64UrlEncode(utf8.encode(jsonEncode(data)))}';
  }

  static Playlist playlistFromShareCode(String value) {
    final match = RegExp('$_prefix([A-Za-z0-9_-]+)').firstMatch(value);
    if (match == null) {
      throw const FormatException('Código de playlist inválido.');
    }

    try {
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(match.group(1)!)),
      );
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final title = (data['title'] as String? ?? '').trim();
      final cifraIds = List<int>.from(data['cifra_ids'] ?? const <int>[]);

      if (title.isEmpty) {
        throw const FormatException('A playlist recebida não possui título.');
      }

      final now = DateTime.now();
      return Playlist(
        id: (data['id'] as String? ?? '').trim().isNotEmpty
            ? (data['id'] as String).trim()
            : Playlist.generateId(),
        title: title,
        description: (data['description'] as String? ?? '').trim(),
        cifraIds: cifraIds,
        createdAt: now,
        updatedAt: now,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Não foi possível ler esta playlist.');
    }
  }
}
