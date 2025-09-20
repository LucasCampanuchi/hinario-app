import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../models/cifra.dart';
import '../../playlists/store/playlist.store.dart';
import '../../../models/playlist.model.dart';

class CifraCard extends StatelessWidget {
  final Cifra cifra;
  final String? lastUpdate;

  const CifraCard({
    Key? key,
    required this.cifra,
    this.lastUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (cifra.localFilePath != null) {
            Modular.to.pushNamed('/cifra_view', arguments: {'cifra': cifra});
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone de status do download
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cifra.localFilePath != null
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  cifra.localFilePath != null
                      ? Icons.download_done
                      : Icons.download,
                  color:
                      cifra.localFilePath != null ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Conteúdo da cifra
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cifra.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (lastUpdate != null)
                      Text(
                        'Atualizada em: $lastUpdate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),

              // Menu de ações
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'add_to_playlist') {
                    _showAddToPlaylistDialog(context);
                  } else if (value == 'view') {
                    if (cifra.localFilePath != null) {
                      Modular.to.pushNamed('/cifra_view',
                          arguments: {'cifra': cifra});
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (cifra.localFilePath != null)
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('Visualizar'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add, size: 18),
                        SizedBox(width: 8),
                        Text('Adicionar à Playlist'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context) async {
    final playlistStore = PlaylistStore();
    await playlistStore.loadPlaylists();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AddToPlaylistDialog(
        cifra: cifra,
        playlists: playlistStore.playlists,
        onAddToPlaylist: (playlist) async {
          final success = await playlistStore.addCifraToPlaylist(
            playlist.id,
            cifra.id,
          );

          if (context.mounted) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Cifra adicionada à playlist "${playlist.title}"'
                      : 'Erro ao adicionar cifra à playlist',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
        onCreateNewPlaylist: () async {
          Navigator.of(context).pop();
          _showCreatePlaylistDialog(context, playlistStore);
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(
      BuildContext context, PlaylistStore controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título da Playlist',
                hintText: 'Ex: Reunião de Sábado à Noite',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva o propósito desta playlist',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite um título para a playlist'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final success = await controller.createPlaylist(
                title: title,
                description: descriptionController.text.trim(),
                cifraIds: [cifra.id],
              );

              if (context.mounted) {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Playlist "$title" criada com a cifra'
                          : 'Erro ao criar playlist',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E5A86),
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class AddToPlaylistDialog extends StatefulWidget {
  final Cifra cifra;
  final List<Playlist> playlists;
  final Function(Playlist) onAddToPlaylist;
  final VoidCallback onCreateNewPlaylist;

  const AddToPlaylistDialog({
    Key? key,
    required this.cifra,
    required this.playlists,
    required this.onAddToPlaylist,
    required this.onCreateNewPlaylist,
  }) : super(key: key);

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar à Playlist'),
      content: widget.playlists.isEmpty
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.playlist_play,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Você ainda não tem playlists.\nCrie sua primeira playlist!',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = widget.playlists[index];
                  final alreadyAdded =
                      playlist.cifraIds.contains(widget.cifra.id);

                  return ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(playlist.title),
                    subtitle: Text('${playlist.cifraIds.length} cifras'),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: alreadyAdded
                        ? null
                        : () => widget.onAddToPlaylist(playlist),
                    enabled: !alreadyAdded,
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: widget.onCreateNewPlaylist,
          icon: const Icon(Icons.add),
          label: const Text('Nova Playlist'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E5A86),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
