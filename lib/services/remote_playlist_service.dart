import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/connection/app_api.dart';
import '../models/playlist.model.dart';
import '../models/remote_playlist.model.dart';
import 'client_identity_service.dart';

/// Rotas /playlist da API.
class RemotePlaylistService {
  static const String _churchCacheKey = 'church_playlists_cache_v1';

  RemotePlaylistService._();
  static final RemotePlaylistService instance = RemotePlaylistService._();

  final ClientIdentityService _identity = ClientIdentityService.instance;

  static const String _codeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final RegExp _labeledCode = RegExp(
    r'c[oó]digo\W{0,3}([A-Za-z0-9]{6})\b',
    caseSensitive: false,
  );
  static final RegExp _anyCode = RegExp(r'\b([A-Z0-9]{6})\b');

  static bool _isValidCode(String code) =>
      code.length == 6 && code.split('').every(_codeChars.contains);

  /// Acha o código curto (ex.: K7P2QX) num texto colado do WhatsApp.
  /// Ordem: "Código: XXXXXX" > texto que é só o código > palavra com dígito.
  static String? extractShortCode(String text) {
    final labeled = _labeledCode.firstMatch(text);
    if (labeled != null) {
      final code = labeled.group(1)!.toUpperCase();
      if (_isValidCode(code)) return code;
    }

    final trimmed = text.trim().toUpperCase();
    if (_isValidCode(trimmed)) return trimmed;

    for (final match in _anyCode.allMatches(text.toUpperCase())) {
      final code = match.group(1)!;
      if (_isValidCode(code) && code.contains(RegExp(r'[0-9]'))) return code;
    }
    return null;
  }

  /// Texto pronto para mandar no WhatsApp.
  static String shareText(Playlist playlist) {
    final buffer = StringBuffer('🎵 Playlist "${playlist.title}"');
    final date = playlist.serviceDateValue;
    if (date != null) {
      buffer.write(
        ' – ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
      );
    }
    buffer.write('\n\nNo app do Hinário, vá em Cifras > Playlists > ');
    buffer.write('"Abrir por código" e digite:\n\nCódigo: ${playlist.remoteCode}');
    return buffer.toString();
  }

  Future<ChurchPlaylists> listChurch() async {
    try {
      final clientId = await _identity.getClientId();
      final data = await AppApi.get(
        'playlist/church',
        query: {'client_id': clientId, 'limit': 30},
      );
      final result = _parseChurch(Map<String, dynamic>.from(data));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_churchCacheKey, jsonEncode(data));
      return result;
    } on ApiException {
      // Sem internet: mostra a última lista que conseguimos baixar
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_churchCacheKey);
      if (cached != null) {
        final parsed = _parseChurch(
          Map<String, dynamic>.from(jsonDecode(cached)),
        );
        return ChurchPlaylists(
          upcoming: parsed.upcoming,
          past: parsed.past,
          pastTotal: parsed.pastTotal,
          fromCache: true,
        );
      }
      rethrow;
    }
  }

  Future<RemotePlaylist> getByCode(String code) async {
    final clientId = await _identity.getClientId();
    final data = await AppApi.get(
      'playlist/code/${code.trim().toUpperCase()}',
      query: {'client_id': clientId},
    );
    return RemotePlaylist.fromJson(Map<String, dynamic>.from(data));
  }

  Future<RemotePlaylist> create(Playlist playlist) async {
    final data = await AppApi.post(
      'playlist',
      data: {...await _identity.actorPayload(), ...playlist.toRemotePayload()},
    );
    return RemotePlaylist.fromJson(Map<String, dynamic>.from(data));
  }

  Future<RemotePlaylist> update(Playlist playlist) async {
    final data = await AppApi.put(
      'playlist/${playlist.remoteCode}',
      data: {...await _identity.actorPayload(), ...playlist.toRemotePayload()},
    );
    return RemotePlaylist.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete(String code) async {
    await AppApi.delete(
      'playlist/$code',
      data: {'client_id': await _identity.getClientId()},
    );
  }

  ChurchPlaylists _parseChurch(Map<String, dynamic> data) {
    List<RemotePlaylist> parse(dynamic list) => (list as List? ?? [])
        .map((e) => RemotePlaylist.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ChurchPlaylists(
      upcoming: parse(data['upcoming']),
      past: parse(data['past']),
      pastTotal: (data['past_total'] as num?)?.toInt() ?? 0,
    );
  }
}
