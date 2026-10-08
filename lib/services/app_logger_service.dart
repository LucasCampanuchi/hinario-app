import 'package:dio/dio.dart';
import '../api/connection/api.dart';

class AppLoggerService {
  static const Duration _timeout = Duration(seconds: 2);
  static Dio? _dio;

  static Future<void> _ensureDio() async {
    _dio ??= await ApiUtil.createDio();
  }

  static Future<void> logError(
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    await _sendLog('error', message, metadata).timeout(
      _timeout,
      onTimeout: () => print('[LOG] Envio ignorado por timeout'),
    );
  }

  static Future<void> logWarning(
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    await _sendLog('warning', message, metadata).timeout(
      _timeout,
      onTimeout: () => print('[LOG] Envio ignorado por timeout'),
    );
  }

  static Future<void> logInfo(
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    await _sendLog('info', message, metadata).timeout(
      _timeout,
      onTimeout: () => print('[LOG] Envio ignorado por timeout'),
    );
  }

  static Future<void> _sendLog(
    String level,
    String message,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      await _ensureDio();

      final logData = {
        'level': level,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };

      await _dio!.post('app-logs', data: logData);
    } catch (e) {
      // Não fazer nada se falhar o envio do log para não criar loop
      print('[LOG ERROR] Falha ao enviar log: $e');
    }
  }
}
