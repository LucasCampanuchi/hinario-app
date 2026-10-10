import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

    // Este widget aparece NO LUGAR do pedaço que quebrou (pode ser só um
    // card, ou o meio de uma tela). Por isso não pode ser uma página inteira
    // com Scaffold/AppBar — isso gerava a tela "Erro" dentro de outra tela.
    return _InlineErrorWidget(message: details.exception.toString());
  };
}

class _InlineErrorWidget extends StatelessWidget {
  final String message;

  const _InlineErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
              const SizedBox(height: 8),
              const Text(
                'Algo deu errado ao mostrar esta parte.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
