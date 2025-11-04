import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../../../../models/cifra.dart';
import '../store/cifras_web.store.dart';

class CifrasWebPage extends StatefulWidget {
  const CifrasWebPage({Key? key}) : super(key: key);

  @override
  State<CifrasWebPage> createState() => _CifrasWebPageState();
}

class _CifrasWebPageState extends State<CifrasWebPage> {
  final CifrasWebStore store = GetIt.I.get<CifrasWebStore>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.loadCifras(refresh: true);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cifras',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header com busca e informações
          Observer(
            builder: (_) => Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              color: Colors.white,
              child: Column(
                children: [
                  // Informações em texto
                  if (store.totalCifras > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${store.cifras.length} de ${store.totalCifras} cifras',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Barra de busca
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 600 : double.infinity,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar cifras...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  store.clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF3E5A86)),
                        ),
                      ),
                      onSubmitted: (value) {
                        store.setSearchQuery(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de cifras
          Expanded(
            child: Observer(
              builder: (_) {
                if (store.isLoading && store.cifras.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3E5A86),
                    ),
                  );
                }

                if (store.errorMessage != null && store.cifras.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          store.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => store.loadCifras(refresh: true),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (store.cifras.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma cifra encontrada',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => store.loadCifras(refresh: true),
                  child: isDesktop
                      ? _buildDesktopGrid()
                      : isTablet
                          ? _buildTabletGrid()
                          : _buildMobileList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: store.cifras.length + (store.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == store.cifras.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3E5A86),
            ),
          );
        }
        return _buildCifraCard(store.cifras[index], true);
      },
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3.0,
      ),
      itemCount: store.cifras.length + (store.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == store.cifras.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3E5A86),
            ),
          );
        }
        return _buildCifraCard(store.cifras[index], false);
      },
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: store.cifras.length + (store.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == store.cifras.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3E5A86),
              ),
            ),
          );
        }
        return _buildCifraCard(store.cifras[index], false);
      },
    );
  }

  Widget _buildCifraCard(Cifra cifra, bool isCompact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(isCompact ? 12 : 16),
        leading: Container(
          padding: EdgeInsets.all(isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3E5A86).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note,
            color: const Color(0xFF3E5A86),
            size: isCompact ? 20 : 24,
          ),
        ),
        title: Text(
          cifra.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 14 : 16,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'ID: ${cifra.id}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isCompact ? 10 : 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isCompact ? 14 : 16,
          color: Colors.grey,
        ),
        onTap: () {
          if (kIsWeb) {
            Navigator.pushNamed(context, '/${cifra.id}');
          } else {
            Navigator.pushNamed(
              context,
              '/cifra-web-view',
              arguments: {'cifraId': cifra.id},
            );
          }
        },
      ),
    );
  }
}
