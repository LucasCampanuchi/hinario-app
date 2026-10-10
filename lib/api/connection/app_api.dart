import 'package:dio/dio.dart';

import '../utils/constants.dart';

/// Erro amigável vindo da API (mensagem já pronta para mostrar ao usuário).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;
  bool get isForbidden => statusCode == 403;
  bool get isOffline => statusCode == null;

  @override
  String toString() => message;
}

/// Cliente HTTP único para as rotas novas (playlists, sala ao vivo, perfil).
///
/// Diferente do [ApiUtil.createDio], não faz lookup no google.com a cada
/// chamada (a sala ao vivo sincroniza a cada 2s) e trata 4xx como erro.
class AppApi {
  AppApi._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '$URL_BASE/v1/',
      headers: const {'Accept': 'application/json', 'freeroute': 'true'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get(path, queryParameters: query));

  static Future<dynamic> post(String path, {Object? data}) =>
      _run(() => _dio.post(path, data: data));

  static Future<dynamic> put(String path, {Object? data}) =>
      _run(() => _dio.put(path, data: data));

  static Future<dynamic> patch(String path, {Object? data}) =>
      _run(() => _dio.patch(path, data: data));

  static Future<dynamic> delete(String path, {Object? data}) =>
      _run(() => _dio.delete(path, data: data));

  /// Envio de arquivo (multipart). Usa timeout maior: foto pode demorar.
  static Future<dynamic> postForm(
    String path,
    FormData form, {
    void Function(int sent, int total)? onProgress,
  }) => _run(
    () => _dio.post(
      path,
      data: form,
      onSendProgress: onProgress,
      options: Options(
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  static Future<dynamic> _run(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  static ApiException _toApiException(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(
        'Sem conexão com o servidor. Verifique sua internet.',
      );
    }

    String message = 'Erro ${response.statusCode} ao falar com o servidor.';
    final data = response.data;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (data is Map && data['error'] is String) {
      message = data['error'] as String;
    }
    return ApiException(message, statusCode: response.statusCode);
  }
}
