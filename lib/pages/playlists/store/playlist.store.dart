import 'package:mobx/mobx.dart';
import '../../../models/playlist.model.dart';
import '../../../services/playlist.service.dart';

part 'playlist.store.g.dart';

class PlaylistStore = _PlaylistStoreBase with _$PlaylistStore;

abstract class _PlaylistStoreBase with Store {
  final PlaylistService _playlistService = PlaylistService.instance;

  @observable
  ObservableList<Playlist> playlists = ObservableList<Playlist>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> loadPlaylists() async {
    isLoading = true;
    errorMessage = null;

    try {
      final loadedPlaylists = await _playlistService.loadPlaylists();
      playlists.clear();
      playlists.addAll(loadedPlaylists);
    } catch (e) {
      errorMessage = 'Erro ao carregar playlists: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createPlaylist({
    required String title,
    String description = '',
    List<int> cifraIds = const [],
  }) async {
    try {
      final now = DateTime.now();
      final playlist = Playlist(
        id: Playlist.generateId(),
        title: title,
        description: description,
        cifraIds: cifraIds,
        createdAt: now,
        updatedAt: now,
      );

      final success = await _playlistService.savePlaylist(playlist);
      if (success) {
        playlists.add(playlist);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro ao criar playlist: $e';
      return false;
    }
  }

  @action
  Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      final success = await _playlistService.savePlaylist(playlist);
      if (success) {
        final index = playlists.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          playlists[index] = playlist;
        }
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro ao atualizar playlist: $e';
      return false;
    }
  }

  @action
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final success = await _playlistService.deletePlaylist(playlistId);
      if (success) {
        playlists.removeWhere((playlist) => playlist.id == playlistId);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro ao excluir playlist: $e';
      return false;
    }
  }

  @action
  Future<bool> addCifraToPlaylist(String playlistId, int cifraId) async {
    try {
      final success =
          await _playlistService.addCifraToPlaylist(playlistId, cifraId);
      if (success) {
        await loadPlaylists(); // Recarrega para atualizar a UI
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro ao adicionar cifra à playlist: $e';
      return false;
    }
  }

  @action
  Future<bool> removeCifraFromPlaylist(String playlistId, int cifraId) async {
    try {
      final success =
          await _playlistService.removeCifraFromPlaylist(playlistId, cifraId);
      if (success) {
        await loadPlaylists(); // Recarrega para atualizar a UI
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro ao remover cifra da playlist: $e';
      return false;
    }
  }

  @computed
  int get totalPlaylists => playlists.length;

  @computed
  List<Playlist> get sortedPlaylists {
    final sortedList = playlists.toList();
    sortedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedList;
  }

  // Verifica se uma cifra está em alguma playlist
  Future<List<Playlist>> getPlaylistsContainingCifra(int cifraId) async {
    return await _playlistService.getPlaylistsContainingCifra(cifraId);
  }

  // Busca uma playlist por ID
  Playlist? getPlaylistById(String playlistId) {
    try {
      return playlists.firstWhere((playlist) => playlist.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
