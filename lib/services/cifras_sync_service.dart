import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../api/connection/api.dart';
import '../models/cifra.dart';
import 'database_service.dart';
import '../pages/cifras/pages/cifras_page/store/sync_progress_singleton.dart';
import 'app_logger_service.dart';

class CifrasSyncService {
  final DatabaseService _databaseService = DatabaseService();

  Dio? _dio;

  Future<void> syncCifras() async {
    print('[SYNC] Iniciando sincronização de cifras...');

    try {
      _dio ??= await ApiUtil.createDio();

      final lastSyncDate = await _databaseService.getLastSyncDate();
      final localCount = await _databaseService.getCifrasCount();
      print('[SYNC] Última sincronização: ${lastSyncDate ?? "primeira vez"}');
      print('[SYNC] Cifras locais: $localCount');

      // Verificar total na API
      final apiTotal = await _getApiTotal();
      print('[SYNC] Total na API: $apiTotal');

      // Decidir estratégia de sincronização
      String? updatedAfterToUse;
      List<int>? excludeIds;

      if (localCount < apiTotal) {
        print(
            '[SYNC] Diferença detectada (Local: $localCount, API: $apiTotal). Buscando apenas cifras não existentes.');
        // Buscar IDs das cifras já existentes localmente
        excludeIds = await _databaseService.getAllCifraIds();
        print(
            '[SYNC] Excluindo ${excludeIds.length} IDs já existentes localmente');
        updatedAfterToUse = null; // Não usar data, usar exclusão por IDs
      } else {
        updatedAfterToUse = lastSyncDate; // Sincronização incremental
        excludeIds = null;
      }

      // Buscar todas as cifras paginadas
      final allCifras = await _fetchAllCifras(
        updatedAfter: updatedAfterToUse,
        excludeIds: excludeIds,
      );

      if (allCifras.isEmpty) {
        print('[SYNC] Nenhuma cifra para sincronizar');
        return;
      }

      print('[SYNC] Total de ${allCifras.length} cifras para sincronizar');

      // Iniciar progresso
      SyncProgressSingleton.instance.startSync(allCifras.length);

      // Processar em lotes para melhor performance
      await _processCifrasInBatches(allCifras);

      // Verificar quantas cifras foram realmente salvas
      final savedCount = await _databaseService.getCifrasCount();
      print(
          '[SYNC] Sincronização concluída! Cifras processadas: ${allCifras.length}, Cifras salvas no banco: $savedCount');

      // Log de sucesso
      await AppLoggerService.logInfo('Sincronização concluída com sucesso',
          metadata: {
            'cifras_processadas': allCifras.length,
            'cifras_salvas': savedCount,
            'local_count': localCount,
            'api_total': apiTotal,
          });

      // Finalizar progresso
      SyncProgressSingleton.instance.finishSync();
    } catch (e, stackTrace) {
      print('[SYNC ERROR] Erro na sincronização: $e');
      print('[SYNC ERROR] Stack trace: $stackTrace');

      // Log de erro
      await AppLoggerService.logError('Erro na sincronização', metadata: {
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
        'local_count': await _databaseService.getCifrasCount(),
      });

      SyncProgressSingleton.instance.finishSync();
      throw Exception('Erro na sincronização: $e');
    }
  }

  Future<List<Cifra>> _fetchAllCifras({
    String? updatedAfter,
    List<int>? excludeIds,
  }) async {
    final allCifras = <Cifra>[];
    int page = 1;
    const limit = 50;
    int? lastPage;
    int? total;

    do {
      print('[SYNC] Buscando página $page...');

      final result = await _fetchCifrasWithPagination(
        page: page,
        limit: limit,
        updatedAfter: updatedAfter,
        excludeIds: excludeIds,
      );

      final cifras = result['cifras'] as List<Cifra>;
      lastPage ??= result['last_page'] as int?;
      total ??= result['total'] as int?;

      if (cifras.isEmpty) {
        print('[SYNC] Página $page vazia, parando busca');
        break;
      }

      allCifras.addAll(cifras);
      print(
          '[SYNC] Página $page/$lastPage - ${cifras.length} cifras nesta página, total: ${allCifras.length}/$total');

      // Atualizar progresso da busca
      if (total != null) {
        SyncProgressSingleton.instance.updateProgress(
          allCifras.length,
          total,
          'Buscando cifras...',
        );
      }

      page++;
    } while (page <= (lastPage ?? 1));

    print('[SYNC] Busca finalizada: ${allCifras.length} cifras encontradas');
    return allCifras;
  }

