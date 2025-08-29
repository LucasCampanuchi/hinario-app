import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hinario_flutter/components/error_pattern_widget.dart';

import '../services/app_logger_service.dart';

Future<void> initErrors() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint("Erro global capturado: ${details.exception}");

    // Enviar para API de logs
    AppLoggerService.logError(
      'Erro Flutter capturado globalmente',
      metadata: {
        'exception': details.exception.toString(),
        'stack_trace': details.stack.toString(),
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
      },
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // Enviar para API de logs
    AppLoggerService.logError(
      'Erro de plataforma capturado globalmente',
      metadata: {
        'error': error.toString(),
        'stack_trace': stack.toString(),
        'error_type': error.runtimeType.toString(),
      },
    );

    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint("Erro global capturado: ${details.exception}");

    // Enviar para API de logs
    AppLoggerService.logError(
      'Erro de widget capturado globalmente',
      metadata: {
        'exception': details.exception.toString(),
        'stack_trace': details.stack.toString(),
        'library': details.library ?? 'unknown',
        'widget_context': details.context?.toString() ?? 'unknown',
      },
    );

    return ErrorPatternWidget(
      text: details.exception.toString(),
    );
  };
}
