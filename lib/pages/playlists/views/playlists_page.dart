import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../api/connection/app_api.dart';
import '../../../models/remote_playlist.model.dart';
import '../../../services/client_identity_service.dart';
import '../../../services/playlist_remote_sync_service.dart';
import '../../../services/remote_playlist_service.dart';
import '../../../utils/date_br.dart';
import '../../live_room/live_room_entry.dart';
import '../store/playlist.store.dart';
import '../../../models/playlist.model.dart';
import '../widgets/create_playlist_dialog.dart';
import '../widgets/playlist_card.dart';
import 'playlist_detail_page.dart';
import 'remote_playlist_detail_page.dart';
import '../../../services/playlist_share_service.dart';

const _primary = Color(0xFF3E5A86);

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage>
    with SingleTickerProviderStateMixin {
  final PlaylistStore _store = PlaylistStore();
  final PlaylistRemoteSyncService _remoteSync =
      PlaylistRemoteSyncService.instance;
  late final TabController _tabs;
  final GlobalKey<_ChurchPlaylistsTabState> _churchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {})); // mostra/esconde o FAB
    _store.loadPlaylists();
    // reenvia alterações que ficaram pendentes (ex.: estava offline)
    _remoteSync.retryPending().then((_) {
      if (mounted) _store.loadPlaylists();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Playlists',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Abrir por código',
            onPressed: _showOpenByCodeDialog,
            icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'name') {
                final identity = ClientIdentityService.instance;
                final current = await identity.getName();
                if (!mounted) return;
                final name = await identity.askName(context, initial: current);
                if (name != null) await identity.setName(name);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('Meu nome')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Minhas'),
            Tab(text: 'Da igreja'),
            Tab(text: 'Ao vivo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildMine(),
          _ChurchPlaylistsTab(key: _churchKey),
          const LiveRoomsTab(),
        ],
      ),
      floatingActionButton: _tabs.index == 0
          ? FloatingActionButton(
              onPressed: _showCreatePlaylistDialog,
              backgroundColor: _primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Aba "Minhas"
  // ---------------------------------------------------------------------------

  Widget _buildMine() {
    return Observer(
      builder: (context) {
        if (_store.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        if (_store.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
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
            await _remoteSync.retryPending();
            await _store.loadPlaylists();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 88),
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
                color: _primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.playlist_play,
                size: 64,
                color: _primary,
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
              'Crie uma playlist para o próximo culto e publique para a igreja, ou veja as que já foram publicadas na aba "Da igreja".',
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
                backgroundColor: _primary,
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

  void _snack(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CreatePlaylistDialog(
        onCreatePlaylist: (data) async {
          final now = DateTime.now();
          final playlist = Playlist(
            id: Playlist.generateId(),
            title: data.title,
            description: data.description,
            cifraIds: const [],
            createdAt: now,
            updatedAt: now,
            serviceDate: data.serviceDateIso,
          );

          final success = await _store.updatePlaylist(playlist);
          if (!success) {
            _snack('Erro ao criar playlist', error: true);
            return;
          }
          await _store.loadPlaylists();

          if (data.publishToChurch) {
            await _publish(playlist, data.serviceDateIso);
          } else {
            _snack('Playlist criada com sucesso!');
          }
        },
      ),
    );
  }

  Future<void> _publish(Playlist playlist, String? serviceDate) async {
    if (!mounted) return;
    if (!await ClientIdentityService.instance.ensureName(context)) return;
    try {
      await _remoteSync.publish(
        playlist,
        visibility: 'church',
        serviceDate: serviceDate,
      );
      await _store.loadPlaylists();
      _churchKey.currentState?.reload();
      _snack('Publicada! Já aparece para todos em "Da igreja".');
    } on ApiException catch (e) {
      _snack('Salva só no aparelho. ${e.message}', error: true);
    }
  }

  Future<void> _showOpenByCodeDialog() async {
    final codeController = TextEditingController();
    String? errorMessage;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          title: const Text('Abrir por código'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite o código da playlist (ex.: K7P2QX) ou cole a mensagem inteira que você recebeu.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                autofocus: true,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.characters,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                decoration: InputDecoration(
                  hintText: 'K7P2QX',
                  errorText: errorMessage,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: loading
                  ? null
                  : () async {
                      final text = codeController.text;

                      // Formato antigo (HINARIO_PLAYLIST_V1:...) continua funcionando
                      if (text.contains('HINARIO_PLAYLIST_V1:')) {
                        try {
                          final imported =
                              PlaylistShareService.playlistFromShareCode(text);
                          Navigator.of(dialogContext).pop();
                          await _importLegacy(imported);
                        } on FormatException catch (error) {
                          setDialogState(
                            () => errorMessage = error.message.toString(),
                          );
                        }
                        return;
                      }

                      final code = RemotePlaylistService.extractShortCode(
                        text,
                      );
                      if (code == null) {
                        setDialogState(
                          () => errorMessage =
                              'Não encontrei um código de 6 letras/números.',
                        );
                        return;
                      }

                      setDialogState(() {
                        loading = true;
                        errorMessage = null;
                      });
                      try {
                        final remote = await RemotePlaylistService.instance
                            .getByCode(code);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        _openRemote(remote);
                      } on ApiException catch (e) {
                        setDialogState(() {
                          loading = false;
                          errorMessage = e.isNotFound
                              ? 'Nenhuma playlist com o código $code.'
                              : e.message;
                        });
                      }
                    },
              icon: const Icon(Icons.search_rounded),
              label: const Text('Abrir'),
            ),
          ],
        ),
      ),
    );
    codeController.dispose();
  }

  Future<void> _importLegacy(Playlist playlist) async {
    final success = await _store.updatePlaylist(playlist);
    if (!mounted) return;
    if (success) {
      await _store.loadPlaylists();
      _snack('Playlist "${playlist.title}" importada.');
    } else {
      _snack('Não foi possível importar a playlist.', error: true);
    }
  }

  void _openRemote(RemotePlaylist remote) {
    if (!mounted) return;
    // Se é minha e eu tenho a versão local, abro a local (editável)
    if (remote.isMine) {
      final local = _store.playlists
          .where((p) => p.remoteCode == remote.code)
          .firstOrNull;
      if (local != null) {
        _navigateToPlaylistDetail(local);
        return;
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RemotePlaylistDetailPage(playlist: remote),
      ),
    );
  }

  void _editPlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (dialogContext) => CreatePlaylistDialog(
        playlist: playlist,
        onCreatePlaylist: (data) async {
          final updatedPlaylist = playlist.copyWith(
            title: data.title,
            description: data.description,
            serviceDate: data.serviceDateIso,
            clearServiceDate: data.serviceDateIso == null,
            updatedAt: DateTime.now(),
          );

          final success = await _store.updatePlaylist(updatedPlaylist);
          if (!success) {
            _snack('Erro ao atualizar playlist', error: true);
            return;
          }

          if (data.publishToChurch && !playlist.isPublishedToChurch) {
            await _publish(updatedPlaylist, data.serviceDateIso);
          } else if (!data.publishToChurch && playlist.isPublishedToChurch) {
            try {
              await _remoteSync.unpublish(updatedPlaylist);
              _churchKey.currentState?.reload();
              _snack('Playlist tirada da aba "Da igreja".');
            } on ApiException catch (e) {
              _snack(e.message, error: true);
            }
          } else {
            _snack('Playlist atualizada com sucesso!');
          }
          await _store.loadPlaylists();
        },
      ),
    );
  }

  void _deletePlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Playlist'),
        content: Text(
          playlist.isRemote
              ? 'Excluir "${playlist.title}"? Ela some também para quem tem o código${playlist.isPublishedToChurch ? ' e da aba "Da igreja"' : ''}.'
              : 'Tem certeza que deseja excluir a playlist "${playlist.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await _store.deletePlaylist(playlist.id);
              if (success) {
                _churchKey.currentState?.reload();
                _snack('Playlist excluída com sucesso!');
              } else {
                _snack('Erro ao excluir playlist', error: true);
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
          onPlaylistUpdated: () {
            _store.loadPlaylists();
            _churchKey.currentState?.reload();
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Aba "Da igreja"
// -----------------------------------------------------------------------------

class _ChurchPlaylistsTab extends StatefulWidget {
  const _ChurchPlaylistsTab({super.key});

  @override
  State<_ChurchPlaylistsTab> createState() => _ChurchPlaylistsTabState();
}

class _ChurchPlaylistsTabState extends State<_ChurchPlaylistsTab>
    with AutomaticKeepAliveClientMixin {
  ChurchPlaylists? _data;
  String? _error;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    if (mounted) setState(() => _loading = true);
    try {
      final data = await RemotePlaylistService.instance.listChurch();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _data;
    if (data == null) {
      return _message(Icons.cloud_off_rounded, _error ?? 'Erro ao carregar');
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (data.fromCache)
            Card(
              color: Colors.orange.shade50,
              elevation: 0,
              child: const ListTile(
                leading: Icon(Icons.cloud_off_rounded),
                title: Text('Sem internet'),
                subtitle: Text('Mostrando a última lista baixada.'),
              ),
            ),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                'Nenhuma playlist publicada ainda.\n\nCrie uma em "Minhas" e ligue "Publicar para a igreja".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ),
          if (data.upcoming.isNotEmpty) ...[
            _section('Próximos cultos'),
            ...data.upcoming.map((p) => _tile(p, highlight: true)),
          ],
          if (data.past.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Anteriores'),
            ...data.past.map((p) => _tile(p)),
          ],
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Colors.grey.shade700,
      ),
    ),
  );

  Widget _tile(RemotePlaylist p, {bool highlight = false}) {
    final date = p.serviceDateValue;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: highlight
              ? _primary.withValues(alpha: 0.35)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: highlight ? 0.14 : 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date == null ? '--' : date.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              Text(
                date == null ? '' : DateBr.short(date).split(',').first,
                style: const TextStyle(fontSize: 10, color: _primary),
              ),
            ],
          ),
        ),
        title: Text(
          p.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            if (date != null) DateBr.serviceDay(date),
            '${p.items.length} ${p.items.length == 1 ? 'cifra' : 'cifras'}',
            if (p.ownerName != null) p.isMine ? 'você' : p.ownerName!,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RemotePlaylistDetailPage(playlist: p),
          ),
        ),
      ),
    );
  }

  Widget _message(IconData icon, String text) => ListView(
    children: [
      const SizedBox(height: 100),
      Icon(icon, size: 56, color: Colors.grey),
      const SizedBox(height: 16),
      Text(text, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Center(
        child: OutlinedButton(
          onPressed: reload,
          child: const Text('Tentar novamente'),
        ),
      ),
    ],
  );
}