  Future<void> _processCifrasInBatches(List<Cifra> cifras) async {
    print('[SYNC] Iniciando processamento de ${cifras.length} cifras...');

    for (int i = 0; i < cifras.length; i++) {
      final cifra = cifras[i];

      try {
        // Salvar cifra no banco
        await _databaseService.insertCifra(cifra);

        // Baixar arquivo se existir
        if (cifra.file != null) {
          await _downloadAndSaveFile(cifra);
        }

        // Atualizar progresso a cada cifra processada
        SyncProgressSingleton.instance.updateProgress(
          i + 1,
          cifras.length,
          cifra.title,
        );

        // Log a cada 10 cifras processadas
        if ((i + 1) % 10 == 0 || i == cifras.length - 1) {
          print('[SYNC] Processadas ${i + 1}/${cifras.length} cifras');
        }
      } catch (e) {
        print('[SYNC ERROR] Erro ao processar cifra ${cifra.id}: $e');
        // Continua processando as outras cifras
      }
    }

    print(
        '[SYNC] Processamento finalizado: ${cifras.length} cifras processadas');
  }

  Future<Map<String, dynamic>> _fetchCifrasWithPagination({
    int page = 1,
    int limit = 50,
    String? updatedAfter,
    List<int>? excludeIds,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final body = <String, dynamic>{};
    if (updatedAfter != null) body['updatedAfter'] = updatedAfter;
    if (excludeIds != null && excludeIds.isNotEmpty) {
      body['ids'] = excludeIds;
    }

    final response = await _dio!.post(
      'music-external/sync',
      queryParameters: queryParams,
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> cifrasData = data['data']['data'];
      final cifras = cifrasData.map((json) => Cifra.fromJson(json)).toList();

      return {
        'cifras': cifras,
        'last_page': data['data']['last_page'],
        'total': data['data']['total'],
      };
    } else {
      await AppLoggerService.logError('Falha na requisição da API', metadata: {
        'status_code': response.statusCode,
        'page': page,
        'limit': limit,
        'response_data': response.data?.toString() ?? 'null',
      });

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Falha ao buscar cifras: ${response.statusCode}',
      );
    }
  }

