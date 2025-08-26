import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../api/connection/api.dart';
import '../models/cifra.dart';
import 'database_service.dart';

class CifrasSyncService {
  final DatabaseService _databaseService = DatabaseService();
  late final Dio _dio;

  Future<void> syncCifras() async {
    print('[SYNC] Iniciando sincronização de cifras...');
    
    try {
      _dio = await ApiUtil.createDio();
      
      final lastSyncDate = await _databaseService.getLastSyncDate();
      print('[SYNC] Última sincronização: ${lastSyncDate ?? "primeira vez"}');
      
      final cifras = await _fetchCifras(updatedAfter: lastSyncDate);
      print('[SYNC] Encontradas ${cifras.length} cifras para sincronizar');
      
      for (int i = 0; i < cifras.length; i++) {
        final cifra = cifras[i];
        print('[SYNC] Processando cifra ${i + 1}/${cifras.length}: ${cifra.title}');
        
        await _databaseService.insertCifra(cifra);
        print('[SYNC] Cifra ${cifra.id} salva no banco');
        
        if (cifra.file != null) {
          print('[SYNC] Baixando arquivo: ${cifra.file!.filename}');
          await _downloadAndSaveFile(cifra);
        } else {
          print('[SYNC] Cifra ${cifra.id} não possui arquivo');
        }
      }
      
      print('[SYNC] Sincronização concluída com sucesso!');
    } catch (e, stackTrace) {
      print('[SYNC ERROR] Erro na sincronização: $e');
      print('[SYNC ERROR] Stack trace: $stackTrace');
      throw Exception('Erro na sincronização: $e');
    }
  }

  Future<List<Cifra>> _fetchCifras({
    int page = 1,
    int limit = 50,
    String? updatedAfter,
    List<int>? ids,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final body = <String, dynamic>{};
    if (updatedAfter != null) body['updatedAfter'] = updatedAfter;
    if (ids != null) body['ids'] = ids;

    final response = await _dio.post(
      'music-external/sync',
      queryParameters: queryParams,
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> cifrasData = data['data']['data'];
      print('[API] Parsed ${cifrasData.length} cifras from response');
      return cifrasData.map((json) => Cifra.fromJson(json)).toList();
    } else {
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
      final fileUrl = cifra.file!.url;
      
      print('[DOWNLOAD] Baixando arquivo: $fileUrl');
      final downloadDio = await ApiUtil.createDio(isArchive: true);
      final response = await downloadDio.get(fileUrl);
      
      print('[DOWNLOAD] Status: ${response.statusCode}, Size: ${response.data.length} bytes');
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/cifras/${cifra.file!.filename}';
        print('[DOWNLOAD] Salvando em: $filePath');
        
        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.data);
        
        await _databaseService.updateCifraFilePath(cifra.id, filePath);
        print('[DOWNLOAD] Arquivo salvo com sucesso para cifra ${cifra.id}');
      } else {
        print('[DOWNLOAD ERROR] Falha no download: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('[DOWNLOAD ERROR] Erro ao baixar arquivo da cifra ${cifra.id}: $e');
      print('[DOWNLOAD ERROR] Stack trace: $stackTrace');
    }
  }

  Future<List<Cifra>> getCifras() async {
    return await _databaseService.getAllCifras();
  }

  Future<void> clearAllCifras() async {
    print('[SYNC] Limpando todas as cifras...');
    await _databaseService.clearAllCifras();
    print('[SYNC] Limpeza concluída!');
  }
}