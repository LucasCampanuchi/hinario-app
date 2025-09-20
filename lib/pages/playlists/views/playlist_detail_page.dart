import 'package:flutter/material.dart';
import '../store/playlist.store.dart';
import '../../../models/playlist.model.dart';
import '../../../models/cifra.dart';
import '../../../pages/cifras/pages/cifra_view_page/view/cifra_view_page.dart';
import '../../../pages/cifras/pages/cifras_page/store/cifras.store.dart';
import 'add_cifras_to_playlist_page.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback onPlaylistUpdated;

  const PlaylistDetailPage({
    Key? key,
    required this.playlist,
    required this.onPlaylistUpdated,
  }) : super(key: key);

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final PlaylistStore _playlistStore = PlaylistStore();
  final CifrasStore _cifrasStore = CifrasStore();
  late Playlist _currentPlaylist;
  List<Cifra> _playlistCifras = [];
  bool _isLoadingCifras = false;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    _loadPlaylistCifras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _currentPlaylist.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_cifras') {
                _showAddCifrasDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_cifras',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Adicionar Cifras'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações da playlist
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF3E5A86),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentPlaylist.description.isNotEmpty) ...[
                  Text(
                    _currentPlaylist.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPlaylist.cifraIds.length} ${_currentPlaylist.cifraIds.length == 1 ? 'cifra' : 'cifras'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de cifras
          Expanded(
            child: _buildCifrasList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCifrasList() {
    if (_isLoadingCifras) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3E5A86),
        ),
      );
    }

    if (_playlistCifras.isEmpty) {
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
                  Icons.music_note,
                  size: 64,
                  color: Color(0xFF3E5A86),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Playlist vazia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Adicione cifras à sua playlist para começar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showAddCifrasDialog,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Cifras'),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _playlistCifras.length,
      itemBuilder: (context, index) {
        final cifra = _playlistCifras[index];
        return _buildCifraCard(cifra, index);
      },
    );
  }

  Widget _buildCifraCard(Cifra cifra, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openCifra(cifra),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E5A86).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E5A86),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cifra.localFilePath != null
                                ? 'Baixado'
                                : 'Não baixado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeCifraFromPlaylist(cifra);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remover', style: TextStyle(color: Colors.red)),
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

  void _showAddCifrasDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCifrasToPlaylistPage(
          playlist: _currentPlaylist,
          onPlaylistUpdated: () {
            widget.onPlaylistUpdated();
            _loadPlaylistCifras();
          },
        ),
      ),
    );
  }

  Future<void> _loadPlaylistCifras() async {
    setState(() {
      _isLoadingCifras = true;
    });

    try {
      // Carregar todas as cifras disponíveis
      await _cifrasStore.loadCifras();

      // Filtrar apenas as cifras que estão na playlist
      final availableCifras = _cifrasStore.cifras
          .where((cifra) => _currentPlaylist.cifraIds.contains(cifra.id))
          .toList();

      // Ordenar pelas mesmas posições da playlist
      final orderedCifras = <Cifra>[];
      for (final cifraId in _currentPlaylist.cifraIds) {
        final cifra = availableCifras.firstWhere(
          (c) => c.id == cifraId,
          orElse: () => throw Exception('Cifra não encontrada'),
        );
        orderedCifras.add(cifra);
      }

      setState(() {
        _playlistCifras = orderedCifras;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar cifras: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCifras = false;
      });
    }
  }

  void _openCifra(Cifra cifra) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CifraViewPage(cifra: cifra),
      ),
    );
  }

  void _removeCifraFromPlaylist(Cifra cifra) async {
    final success = await _playlistStore.removeCifraFromPlaylist(
      _currentPlaylist.id,
      cifra.id,
    );

    if (success) {
      // Atualizar a playlist local
      final updatedCifraIds =
          _currentPlaylist.cifraIds.where((id) => id != cifra.id).toList();

      setState(() {
        _currentPlaylist = _currentPlaylist.copyWith(cifraIds: updatedCifraIds);
        _playlistCifras.removeWhere((c) => c.id == cifra.id);
      });

      widget.onPlaylistUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cifra removida da playlist'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover cifra da playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
