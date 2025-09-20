import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.model.dart';
import 'app_logger_service.dart';

class PlaylistService {
  static const String _playlistsKey = 'local_playlists';

  static PlaylistService? _instance;
  static PlaylistService get instance {
    _instance ??= PlaylistService._();
    return _instance!;
  }

  PlaylistService._();

  /// Carrega todas as playlists salvas localmente
  Future<List<Playlist>> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);

      if (playlistsJson == null) {
        return [];
      }

      final List<dynamic> playlistsList = json.decode(playlistsJson);
      final playlists = playlistsList
          .map((playlistJson) => Playlist.fromJson(playlistJson))
          .toList();

      await AppLoggerService.logInfo(
        'Playlists carregadas com sucesso',
        metadata: {
          'total_playlists': playlists.length,
        },
      );

      return playlists;
    } catch (e, stackTrace) {
      await AppLoggerService.logError(
        'Erro ao carregar playlists',
        metadata: {
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
      return [];
    }
  }

  /// Salva uma nova playlist
  Future<bool> savePlaylist(Playlist playlist) async {
    try {
      final playlists = await loadPlaylists();

      // Verifica se já existe uma playlist com o mesmo ID
      final existingIndex = playlists.indexWhere((p) => p.id == playlist.id);

      if (existingIndex != -1) {
        // Atualiza playlist existente
        playlists[existingIndex] = playlist.copyWith(
          updatedAt: DateTime.now(),
        );
      } else {
        // Adiciona nova playlist
        playlists.add(playlist);
      }

      await _savePlaylists(playlists);

      await AppLoggerService.logInfo(
        'Playlist salva com sucesso',
        metadata: {
          'playlist_id': playlist.id,
          'playlist_title': playlist.title,
          'cifras_count': playlist.cifraIds.length,
          'action': existingIndex != -1 ? 'updated' : 'created',
        },
      );

      return true;
    } catch (e, stackTrace) {
      await AppLoggerService.logError(
        'Erro ao salvar playlist',
        metadata: {
          'playlist_id': playlist.id,
          'playlist_title': playlist.title,
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
      return false;
    }
  }

  /// Remove uma playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final playlists = await loadPlaylists();
      playlists.removeWhere((playlist) => playlist.id == playlistId);

      await _savePlaylists(playlists);

      await AppLoggerService.logInfo(
        'Playlist removida com sucesso',
        metadata: {
          'playlist_id': playlistId,
        },
      );

      return true;
    } catch (e, stackTrace) {
      await AppLoggerService.logError(
        'Erro ao remover playlist',
        metadata: {
          'playlist_id': playlistId,
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
      return false;
    }
  }

  /// Adiciona uma cifra a uma playlist
  Future<bool> addCifraToPlaylist(String playlistId, int cifraId) async {
    try {
      final playlists = await loadPlaylists();
      final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);

      if (playlistIndex == -1) {
        throw Exception('Playlist não encontrada');
      }

      final playlist = playlists[playlistIndex];

      // Verifica se a cifra já está na playlist
      if (playlist.cifraIds.contains(cifraId)) {
        return true; // Já está na playlist
      }

      final updatedCifraIds = [...playlist.cifraIds, cifraId];
      playlists[playlistIndex] = playlist.copyWith(
        cifraIds: updatedCifraIds,
        updatedAt: DateTime.now(),
      );

      await _savePlaylists(playlists);

      await AppLoggerService.logInfo(
        'Cifra adicionada à playlist',
        metadata: {
          'playlist_id': playlistId,
          'cifra_id': cifraId,
          'total_cifras': updatedCifraIds.length,
        },
      );

      return true;
    } catch (e, stackTrace) {
      await AppLoggerService.logError(
        'Erro ao adicionar cifra à playlist',
        metadata: {
          'playlist_id': playlistId,
          'cifra_id': cifraId,
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
      return false;
    }
  }

  /// Remove uma cifra de uma playlist
  Future<bool> removeCifraFromPlaylist(String playlistId, int cifraId) async {
    try {
      final playlists = await loadPlaylists();
      final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);

      if (playlistIndex == -1) {
        throw Exception('Playlist não encontrada');
      }

      final playlist = playlists[playlistIndex];
      final updatedCifraIds =
          playlist.cifraIds.where((id) => id != cifraId).toList();

      playlists[playlistIndex] = playlist.copyWith(
        cifraIds: updatedCifraIds,
        updatedAt: DateTime.now(),
      );

      await _savePlaylists(playlists);

      await AppLoggerService.logInfo(
        'Cifra removida da playlist',
        metadata: {
          'playlist_id': playlistId,
          'cifra_id': cifraId,
          'total_cifras': updatedCifraIds.length,
        },
      );

      return true;
    } catch (e, stackTrace) {
      await AppLoggerService.logError(
        'Erro ao remover cifra da playlist',
        metadata: {
          'playlist_id': playlistId,
          'cifra_id': cifraId,
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
      return false;
    }
  }

  /// Busca uma playlist por ID
  Future<Playlist?> getPlaylistById(String playlistId) async {
    try {
      final playlists = await loadPlaylists();
      return playlists.firstWhere(
        (playlist) => playlist.id == playlistId,
        orElse: () => throw Exception('Playlist não encontrada'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Verifica se uma cifra está em alguma playlist
  Future<List<Playlist>> getPlaylistsContainingCifra(int cifraId) async {
    final playlists = await loadPlaylists();
    return playlists
        .where((playlist) => playlist.cifraIds.contains(cifraId))
        .toList();
  }

  /// Salva a lista de playlists no SharedPreferences
  Future<void> _savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(
      playlists.map((playlist) => playlist.toJson()).toList(),
    );
    await prefs.setString(_playlistsKey, playlistsJson);
  }
}
