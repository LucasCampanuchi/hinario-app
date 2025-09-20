import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../store/playlist.store.dart';
import '../../../models/playlist.model.dart';
import '../widgets/create_playlist_dialog.dart';
import '../widgets/playlist_card.dart';
import 'playlist_detail_page.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({Key? key}) : super(key: key);

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final PlaylistStore _store = PlaylistStore();

  @override
  void initState() {
    super.initState();
    _store.loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Minhas Playlists',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3E5A86),
              ),
            );
          }

          if (_store.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _store.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _store.clearError();
                      _store.loadPlaylists();
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (_store.playlists.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _store.loadPlaylists();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 16,
              ),
              itemCount: _store.sortedPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = _store.sortedPlaylists[index];
                return PlaylistCard(
                  playlist: playlist,
                  onTap: () => _navigateToPlaylistDetail(playlist),
                  onDelete: () => _deletePlaylist(playlist),
                  onEdit: () => _editPlaylist(playlist),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        backgroundColor: const Color(0xFF3E5A86),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3E5A86).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.playlist_play,
                size: 64,
                color: Color(0xFF3E5A86),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma playlist criada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crie sua primeira playlist para organizar suas cifras favoritas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreatePlaylistDialog,
              icon: const Icon(Icons.add),
              label: const Text('Criar Playlist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E5A86),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        onCreatePlaylist: (title, description) async {
          final success = await _store.createPlaylist(
            title: title,
            description: description,
          );

          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playlist criada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erro ao criar playlist'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editPlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        playlist: playlist,
        onCreatePlaylist: (title, description) async {
          final updatedPlaylist = playlist.copyWith(
            title: title,
            description: description,
            updatedAt: DateTime.now(),
          );

          final success = await _store.updatePlaylist(updatedPlaylist);

          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playlist atualizada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erro ao atualizar playlist'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deletePlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Playlist'),
        content: Text(
            'Tem certeza que deseja excluir a playlist "${playlist.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await _store.deletePlaylist(playlist.id);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Playlist excluída com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao excluir playlist'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _navigateToPlaylistDetail(Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlist: playlist,
          onPlaylistUpdated: () => _store.loadPlaylists(),
        ),
      ),
    );
  }
}
