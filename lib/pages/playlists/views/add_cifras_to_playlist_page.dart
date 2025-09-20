import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../models/cifra.dart';
import '../../../models/playlist.model.dart';
import '../store/playlist.store.dart';
import '../../cifras/pages/cifras_page/store/cifras.store.dart';

class AddCifrasToPlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback onPlaylistUpdated;

  const AddCifrasToPlaylistPage({
    Key? key,
    required this.playlist,
    required this.onPlaylistUpdated,
  }) : super(key: key);

  @override
  State<AddCifrasToPlaylistPage> createState() =>
      _AddCifrasToPlaylistPageState();
}

class _AddCifrasToPlaylistPageState extends State<AddCifrasToPlaylistPage> {
  final CifrasStore _cifrasStore = CifrasStore();
  final PlaylistStore _playlistStore = PlaylistStore();
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedCifras = <int>{};

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cifrasStore.loadCifras();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Adicionar Cifras',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
        actions: [
          if (_selectedCifras.isNotEmpty)
            TextButton(
              onPressed: _addSelectedCifras,
              child: Text(
                'Adicionar (${_selectedCifras.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar cifras...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Lista de cifras
          Expanded(
            child: Observer(
              builder: (context) {
                if (_cifrasStore.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3E5A86),
                    ),
                  );
                }

                final availableCifras = _getAvailableCifras();

                if (availableCifras.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableCifras.length,
                  itemBuilder: (context, index) {
                    final cifra = availableCifras[index];
                    final isSelected = _selectedCifras.contains(cifra.id);
                    final isAlreadyInPlaylist =
                        widget.playlist.cifraIds.contains(cifra.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? const BorderSide(
                                color: Color(0xFF3E5A86), width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: Container(
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
                            color: cifra.localFilePath != null
                                ? Colors.green
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          cifra.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isAlreadyInPlaylist
                                ? Colors.grey[600]
                                : const Color(0xFF2D3748),
                          ),
                        ),
                        subtitle: isAlreadyInPlaylist
                            ? const Text(
                                'Já está na playlist',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : null,
                        trailing: isAlreadyInPlaylist
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedCifras.add(cifra.id);
                                    } else {
                                      _selectedCifras.remove(cifra.id);
                                    }
                                  });
                                },
                                activeColor: const Color(0xFF3E5A86),
                              ),
                        onTap: isAlreadyInPlaylist
                            ? null
                            : () {
                                setState(() {
                                  if (_selectedCifras.contains(cifra.id)) {
                                    _selectedCifras.remove(cifra.id);
                                  } else {
                                    _selectedCifras.add(cifra.id);
                                  }
                                });
                              },
                        enabled: !isAlreadyInPlaylist,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedCifras.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addSelectedCifras,
              backgroundColor: const Color(0xFF3E5A86),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Adicionar ${_selectedCifras.length}',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
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
                Icons.music_note,
                size: 64,
                color: Color(0xFF3E5A86),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma cifra disponível',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nenhuma cifra encontrada para "$_searchQuery"'
                  : 'Todas as cifras já estão nesta playlist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Cifra> _getAvailableCifras() {
    List<Cifra> cifras = _cifrasStore.filteredCifras.toList();

    // Filtrar por busca se houver
    if (_searchQuery.isNotEmpty) {
      cifras = cifras.where((cifra) {
        return cifra.title.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return cifras;
  }

  Future<void> _addSelectedCifras() async {
    if (_selectedCifras.isEmpty) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3E5A86),
        ),
      ),
    );

    int successCount = 0;

    for (final cifraId in _selectedCifras) {
      final success = await _playlistStore.addCifraToPlaylist(
        widget.playlist.id,
        cifraId,
      );
      if (success) successCount++;
    }

    if (mounted) {
      Navigator.of(context).pop(); // Fechar loading

      if (successCount > 0) {
        widget.onPlaylistUpdated();
        Navigator.of(context).pop(); // Voltar para a página anterior

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount cifra(s) adicionada(s) à playlist'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao adicionar cifras à playlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
