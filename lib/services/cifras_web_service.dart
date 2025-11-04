import 'package:dio/dio.dart';
import '../api/connection/api.dart';
import '../models/cifra.dart';
import '../services/app_logger_service.dart';

class CifrasWebService {
  Dio? _dio;

  Future<Map<String, dynamic>> getCifras({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    try {
      _dio ??= await ApiUtil.createDio();

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio!.get(
        'music-external',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> cifrasData = data['data']['data'];
        final cifras = cifrasData.map((json) => Cifra.fromJson(json)).toList();

        return {
          'cifras': cifras,
          'current_page': data['data']['current_page'],
          'last_page': data['data']['last_page'],
          'total': data['data']['total'],
          'per_page': data['data']['per_page'],
        };
      } else {
        await AppLoggerService.logError('Falha na requisição da API web',
            metadata: {
              'status_code': response.statusCode,
              'page': page,
              'limit': limit,
              'search': search ?? 'null',
              'response_data': response.data?.toString() ?? 'null',
            });

        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Falha ao buscar cifras: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      await AppLoggerService.logError('Erro no serviço de cifras web',
          metadata: {
            'error': e.toString(),
            'stack_trace': stackTrace.toString(),
            'page': page,
            'limit': limit,
            'search': search ?? 'null',
          });
      rethrow;
    }
  }

  Future<int> getTotal() async {
    try {
      final result = await getCifras(page: 1, limit: 1);
      return result['total'] ?? 0;
    } catch (e) {
      print('[CIFRAS_WEB_SERVICE] Erro ao buscar total: $e');
      return 0;
    }
  }

  Future<Cifra> getCifraById(int id) async {
    try {
      _dio ??= await ApiUtil.createDio();

      final response = await _dio!.get('music-external/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return Cifra.fromJson(data);
      } else {
        await AppLoggerService.logError('Falha ao buscar cifra individual', metadata: {
          'status_code': response.statusCode,
          'cifra_id': id,
          'response_data': response.data?.toString() ?? 'null',
        });
        
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Falha ao buscar cifra: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      await AppLoggerService.logError('Erro ao buscar cifra individual', metadata: {
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
        'cifra_id': id,
      });
      rethrow;
    }
  }
}
