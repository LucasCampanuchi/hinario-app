import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../store/cifras.store.dart';

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
        title: const Text(
          'Cifras',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => store.syncCifras(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpar todas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar cifras...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => store.setSearchQuery(value),
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
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro na sincronização',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: Text(store.searchQuery.isNotEmpty 
                      ? 'Nenhuma cifra encontrada para "${store.searchQuery}"'
                      : 'Nenhuma cifra encontrada'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: store.filteredCifras.length + (store.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == store.filteredCifras.length) {
                      return Observer(
                        builder: (_) => store.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink(),
                      );
                    }
                    
                    final cifra = store.filteredCifras[index];
                    return ListTile(
                      title: Text(cifra.title),
                      subtitle: Text('Atualizada em: ${_formatDate(cifra.updatedAt)}'),
                      trailing: cifra.localFilePath != null
                          ? const Icon(Icons.download_done, color: Colors.green)
                          : const Icon(Icons.download, color: Colors.grey),
                      onTap: () {
                        if (cifra.localFilePath != null) {
                          Modular.to.pushNamed('/cifra_view', arguments: {'cifra': cifra});
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}