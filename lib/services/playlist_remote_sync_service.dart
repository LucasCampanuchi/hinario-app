import 'dart:async';

import '../api/connection/app_api.dart';
import '../models/playlist.model.dart';
import 'playlist.service.dart';
import 'remote_playlist_service.dart';

/// Mantém a cópia da API igual à playlist local para as playlists
/// que já têm código (compartilhadas ou publicadas para a igreja).
///
/// A playlist local continua sendo a fonte da verdade: se estiver sem
/// internet, marca `pendingSync` e tenta de novo depois.
class PlaylistRemoteSyncService {
  PlaylistRemoteSyncService._();
  static final PlaylistRemoteSyncService instance =
      PlaylistRemoteSyncService._();

  final PlaylistService _local = PlaylistService.instance;
  final RemotePlaylistService _remote = RemotePlaylistService.instance;
  final Map<String, Timer> _debounce = {};

  /// Agenda o envio (várias alterações seguidas viram um só PUT).
  void schedulePush(String playlistId) {
    _debounce[playlistId]?.cancel();
    _debounce[playlistId] = Timer(const Duration(milliseconds: 800), () {
      _debounce.remove(playlistId);
      pushNow(playlistId);
    });
  }

  /// Envia agora. Retorna a playlist atualizada (ou null se não for remota).
  Future<Playlist?> pushNow(String playlistId) async {
    final playlist = await _local.getPlaylistById(playlistId);
    if (playlist == null || !playlist.isRemote) return playlist;

    try {
      await _remote.update(playlist);
      return await _saveFlags(playlist.id, pendingSync: false);
    } on ApiException catch (e) {
      if (e.isNotFound || e.isForbidden) {
        // Apagada na API ou não é mais dono: volta a ser só local
        return await _saveFlags(
          playlist.id,
          pendingSync: false,
          transform: (p) =>
              p.copyWith(clearRemoteCode: true, visibility: 'private'),
        );
      }
      return await _saveFlags(playlist.id, pendingSync: true);
    }
  }

  /// Cria a playlist na API (para compartilhar o código ou publicar).
  Future<Playlist> publish(
    Playlist playlist, {
    required String visibility,
    String? serviceDate,
  }) async {
    var updated = playlist.copyWith(
      visibility: visibility,
      serviceDate: serviceDate,
      updatedAt: DateTime.now(),
    );

    if (updated.isRemote) {
      await _remote.update(updated);
    } else {
      final created = await _remote.create(updated);
      updated = updated.copyWith(remoteCode: created.code);
    }

    final code = updated.remoteCode;
    return (await _saveFlags(
      playlist.id,
      pendingSync: false,
      transform: (p) => p.copyWith(
        remoteCode: code,
        visibility: visibility,
        serviceDate: serviceDate,
      ),
    )) ?? updated;
  }

  /// Tira da aba "Da igreja" (o código continua funcionando).
  Future<Playlist> unpublish(Playlist playlist) async {
    final updated = playlist.copyWith(visibility: 'private');
    if (updated.isRemote) await _remote.update(updated);
    return (await _saveFlags(
      playlist.id,
      pendingSync: false,
      transform: (p) => p.copyWith(visibility: 'private'),
    )) ?? updated;
  }

  /// Ao excluir localmente, remove também da API (melhor esforço).
  Future<void> deleteRemote(Playlist playlist) async {
    if (!playlist.isRemote) return;
    try {
      await _remote.delete(playlist.remoteCode!);
    } catch (_) {
      // se falhar, ela fica órfã na API; não bloqueia a exclusão local
    }
  }

  /// Reenvia o que ficou pendente (chamado ao abrir a tela de playlists).
  Future<void> retryPending() async {
    final playlists = await _local.loadPlaylists();
    for (final p in playlists.where((p) => p.pendingSync && p.isRemote)) {
      await pushNow(p.id);
    }
  }

  /// Relê a versão local mais recente (pode ter mudado durante o envio)
  /// e só aplica as marcações de sincronização.
  Future<Playlist?> _saveFlags(
    String playlistId, {
    required bool pendingSync,
    Playlist Function(Playlist)? transform,
  }) async {
    final latest = await _local.getPlaylistById(playlistId);
    if (latest == null) return null;
    var updated = latest.copyWith(pendingSync: pendingSync);
    if (transform != null) updated = transform(updated);
    await _local.savePlaylist(updated, touch: false);
    return updated;
  }
}
