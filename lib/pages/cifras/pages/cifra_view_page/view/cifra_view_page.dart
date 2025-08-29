import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/app_logger_service.dart';

class CifraViewPage extends StatefulWidget {
  final Cifra cifra;

  const CifraViewPage({Key? key, required this.cifra}) : super(key: key);

  @override
  State<CifraViewPage> createState() => _CifraViewPageState();
}

class _CifraViewPageState extends State<CifraViewPage> {
  String? errorMessage;
  bool isLoading = true;
  bool fileExists = false;
  int? fileSize;

  @override
  void initState() {
    super.initState();
    print('[CIFRA_VIEW] initState chamado para cifra: ${widget.cifra.title}');
    print(
        '[CIFRA_VIEW] Dados da cifra: ID=${widget.cifra.id}, localFilePath=${widget.cifra.localFilePath}');

    AppLoggerService.logInfo(
      'CifraViewPage inicializada',
      metadata: {
        'cifra_id': widget.cifra.id,
        'cifra_title': widget.cifra.title,
        'local_file_path': widget.cifra.localFilePath ?? 'null',
      },
    );

    _checkFile();
  }

  @override
  void dispose() {
    print('[CIFRA_VIEW] dispose chamado para cifra: ${widget.cifra.title}');
    AppLoggerService.logInfo(
      'CifraViewPage disposed',
      metadata: {
        'cifra_id': widget.cifra.id,
        'cifra_title': widget.cifra.title,
      },
    );
    super.dispose();
  }

  @override
  void didUpdateWidget(CifraViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[CIFRA_VIEW] didUpdateWidget chamado');
    print('[CIFRA_VIEW] - Old cifra: ${oldWidget.cifra.title}');
    print('[CIFRA_VIEW] - New cifra: ${widget.cifra.title}');

    if (oldWidget.cifra.id != widget.cifra.id ||
        oldWidget.cifra.localFilePath != widget.cifra.localFilePath) {
      print('[CIFRA_VIEW] Cifra mudou, recarregando arquivo');
      AppLoggerService.logInfo(
        'Cifra atualizada, recarregando arquivo',
        metadata: {
          'old_cifra_id': oldWidget.cifra.id,
          'new_cifra_id': widget.cifra.id,
          'old_file_path': oldWidget.cifra.localFilePath ?? 'null',
          'new_file_path': widget.cifra.localFilePath ?? 'null',
        },
      );

      setState(() {
        isLoading = true;
        errorMessage = null;
        fileExists = false;
        fileSize = null;
      });
      _checkFile();
    }
  }

  void _logCurrentState(String context) {
    print('[CIFRA_VIEW] Estado atual ($context):');
    print('[CIFRA_VIEW] - isLoading: $isLoading');
    print('[CIFRA_VIEW] - fileExists: $fileExists');
    print('[CIFRA_VIEW] - errorMessage: $errorMessage');
    print('[CIFRA_VIEW] - fileSize: $fileSize');
    print('[CIFRA_VIEW] - mounted: $mounted');
    print('[CIFRA_VIEW] - localFilePath: ${widget.cifra.localFilePath}');

    AppLoggerService.logInfo(
      'Estado atual da CifraViewPage',
      metadata: {
        'context': context,
        'cifra_id': widget.cifra.id,
        'is_loading': isLoading,
        'file_exists': fileExists,
        'error_message': errorMessage ?? 'null',
        'file_size': fileSize?.toString() ?? 'null',
        'widget_mounted': mounted,
        'local_file_path': widget.cifra.localFilePath ?? 'null',
      },
    );
  }

