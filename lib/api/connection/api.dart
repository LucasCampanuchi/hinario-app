// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hinario_flutter/utils/message.dart';

import '../../utils/check_connection.dart';
import '../utils/constants.dart';

class ApiUtil {
  static Future<Dio> createDio({
    String version = 'v1',
    bool isArchive = false,
    bool wp = false,
  }) async {
    bool connected = await checkUserConnection();

    Map<String, String> headers = {
      'Accept': 'application/json',
      'freeroute': 'true',
    };

    Dio dio = Dio(
      BaseOptions(
        baseUrl: '$URL_BASE/$version/',
        headers: headers,
        validateStatus: (status) {
          return status! < 400 || status == 404;
        },
      ),
    );

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('REQUEST[${options.method}] => HEADERS: ${options.headers}');
          print('REQUEST[${options.method}] => DATA: ${options.data}');
          print(
            'REQUEST[${options.method}] => QUERY: ${options.queryParameters}',
          );
          print(
            'REQUEST[${options.method}] => CANCEL TOKEN: ${options.cancelToken}',
          );
          print('REQUEST[${options.method}] => BASE URL: ${options.baseUrl}');

          CancelToken cancelToken = CancelToken();
          options.cancelToken = cancelToken;

          if (!connected) {
            message('Sem conexão com a internet');

            cancelToken.cancel();

            return handler.reject(
              DioException(
                type: DioExceptionType.unknown,
                requestOptions: options,
              ),
            );
          }

          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            return handler.reject(e);
          }
        },
      ),
    );

    if (isArchive) {
      dio.options.responseType = ResponseType.bytes;
    }

    return dio;
  }

  static void exitApp() {
    Modular.to.pushNamedAndRemoveUntil('login', (p0) => false);

    message(
      'Token expirado, refaça seu login!',
    );
  }

  static String getUserExceptionMessage(DioException? dioException) {
    if (dioException == null) return 'Erro desconhecido';
    return '${dioException.response!.statusCode}: ${dioException.response!.statusMessage}.';
  }
}
