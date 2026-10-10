import 'package:flutter/material.dart';

import '../../../models/cifra.dart';
import '../../../models/remote_playlist.model.dart';
import '../../../services/cifra_lookup_service.dart';
import '../../../services/playlist.service.dart';
import '../../../utils/cifra_title.dart';
import '../../../utils/date_br.dart';
import '../../cifras/pages/cifra_view_page/view/cifra_view_page.dart';
import '../../live_room/live_room_entry.dart';

const _primary = Color(0xFF3E5A86);

/// Playlist de outra pessoa (aba "Da igreja" ou aberta por código).
/// Somente leitura: dá para abrir as cifras, salvar uma cópia ou tocar ao vivo.
class RemotePlaylistDetailPage extends StatefulWidget {
  final RemotePlaylist playlist;

  const RemotePlaylistDetailPage({super.key, required this.playlist});

  @override
  State<RemotePlaylistDetailPage> createState() =>
      _RemotePlaylistDetailPageState();
}

class _RemotePlaylistDetailPageState extends State<RemotePlaylistDetailPage> {
  Map<int, Cifra> _cifras = {};
  bool _loading = true;

  RemotePlaylist get p => widget.playlist;

  @override
  void initState() {
    super.initState();
    CifraLookupService.instance.all(refresh: true).then((map) {
      if (mounted) {
        setState(() {
          _cifras = map;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = p.serviceDateValue;
    final missing = p.items.where((i) => _cifras[i.musicId] == null).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          p.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Salvar uma cópia em Minhas',
            icon: const Icon(Icons.library_add_outlined, color: Colors.white),
            onPressed: _saveCopy,
          ),
        ],
      ),
      floatingActionButton: p.items.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              onPressed: () => startLiveRoom(context, playlistCode: p.code),
              icon: const Icon(Icons.sensors_rounded),
              label: const Text('Tocar ao vivo'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (date != null)
                Chip(
                  avatar: const Icon(Icons.event, size: 16),
                  label: Text(DateBr.serviceDay(date)),
                ),
              if (p.ownerName != null)
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: Text(p.isMine ? 'Você' : p.ownerName!),
                ),
              Chip(label: Text('Código ${p.code}')),
            ],
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(p.description, style: TextStyle(color: Colors.grey.shade800)),
          ],
          if (!_loading && missing > 0) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.orange.shade50,
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: Text(
                  missing == 1
                      ? '1 cifra ainda não está no seu aparelho'
                      : '$missing cifras ainda não estão no seu aparelho',
                ),
                subtitle: const Text('Sincronize em Cifras para baixar.'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ...p.items.asMap().entries.map((e) {
              final item = e.value;
              final cifra = _cifras[item.musicId];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _primary.withValues(alpha: 0.1),
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(color: _primary),
                    ),
                  ),
                  title: Text(
                    cifra == null
                        ? 'Cifra nº ${item.musicId}'
                        : CifraTitle.parse(cifra.title).name,
                  ),
                  subtitle: item.note?.isNotEmpty == true
                      ? Text(item.note!)
                      : (cifra == null ? const Text('Não baixada') : null),
                  enabled: cifra?.localFilePath != null,
                  onTap: cifra?.localFilePath == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CifraViewPage(cifra: cifra!),
                          ),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _saveCopy() async {
    final copy = p.toLocalCopy();
    final ok = await PlaylistService.instance.savePlaylist(copy);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Cópia salva em "Minhas". Você pode editar à vontade.'
              : 'Não foi possível salvar a cópia.',
        ),
      ),
    );
  }
}
