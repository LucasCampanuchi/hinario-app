import 'package:mobx/mobx.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/cifras_web_service.dart';
import '../../../../../services/app_logger_service.dart';

part 'cifras_web.store.g.dart';

class CifrasWebStore = _CifrasWebStore with _$CifrasWebStore;

abstract class _CifrasWebStore with Store {
  final CifrasWebService _webService = CifrasWebService();

  @observable
  ObservableList<Cifra> cifras = ObservableList<Cifra>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @observable
  int currentPage = 1;

  @observable
  int totalPages = 1;

  @observable
  int totalCifras = 0;

  @observable
  bool hasMoreData = true;

  static const int _pageSize = 50;

  @action
  Future<void> loadCifras({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      cifras.clear();
      hasMoreData = true;
    }

    if (isLoading || (!hasMoreData && !refresh)) return;

    isLoading = refresh || currentPage == 1;
    isLoadingMore = !refresh && currentPage > 1;
    errorMessage = null;

    try {
      final result = await _webService.getCifras(
        page: currentPage,
        limit: _pageSize,
        search: searchQuery.isEmpty ? null : searchQuery,
      );

      final newCifras = result['cifras'] as List<Cifra>;
      totalPages = result['last_page'] ?? 1;
      totalCifras = result['total'] ?? 0;

      if (refresh || currentPage == 1) {
        cifras.clear();
      }

      cifras.addAll(newCifras);
      hasMoreData = currentPage < totalPages;

      print('[CIFRAS_WEB_STORE] Carregadas ${newCifras.length} cifras. Total: ${cifras.length}/$totalCifras');
    } catch (e, stackTrace) {
      print('[CIFRAS_WEB_STORE ERROR] Erro ao carregar cifras: $e');
      errorMessage = 'Erro ao carregar cifras: $e';

      await AppLoggerService.logError('Erro ao carregar cifras web na interface',
          metadata: {
            'error': e.toString(),
            'stack_trace': stackTrace.toString(),
            'current_page': currentPage,
            'search_query': searchQuery,
          });
    } finally {
      isLoading = false;
      isLoadingMore = false;
    }
  }

  @action
  Future<void> loadMoreCifras() async {
    if (!hasMoreData || isLoadingMore) return;

    currentPage++;
    await loadCifras();
  }

  @action
  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    await loadCifras(refresh: true);
  }

  @action
  void clearSearch() {
    searchQuery = '';
    loadCifras(refresh: true);
  }
}