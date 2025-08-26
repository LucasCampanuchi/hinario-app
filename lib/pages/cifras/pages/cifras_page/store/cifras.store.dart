import 'package:mobx/mobx.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/cifras_sync_service.dart';

part 'cifras.store.g.dart';

class CifrasStore = _CifrasStore with _$CifrasStore;

abstract class _CifrasStore with Store {
  final CifrasSyncService _syncService = CifrasSyncService();

  @observable
  ObservableList<Cifra> cifras = ObservableList<Cifra>();

  @observable
  ObservableList<Cifra> filteredCifras = ObservableList<Cifra>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  static const int _pageSize = 50;
  int _currentPage = 0;
  bool _hasMoreData = true;
  List<Cifra> _allCifras = [];

  @action
  Future<void> loadCifras() async {
    print('[STORE] Iniciando carregamento de cifras...');
    isLoading = true;
    errorMessage = null;
    _currentPage = 0;
    _hasMoreData = true;
    
    try {
      _allCifras = await _syncService.getCifras();
      cifras.clear();
      filteredCifras.clear();
      
      _loadPage();
      _applyFilter();
      
      print('[STORE] ${_allCifras.length} cifras carregadas com sucesso');
    } catch (e, stackTrace) {
      print('[STORE ERROR] Erro ao carregar cifras: $e');
      print('[STORE ERROR] Stack trace: $stackTrace');
      errorMessage = 'Erro ao carregar cifras: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMoreCifras() async {
    if (isLoadingMore || !_hasMoreData) return;
    
    isLoadingMore = true;
    _loadPage();
    _applyFilter();
    isLoadingMore = false;
  }

  void _loadPage() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _allCifras.length);
    
    if (startIndex >= _allCifras.length) {
      _hasMoreData = false;
      return;
    }
    
    final pageItems = _allCifras.sublist(startIndex, endIndex);
    cifras.addAll(pageItems);
    _currentPage++;
    _hasMoreData = endIndex < _allCifras.length;
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (searchQuery.isEmpty) {
      filteredCifras.clear();
      filteredCifras.addAll(cifras);
    } else {
      final filtered = cifras.where((cifra) => 
        cifra.title.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
      filteredCifras.clear();
      filteredCifras.addAll(filtered);
    }
  }

  @action
  Future<void> syncCifras() async {
    print('[STORE] Iniciando sincronização...');
    isLoading = true;
    errorMessage = null;
    
    try {
      await _syncService.syncCifras();
      print('[STORE] Sincronização concluída, recarregando lista...');
      await loadCifras();
    } catch (e, stackTrace) {
      print('[STORE ERROR] Erro na sincronização: $e');
      print('[STORE ERROR] Stack trace: $stackTrace');
      errorMessage = 'Erro na sincronização: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> clearAllCifras() async {
    print('[STORE] Limpando todas as cifras...');
    isLoading = true;
    errorMessage = null;
    
    try {
      await _syncService.clearAllCifras();
      cifras.clear();
      filteredCifras.clear();
      _allCifras.clear();
      _currentPage = 0;
      _hasMoreData = true;
      searchQuery = '';
      print('[STORE] Todas as cifras foram removidas');
    } catch (e, stackTrace) {
      print('[STORE ERROR] Erro ao limpar cifras: $e');
      print('[STORE ERROR] Stack trace: $stackTrace');
      errorMessage = 'Erro ao limpar cifras: $e';
    } finally {
      isLoading = false;
    }
  }

  @computed
  bool get hasMoreData => _hasMoreData;
}