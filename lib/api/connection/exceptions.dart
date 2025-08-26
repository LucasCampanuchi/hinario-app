import 'package:dio/dio.dart';
import 'package:hinario_flutter/utils/message.dart';

import '../../utils/check_connection.dart';

class DioExceptions implements Exception {
  messageDioError(DioException dioException) async {
    message(
      fromDioError(
        dioException,
        await checkUserConnection(),
      ).toString(),
    );
  }

  fromDioError(
    DioException dioException,
    bool conected,
  ) {
    String messageDesc;

    switch (dioException.type) {
      case DioExceptionType.cancel:
        messageDesc = 'Requisição foi cancelada';
        break;
      case DioExceptionType.connectionTimeout:
        messageDesc = 'Timeout na conexão';
        break;
      case DioExceptionType.unknown:
        messageDesc = conected
            ? 'Falha na conexão com o servidor'
            : 'Sem conexão com a Internet';
        break;
      case DioExceptionType.receiveTimeout:
        messageDesc = 'Receive timeout in connection with API server';
        break;
      case DioExceptionType.badResponse:
        messageDesc = _handleError(
          dioException.response!.statusCode!,
          dioException.response!.data,
          dioException.requestOptions.path,
        );
        break;
      case DioExceptionType.sendTimeout:
        messageDesc = 'Send timeout in connection with API server';
        break;
      default:
        messageDesc = 'Algo deu errado';
        break;
    }

    return messageDesc;
  }

  String _handleError(
    int statusCode,
    dynamic error,
    String path,
  ) {
    String errorMessage;
    // ignore: avoid_print
    print(error);
    // ignore: avoid_print
    print('Path $path');

    try {
      errorMessage = error['message'];
    } catch (e) {
      errorMessage = 'Rota inexistente';
    }

    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Não autorizado';
      case 404:
        return errorMessage;
      case 500:
        return 'Erro interno no servidor';
      default:
        return 'Oops algo deu errado';
    }
  }
}
