import 'package:hinario_flutter/pages/cifras/pages/cifras_page/store/sync_progress.store.dart';
import 'package:mobx/mobx.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/cifras_sync_service.dart';
import '../../../../../services/app_logger_service.dart';
import 'sync_progress_singleton.dart';

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

  @observable
  int totalCifrasCount = 0;

  @observable
  int? remoteTotal;

  @observable
  bool isCheckingRemote = false;

  @observable
  bool isStartingSync = false;

  @observable
  Map<String, dynamic>? fileIntegrity;

  @observable
  bool isCheckingFiles = false;

  static const int _pageSize = 50;
  int currentPage = 0;
  bool _hasMoreData = true;
  final List<Cifra> _allCifras = [];

  @action
  Future<void> loadCifras() async {
    print('[STORE] Iniciando carregamento de cifras...');
    isLoading = true;
    errorMessage = null;
    currentPage = 0;
    _hasMoreData = true;

    try {
      // Carregar apenas a primeira página
      final firstPage =
          await _syncService.getCifras(limit: _pageSize, offset: 0);
      totalCifrasCount = await _syncService.getCifrasCount();

      cifras.clear();
      filteredCifras.clear();
      _allCifras.clear();

      _allCifras.addAll(firstPage);
      cifras.addAll(firstPage);
      _applyFilter();

      _hasMoreData =
          firstPage.length == _pageSize && cifras.length < totalCifrasCount;

      print('[STORE] ${firstPage.length} cifras carregadas com sucesso');

      // Verificar total remoto e integridade dos arquivos em background
      _checkRemoteTotal();
      _checkFileIntegrity();
    } catch (e, stackTrace) {
      print('[STORE ERROR] Erro ao carregar cifras: $e');
      print('[STORE ERROR] Stack trace: $stackTrace');
      errorMessage = 'Erro ao carregar cifras: $e';

      await AppLoggerService.logError('Erro ao carregar cifras na interface',
          metadata: {
            'error': e.toString(),
            'stack_trace': stackTrace.toString(),
          });
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMoreCifras() async {
    if (isLoadingMore || !_hasMoreData || searchQuery.isNotEmpty) return;

    isLoadingMore = true;

    try {
      final offset = cifras.length;
      final moreCifras =
          await _syncService.getCifras(limit: _pageSize, offset: offset);

      if (moreCifras.isNotEmpty) {
        _allCifras.addAll(moreCifras);
        cifras.addAll(moreCifras);
        _applyFilter();

        _hasMoreData =
            moreCifras.length == _pageSize && cifras.length < totalCifrasCount;
        print(
            '[STORE] Carregadas mais ${moreCifras.length} cifras. Total: ${cifras.length}');
      } else {
        _hasMoreData = false;
        print('[STORE] Não há mais cifras para carregar');
      }
    } catch (e) {
      print('[STORE ERROR] Erro ao carregar mais cifras: $e');
    } finally {
      isLoadingMore = false;
    }
  }

  @action
  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    await _applyFilter();
  }

  Future<void> _applyFilter() async {
    if (searchQuery.isEmpty) {
      // Se não há busca, mostrar cifras carregadas
      filteredCifras.clear();
      filteredCifras.addAll(cifras);
    } else {
      // Buscar no banco de dados com normalização
      try {
        final searchResults = await _syncService.searchCifras(searchQuery);
        filteredCifras.clear();
        filteredCifras.addAll(searchResults);
        print(
            '[STORE] Busca por "$searchQuery" retornou ${searchResults.length} resultados');
      } catch (e) {
        print('[STORE ERROR] Erro na busca: $e');
        // Fallback para busca local
        final filtered = cifras
            .where((cifra) => _normalizeText(cifra.title)
                .contains(_normalizeText(searchQuery)))
            .toList();
        filteredCifras.clear();
        filteredCifras.addAll(filtered);
      }
    }
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  @action
  Future<void> syncCifras() async {
    print('[STORE] Iniciando sincronização...');
    errorMessage = null;
    isStartingSync = true;

    try {
      // Executar sincronização em background
      _syncService.syncCifras().then((_) async {
        print(
            '[STORE] Sincronização concluída em background, atualizando contadores...');

        // Atualizar totalCifrasCount primeiro
        totalCifrasCount = await _syncService.getCifrasCount();

        // Depois recarregar a lista
        loadCifras();
      }).catchError((e, stackTrace) {
        print('[STORE ERROR] Erro na sincronização em background: $e');
        errorMessage = 'Erro na sincronização: $e';
        isStartingSync = false;

        AppLoggerService.logError('Erro na sincronização em background',
            metadata: {
              'error': e.toString(),
              'stack_trace': stackTrace.toString(),
            });
      });

      // Aguardar um pouco para dar tempo da sincronização começar
      Future.delayed(const Duration(milliseconds: 500), () {
        if (syncProgress.isSyncing) {
          isStartingSync = false;
        }
      });

      print('[STORE] Sincronização iniciada em background');
    } catch (e, stackTrace) {
      print('[STORE ERROR] Erro ao iniciar sincronização: $e');
      print('[STORE ERROR] Stack trace: $stackTrace');
      errorMessage = 'Erro ao iniciar sincronização: $e';
      isStartingSync = false;
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
      currentPage = 0;
      _hasMoreData = true;
      searchQuery = '';
      totalCifrasCount = 0;
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

  @action
  Future<void> _checkRemoteTotal() async {
    if (isCheckingRemote) return;

    isCheckingRemote = true;
    try {
      remoteTotal = await _syncService.getRemoteTotal();
      print('[STORE] Total remoto: $remoteTotal, Local: $totalCifrasCount');
    } catch (e) {
      print('[STORE] Erro ao verificar total remoto: $e');
      remoteTotal = null;
    } finally {
      isCheckingRemote = false;
    }
  }

  @computed
  bool get needsUpdate =>
      remoteTotal != null && totalCifrasCount < remoteTotal!;

  @computed
  int get missingCifras => needsUpdate ? remoteTotal! - totalCifrasCount : 0;

  @action
  Future<void> _checkFileIntegrity() async {
    if (isCheckingFiles || totalCifrasCount == 0) return;

    isCheckingFiles = true;
    try {
      fileIntegrity = await _syncService.checkFileIntegrity();
      print('[STORE] Integridade dos arquivos: $fileIntegrity');
    } catch (e) {
      print('[STORE] Erro ao verificar integridade dos arquivos: $e');
      fileIntegrity = null;
    } finally {
      isCheckingFiles = false;
    }
  }

  @computed
  bool get hasFileIssues =>
      fileIntegrity != null &&
      (fileIntegrity!['missing'] > 0 || fileIntegrity!['corrupted'] > 0);

  @computed
  SyncProgressStore get syncProgress => SyncProgressSingleton.instance;
}
