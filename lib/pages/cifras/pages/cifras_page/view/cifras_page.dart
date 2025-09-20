import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../store/cifras.store.dart';
import '../widgets/cifra_card.dart';
import '../../../../playlists/views/playlists_page.dart';

class CifrasPage extends StatefulWidget {
  const CifrasPage({Key? key}) : super(key: key);

  @override
  State<CifrasPage> createState() => _CifrasPageState();
}

class _CifrasPageState extends State<CifrasPage> {
  final CifrasStore store = CifrasStore();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.loadCifras();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      store.loadMoreCifras();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Tem certeza que deseja apagar todas as cifras?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              store.clearAllCifras();
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Column(
            children: [
              const Text(
                'Cifras',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (store.totalCifrasCount > 0)
                Text(
                  '${store.totalCifrasCount} cifras locais',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PlaylistsPage(),
                ),
              );
            },
            icon: const Icon(Icons.playlist_play),
            tooltip: 'Minhas Playlists',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sync') {
                store.syncCifras();
              } else if (value == 'clear') {
                _showClearConfirmDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(
                      Icons.sync,
                      size: 18,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text('Sincronizar'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Limpar todas', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de atualização
          Observer(
            builder: (_) {
              // Se está sincronizando, não mostra nada
              if (store.syncProgress.isSyncing) {
                return const SizedBox.shrink();
              }

              // Se está iniciando sync, mostra loading
              if (store.isStartingSync) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Iniciando sincronização...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Se precisa atualizar, mostra indicador
              return store.needsUpdate
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.update,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Atualização disponível: ${store.missingCifras} novas cifras',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => store.syncCifras(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Atualizar',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          // Indicador de problemas com arquivos
          Observer(
            builder: (_) => store.hasFileIssues
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Problemas com arquivos: ${store.fileIntegrity!['missing']} ausentes, ${store.fileIntegrity!['corrupted']} corrompidos',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => store.syncCifras(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Reparar',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Observer(
              builder: (_) => TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar cifras...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: store.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            store.setSearchQuery('');
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
                onChanged: (value) => store.setSearchQuery(value),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (store.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (store.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Erro na sincronização',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              store.errorMessage!,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => store.loadCifras(),
                                child: const Text('Recarregar'),
                              ),
                              ElevatedButton(
                                onPressed: () => store.syncCifras(),
                                child: const Text('Sincronizar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Verifique os logs no console para mais detalhes',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (store.filteredCifras.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(store.searchQuery.isNotEmpty
                            ? 'Nenhuma cifra encontrada para "${store.searchQuery}"'
                            : 'Nenhuma cifra encontrada'),
                        if (store.totalCifrasCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Total: ${store.totalCifrasCount} cifras no banco',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      store.filteredCifras.length + (store.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == store.filteredCifras.length) {
                      return Observer(
                        builder: (_) => store.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink(),
                      );
                    }

                    final cifra = store.filteredCifras[index];
                    return CifraCard(
                      cifra: cifra,
                      lastUpdate: _formatDate(cifra.updatedAt),
                    );
                  },
                );
              },
            ),
          ),
          // Barra de progresso de sincronização (embaixo)
          Observer(
            builder: (_) => store.syncProgress.isSyncing
                ? Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(158, 158, 158, 0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          value: store.syncProgress.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3E5A86)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sincronizando: ${store.syncProgress.current}/${store.syncProgress.total} (${store.syncProgress.progressPercent}%)',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF3E5A86)),
                        ),
                        if (store.syncProgress.currentItem.isNotEmpty)
                          Text(
                            store.syncProgress.currentItem,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
