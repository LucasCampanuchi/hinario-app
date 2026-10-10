import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../models/cifra.dart';
import '../../../../../services/app_logger_service.dart';
import '../../../../../utils/cifra_title.dart';
import '../../../widgets/chord_sheet_view.dart';

const _primary = Color(0xFF3E5A86);

/// Mostra uma cifra: PDF (painel), foto (enviada pelo app) ou texto.
///
/// Importante: os callbacks do leitor de PDF NÃO fazem setState nesta tela.
/// Reconstruir a página inteira enquanto o SfPdfViewer ainda está montando
/// o layout causava "RenderBox was not laid out: RenderTransform".
/// O contador de páginas usa ValueNotifier e só redesenha o próprio texto.
class CifraViewPage extends StatefulWidget {
  final Cifra cifra;

  /// Barra opcional exibida embaixo da cifra (usada pela sala ao vivo).
  final Widget? bottomBar;

  /// Ações extras no AppBar (usadas pela sala ao vivo).
  final List<Widget> extraActions;

  /// Texto pequeno opcional acima do título (ex.: "AO VIVO").
  final String? overline;

  /// Camada opcional por cima do conteúdo (ex.: aviso de mensagem do chat).
  final Widget? overlay;

  /// Se a cifra ainda não está no aparelho, mostra direto desta URL
  /// (sala ao vivo: foto que alguém acabou de mandar aparece na hora).
  final String? remoteUrl;

  const CifraViewPage({
    Key? key,
    required this.cifra,
    this.bottomBar,
    this.extraActions = const [],
    this.overline,
    this.overlay,
    this.remoteUrl,
  }) : super(key: key);

  @override
  State<CifraViewPage> createState() => _CifraViewPageState();
}

class _CifraViewPageState extends State<CifraViewPage> {
  final ValueNotifier<int> _currentPage = ValueNotifier(1);
  final ValueNotifier<int> _totalPages = ValueNotifier(0);

  late Future<_FileCheck> _check;
  int _reloadToken = 0;

  /// O conteúdo (PDF/foto/texto) é montado UMA vez e reaproveitado.
  /// Assim a sala ao vivo pode redesenhar a barra/avisos a cada 2s sem
  /// recarregar o PDF.
  Widget? _cachedBody;
  int _cachedToken = -1;

  @override
  void initState() {
    super.initState();
    _check = _checkFile();
  }