  Future<void> _downloadAndSaveFile(Cifra cifra) async {
    if (cifra.file == null) return;

    try {
      // Verificar permissões de armazenamento
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        print(
            '[DOWNLOAD ERROR] Permissão de armazenamento negada para cifra ${cifra.id}');
        await AppLoggerService.logWarning('Permissão de armazenamento negada',
            metadata: {
              'cifra_id': cifra.id,
              'cifra_title': cifra.title,
            });
        return;
      }

      final fileUrl = cifra.file!.url;
      print('[DOWNLOAD] Baixando arquivo: $fileUrl');

      final downloadDio = await ApiUtil.createDio(isArchive: true);
      final response = await downloadDio.get(fileUrl);

      print(
          '[DOWNLOAD] Status: ${response.statusCode}, Size: ${response.data.length} bytes');

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final cifrasDir = Directory('${directory.path}/cifras');

        // Criar diretório se não existir
        if (!await cifrasDir.exists()) {
          await cifrasDir.create(recursive: true);
        }

        final filePath = '${cifrasDir.path}/${cifra.file!.filename}';
        print('[DOWNLOAD] Salvando em: $filePath');

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        // Verificar se arquivo foi salvo corretamente
        if (await file.exists()) {
          final fileSize = await file.length();
          print('[DOWNLOAD] Arquivo verificado: $fileSize bytes');

          await _databaseService.updateCifraFilePath(cifra.id, filePath);
          print('[DOWNLOAD] Arquivo salvo com sucesso para cifra ${cifra.id}');
        } else {
          print(
              '[DOWNLOAD ERROR] Arquivo não foi salvo corretamente para cifra ${cifra.id}');
          await AppLoggerService.logError('Arquivo não foi salvo corretamente',
              metadata: {
                'cifra_id': cifra.id,
                'cifra_title': cifra.title,
                'file_path': filePath,
              });
        }
      } else {
        print('[DOWNLOAD ERROR] Falha no download: ${response.statusCode}');
        await AppLoggerService.logError('Falha no download de arquivo',
            metadata: {
              'cifra_id': cifra.id,
              'cifra_title': cifra.title,
              'file_url': fileUrl,
              'status_code': response.statusCode,
            });
      }
    } catch (e, stackTrace) {
      print('[DOWNLOAD ERROR] Erro ao baixar arquivo da cifra ${cifra.id}: $e');
      print('[DOWNLOAD ERROR] Stack trace: $stackTrace');

      await AppLoggerService.logError('Erro ao baixar arquivo', metadata: {
        'cifra_id': cifra.id,
        'cifra_title': cifra.title,
        'file_url': cifra.file?.url ?? 'null',
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      });
    }
  }

  Future<bool> _checkStoragePermission() async {
    // Usando diretório interno do app - não precisa de permissão
    return true;
  }

  Future<List<Cifra>> getCifras({int? limit, int? offset}) async {
    return await _databaseService.getAllCifras(limit: limit, offset: offset);
  }

  Future<List<Cifra>> searchCifras(String query) async {
    return await _databaseService.searchCifras(query);
  }

  Future<void> clearAllCifras() async {
    print('[SYNC] Limpando todas as cifras...');
    await _databaseService.clearAllCifras();
    print('[SYNC] Limpeza concluída!');
  }

  Future<int> getCifrasCount() async {
    return await _databaseService.getCifrasCount();
  }

  Future<int> getRemoteTotal() async {
    _dio ??= await ApiUtil.createDio();
    return await _getApiTotal();
  }

  Future<Map<String, dynamic>> checkFileIntegrity() async {
    final cifras = await _databaseService.getAllCifras();
    int totalFiles = 0;
    int validFiles = 0;
    int missingFiles = 0;
    int corruptedFiles = 0;

    for (final cifra in cifras) {
      if (cifra.localFilePath != null) {
        totalFiles++;
        final file = File(cifra.localFilePath!);

        if (await file.exists()) {
          try {
            final size = await file.length();
            if (size > 0) {
              validFiles++;
            } else {
              corruptedFiles++;
              print('[FILE CHECK] Arquivo vazio: ${cifra.localFilePath}');
            }
          } catch (e) {
            corruptedFiles++;
            print(
                '[FILE CHECK] Erro ao verificar arquivo: ${cifra.localFilePath} - $e');
          }
        } else {
          missingFiles++;
          print('[FILE CHECK] Arquivo não encontrado: ${cifra.localFilePath}');
        }
      }
    }

    return {
      'total': totalFiles,
      'valid': validFiles,
      'missing': missingFiles,
      'corrupted': corruptedFiles,
    };
  }

  Future<int> _getApiTotal() async {
    try {
      final queryParams = {
        'page': '1',
        'limit': '1',
      };

      final response = await _dio!.post(
        'music-external/sync',
        queryParameters: queryParams,
        data: {},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data']['total'] ?? 0;
      } else {
        print(
            '[SYNC WARNING] Não foi possível obter total da API: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('[SYNC WARNING] Erro ao buscar total da API: $e');
      return 0;
    }
  }
}