  Future<void> _checkFile() async {
    _logCurrentState('início de _checkFile');

    try {
      print(
          '[CIFRA_VIEW] Verificando arquivo para cifra ${widget.cifra.id}: ${widget.cifra.title}');
      print('[CIFRA_VIEW] Caminho do arquivo: ${widget.cifra.localFilePath}');

      if (widget.cifra.localFilePath == null) {
        errorMessage = 'Caminho do arquivo não definido';
        await AppLoggerService.logWarning(
          'Cifra sem caminho de arquivo definido',
          metadata: {
            'cifra_id': widget.cifra.id,
            'cifra_title': widget.cifra.title,
          },
        );
      } else {
        final file = File(widget.cifra.localFilePath!);
        fileExists = await file.exists();

        if (fileExists) {
          fileSize = await file.length();
          print('[CIFRA_VIEW] Arquivo encontrado. Tamanho: $fileSize bytes');

          if (fileSize == 0) {
            errorMessage = 'Arquivo está vazio';
            await AppLoggerService.logError(
              'Arquivo de cifra está vazio',
              metadata: {
                'cifra_id': widget.cifra.id,
                'cifra_title': widget.cifra.title,
                'file_path': widget.cifra.localFilePath!,
                'file_size': fileSize!,
              },
            );
          }
        } else {
          errorMessage = 'Arquivo não encontrado no dispositivo';
          print(
              '[CIFRA_VIEW] Arquivo não encontrado: ${widget.cifra.localFilePath}');

          await AppLoggerService.logError(
            'Arquivo de cifra não encontrado',
            metadata: {
              'cifra_id': widget.cifra.id,
              'cifra_title': widget.cifra.title,
              'file_path': widget.cifra.localFilePath!,
            },
          );
        }
      }
    } catch (e, stackTrace) {
      errorMessage = 'Erro ao verificar arquivo: $e';
      print('[CIFRA_VIEW ERROR] Erro ao verificar arquivo: $e');

      await AppLoggerService.logError(
        'Erro ao verificar arquivo de cifra',
        metadata: {
          'cifra_id': widget.cifra.id,
          'cifra_title': widget.cifra.title,
          'file_path': widget.cifra.localFilePath ?? 'null',
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
    } finally {
      print('[CIFRA_VIEW] Finalizando _checkFile:');
      print('[CIFRA_VIEW] - isLoading: $isLoading -> false');
      print('[CIFRA_VIEW] - fileExists: $fileExists');
      print('[CIFRA_VIEW] - errorMessage: $errorMessage');
      print('[CIFRA_VIEW] - fileSize: $fileSize');
      print('[CIFRA_VIEW] - mounted: $mounted');

      await AppLoggerService.logInfo(
        'Verificação de arquivo concluída',
        metadata: {
          'cifra_id': widget.cifra.id,
          'cifra_title': widget.cifra.title,
          'file_exists': fileExists,
          'error_message': errorMessage ?? 'null',
          'file_size': fileSize?.toString() ?? 'null',
          'widget_mounted': mounted,
        },
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('[CIFRA_VIEW] setState chamado - isLoading agora é false');
      } else {
        print('[CIFRA_VIEW] Widget não está mounted, setState não foi chamado');
      }

      _logCurrentState('final de _checkFile');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logCurrentState('build');

    print('[CIFRA_VIEW] build() chamado:');
    print('[CIFRA_VIEW] - isLoading: $isLoading');
    print('[CIFRA_VIEW] - fileExists: $fileExists');
    print('[CIFRA_VIEW] - errorMessage: $errorMessage');
    print('[CIFRA_VIEW] - localFilePath: ${widget.cifra.localFilePath}');

    // Log das condições para determinar qual widget será exibido
    final showLoading = isLoading;
    final showPDF = fileExists && errorMessage == null;
    final showError = !fileExists || errorMessage != null;

    print('[CIFRA_VIEW] Decisões de renderização:');
    print('[CIFRA_VIEW] - Mostrar loading: $showLoading');
    print('[CIFRA_VIEW] - Mostrar PDF: $showPDF');
    print('[CIFRA_VIEW] - Mostrar erro: $showError');

    AppLoggerService.logInfo(
      'CifraViewPage build executado',
      metadata: {
        'cifra_id': widget.cifra.id,
        'is_loading': isLoading,
        'file_exists': fileExists,
        'error_message': errorMessage ?? 'null',
        'show_loading': showLoading,
        'show_pdf': showPDF,
        'show_error': showError,
      },
    );

    _debugScaffoldContent();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.cifra.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : fileExists && errorMessage == null
              ? _buildPDFWidget()
              : _buildErrorWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    print('[CIFRA_VIEW] Renderizando widget de loading');
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF3E5A86),
          ),
          SizedBox(height: 16),
          Text('Verificando arquivo...'),
        ],
      ),
    );
  }

  Widget _buildPDFWidget() {
    print(
        '[CIFRA_VIEW] Renderizando PDFView para arquivo: ${widget.cifra.localFilePath}');

    AppLoggerService.logInfo(
      'Iniciando renderização do PDF',
      metadata: {
        'cifra_id': widget.cifra.id,
        'file_path': widget.cifra.localFilePath!,
        'file_size': fileSize?.toString() ?? 'unknown',
      },
    );

    return PDFView(
      filePath: widget.cifra.localFilePath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: false,
      onRender: (pages) {
        print('[CIFRA_VIEW] PDF renderizado com $pages páginas');
        AppLoggerService.logInfo(
          'PDF renderizado com sucesso',
          metadata: {
            'cifra_id': widget.cifra.id,
            'total_pages': pages.toString(),
            'file_path': widget.cifra.localFilePath!,
          },
        );
      },
      onViewCreated: (PDFViewController controller) {
        print('[CIFRA_VIEW] PDFViewController criado');
        AppLoggerService.logInfo(
          'PDFViewController criado',
          metadata: {
            'cifra_id': widget.cifra.id,
            'file_path': widget.cifra.localFilePath!,
          },
        );
      },
      onError: (error) {
        print('[CIFRA_VIEW ERROR] Erro no PDFView: $error');
        AppLoggerService.logError(
          'Erro ao carregar PDF',
          metadata: {
            'cifra_id': widget.cifra.id,
            'cifra_title': widget.cifra.title,
            'file_path': widget.cifra.localFilePath!,
            'file_size': fileSize?.toString() ?? 'unknown',
            'pdf_error': error.toString(),
          },
        );
        setState(() {
          errorMessage = 'Erro ao carregar PDF: $error';
        });
        print('[CIFRA_VIEW] setState chamado após erro no PDF');
        _logCurrentState('após erro no PDF');
      },
      onPageError: (page, error) {
        print('[CIFRA_VIEW ERROR] Erro na página $page: $error');
        AppLoggerService.logError(
          'Erro ao carregar página do PDF',
          metadata: {
            'cifra_id': widget.cifra.id,
            'cifra_title': widget.cifra.title,
            'file_path': widget.cifra.localFilePath!,
            'page': page.toString(),
            'page_error': error.toString(),
          },
        );
      },
      onPageChanged: (int? page, int? total) {
        print('[CIFRA_VIEW] Página alterada: $page de $total');
      },
    );
  }

  Widget _buildErrorWidget() {
    print('[CIFRA_VIEW] Renderizando widget de erro: $errorMessage');

    AppLoggerService.logWarning(
      'Exibindo tela de erro',
      metadata: {
        'cifra_id': widget.cifra.id,
        'error_message': errorMessage ?? 'Arquivo não encontrado',
        'file_exists': fileExists,
        'file_path': widget.cifra.localFilePath ?? 'null',
      },
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Arquivo não disponível',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Arquivo não encontrado no dispositivo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente sincronizar novamente para baixar o arquivo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.cifra.localFilePath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Caminho: ${widget.cifra.localFilePath}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (fileSize != null)
                      Text(
                        'Tamanho: $fileSize bytes',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _debugScaffoldContent() {
    print('[CIFRA_VIEW] Debug do conteúdo do Scaffold:');

    if (isLoading) {
      print('[CIFRA_VIEW] - Deveria mostrar loading widget');
    } else if (fileExists && errorMessage == null) {
      print('[CIFRA_VIEW] - Deveria mostrar PDFView');
      print('[CIFRA_VIEW] - Arquivo existe: $fileExists');
      print('[CIFRA_VIEW] - Sem mensagem de erro: ${errorMessage == null}');
      print(
          '[CIFRA_VIEW] - Caminho válido: ${widget.cifra.localFilePath != null}');
    } else {
      print('[CIFRA_VIEW] - Deveria mostrar widget de erro');
      print('[CIFRA_VIEW] - Arquivo não existe: ${!fileExists}');
      print('[CIFRA_VIEW] - Tem mensagem de erro: ${errorMessage != null}');
      print('[CIFRA_VIEW] - Mensagem: $errorMessage');
    }

    // Verificar se o widget está em uma árvore válida
    try {
      Scaffold.of(context);
      print('[CIFRA_VIEW] - Scaffold encontrado com sucesso');
    } catch (e) {
      print('[CIFRA_VIEW] - Erro ao acessar Scaffold: $e');
    }

    // Verificar MediaQuery
    try {
      final mediaQuery = MediaQuery.of(context);
      print('[CIFRA_VIEW] - MediaQuery size: ${mediaQuery.size}');
      print('[CIFRA_VIEW] - MediaQuery padding: ${mediaQuery.padding}');
    } catch (e) {
      print('[CIFRA_VIEW] - Erro ao acessar MediaQuery: $e');
    }
  }
}