  @override
  void didUpdateWidget(CifraViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cifra.id != widget.cifra.id ||
        oldWidget.cifra.localFilePath != widget.cifra.localFilePath) {
      _reload();
    }
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _totalPages.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _reloadToken++;
      _currentPage.value = 1;
      _totalPages.value = 0;
      _check = _checkFile();
    });
  }

  Future<_FileCheck> _checkFile() async {
    final path = widget.cifra.localFilePath;
    if (path == null && widget.remoteUrl != null) {
      return await _checkRemote(widget.remoteUrl!);
    }
    if (path == null) {
      return const _FileCheck.error('Esta cifra ainda não foi baixada.');
    }
    try {
      final file = File(path);
      if (!await file.exists()) {
        AppLoggerService.logError(
          'Arquivo de cifra não encontrado',
          metadata: {'cifra_id': widget.cifra.id, 'file_path': path},
        );
        return const _FileCheck.error('O arquivo não está no aparelho.');
      }
      if (await file.length() == 0) {
        return const _FileCheck.error('O arquivo baixado está vazio.');
      }
      String? text;
      if (widget.cifra.kind == 'text') {
        text = await file.readAsString();
      }
      return _FileCheck.ok(file, text);
    } catch (e) {
      AppLoggerService.logError(
        'Erro ao abrir cifra',
        metadata: {'cifra_id': widget.cifra.id, 'error': e.toString()},
      );
      return _FileCheck.error('Não foi possível abrir o arquivo.');
    }
  }

  Future<_FileCheck> _checkRemote(String url) async {
    if (widget.cifra.kind != 'text') return _FileCheck.remote(url, null);
    try {
      final response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          responseType: ResponseType.plain,
        ),
      ).get<String>(url);
      return _FileCheck.remote(url, response.data ?? '');
    } catch (_) {
      return const _FileCheck.error('Sem conexão para abrir esta cifra.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = CifraTitle.parse(widget.cifra.title);
    final details = [
      if (parsed.hymnRef != null) 'Hino ${parsed.hymnRef}',
      ...parsed.chips,
      if (parsed.status != null) parsed.status!,
      if (widget.cifra.tone != null) 'Tom ${widget.cifra.tone}',
    ].join(' · ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showDetails(parsed),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.overline != null)
                  Text(
                    widget.overline!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                Text(
                  parsed.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          ...widget.extraActions,
          if (widget.cifra.kind == 'pdf')
            ValueListenableBuilder<int>(
              valueListenable: _totalPages,
              builder: (context, total, _) => total > 1
                  ? ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, page, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '$page/$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'details') _showDetails(parsed);
              if (value == 'reload') _reload();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'details', child: Text('Detalhes da cifra')),
              PopupMenuItem(value: 'reload', child: Text('Recarregar')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: widget.bottomBar,
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<_FileCheck>(
              key: ValueKey(_reloadToken),
              future: _check,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_cachedBody != null && _cachedToken == _reloadToken) {
                  return _cachedBody!;
                }
                final body = _buildBody(snapshot.data!);
                _cachedBody = body;
                _cachedToken = _reloadToken;
                return body;
              },
            ),
          ),
          if (widget.overlay != null) widget.overlay!,
        ],
      ),
    );
  }

  Widget _buildBody(_FileCheck check) {
                if (check.error != null) return _error(check.error!);
                if (check.url != null) {
                  switch (widget.cifra.kind) {
                    case 'image':
                      return _NetworkImageBody(url: check.url!);
                    case 'text':
                      return ChordSheetView(
                        content: check.text ?? '',
                        originalKey: widget.cifra.tone,
                      );
                    default:
                      return ColoredBox(
                        color: const Color(0xFFF3F4F6),
                        child: SfPdfViewer.network(
                          check.url!,
                          pageLayoutMode: PdfPageLayoutMode.continuous,
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                          canShowPaginationDialog: false,
                          enableTextSelection: false,
                        ),
                      );
                  }
                }
                switch (widget.cifra.kind) {
                  case 'image':
                    return _ImageBody(file: check.file!);
                  case 'text':
                    return ChordSheetView(
                      content: check.text ?? '',
                      originalKey: widget.cifra.tone,
                    );
                  default:
                    return _PdfBody(
                      key: ValueKey('pdf-${widget.cifra.id}-$_reloadToken'),
                      file: check.file!,
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      onError: (message) => AppLoggerService.logError(
                        'Erro ao carregar PDF',
                        metadata: {
                          'cifra_id': widget.cifra.id,
                          'error': message,
                        },
                      ),
                    );
                }
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_download_outlined, size: 56, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Volte em Cifras e toque em Sincronizar para baixar de novo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(CifraTitle parsed) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parsed.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (parsed.hymnRef != null) Chip(label: Text('Hino ${parsed.hymnRef}')),
                  ...parsed.chips.map((c) => Chip(label: Text(c))),
                  if (parsed.status != null)
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16, color: Colors.green),
                      label: Text(parsed.status!),
                    ),
                  if (widget.cifra.tone != null) Chip(label: Text('Tom ${widget.cifra.tone}')),
                  if (parsed.seq != null) Chip(label: Text('Serviço de Música nº ${parsed.seq}')),
                  if (widget.cifra.authorName != null)
                    Chip(
                      avatar: const Icon(Icons.person_outline, size: 16),
                      label: Text('Enviada por ${widget.cifra.authorName}'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Título original',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              SelectableText(widget.cifra.title),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileCheck {
  final File? file;
  final String? text;
  final String? error;
  final String? url;

  const _FileCheck.ok(File this.file, this.text) : error = null, url = null;
  const _FileCheck.error(String this.error)
    : file = null,
      text = null,
      url = null;
  const _FileCheck.remote(String this.url, this.text)
    : file = null,
      error = null;
}

// -----------------------------------------------------------------------------

class _PdfBody extends StatefulWidget {
  final File file;
  final ValueNotifier<int> currentPage;
  final ValueNotifier<int> totalPages;
  final void Function(String message) onError;

  const _PdfBody({
    super.key,
    required this.file,
    required this.currentPage,
    required this.totalPages,
    required this.onError,
  });

  @override
  State<_PdfBody> createState() => _PdfBodyState();
}

class _PdfBodyState extends State<_PdfBody> {
  final PdfViewerController _controller = PdfViewerController();
  String? _error;

  /// Atualiza os contadores depois do frame atual, nunca durante o layout.
  void _later(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) fn();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Não foi possível abrir este PDF.\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: SfPdfViewer.file(
        widget.file,
        controller: _controller,
        // Rolagem contínua: mais estável que o modo "single" e melhor para
        // ler a cifra inteira descendo a tela.
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
        enableDoubleTapZooming: true,
        enableTextSelection: false,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        pageSpacing: 6,
        onDocumentLoaded: (details) {
          final count = details.document.pages.count;
          _later(() => widget.totalPages.value = count);
        },
        onPageChanged: (details) {
          final page = details.newPageNumber;
          _later(() => widget.currentPage.value = page);
        },
        onDocumentLoadFailed: (details) {
          widget.onError(details.description);
          _later(() => setState(() => _error = details.description));
        },
      ),
    );
  }
}

class _ImageBody extends StatelessWidget {
  final File file;

  const _ImageBody({required this.file});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111827),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 6,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Não foi possível abrir a foto.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkImageBody extends StatelessWidget {
  final String url;

  const _NetworkImageBody({required this.url});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111827),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 6,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            progressIndicatorBuilder: (context, _, progress) => Center(
              child: CircularProgressIndicator(
                value: progress.progress,
                color: Colors.white,
              ),
            ),
            errorWidget: (context, _, __) => const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Não foi possível carregar a foto. Verifique a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
