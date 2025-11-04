import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/cifras_web_service.dart';
import '../../../../../services/app_logger_service.dart';

class CifraWebViewPage extends StatefulWidget {
  final int cifraId;

  const CifraWebViewPage({Key? key, required this.cifraId}) : super(key: key);

  @override
  State<CifraWebViewPage> createState() => _CifraWebViewPageState();
}

class _CifraWebViewPageState extends State<CifraWebViewPage> {
  final CifrasWebService _webService = CifrasWebService();
  final PdfViewerController _pdfController = PdfViewerController();
  Cifra? cifra;
  bool isLoading = true;
  String? errorMessage;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _loadCifra();
  }

  Future<void> _loadCifra() async {
    try {
      print('[CIFRA_WEB_VIEW] Carregando cifra ${widget.cifraId}');
      final loadedCifra = await _webService.getCifraById(widget.cifraId);

      if (mounted) {
        setState(() {
          cifra = loadedCifra;
          isLoading = false;
        });
      }

      print('[CIFRA_WEB_VIEW] Cifra carregada: ${loadedCifra.title}');
      print('[CIFRA_WEB_VIEW] URL do arquivo: ${loadedCifra.file?.url}');
    } catch (e, stackTrace) {
      print('[CIFRA_WEB_VIEW ERROR] Erro ao carregar cifra: $e');

      await AppLoggerService.logError('Erro ao carregar cifra web', metadata: {
        'cifra_id': widget.cifraId,
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      });

      if (mounted) {
        setState(() {
          errorMessage = 'Erro ao carregar cifra: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          cifra?.title ?? 'Carregando...',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5A86),
        elevation: 0,
        leading: kIsWeb
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              )
            : null,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF3E5A86),
                  ),
                  SizedBox(height: 16),
                  Text('Carregando cifra...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Erro ao carregar cifra',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _loadCifra();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E5A86),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : cifra?.file?.url != null
                  ? Stack(
                      children: [
                        PdfViewer.uri(
                          Uri.parse(cifra!.file!.url),
                          controller: _pdfController,
                          params: const PdfViewerParams(
                            maxScale: 3.0,
                            minScale: 0.5,
                          ),
                        ),
                        if (kIsWeb ||
                            Theme.of(context).platform ==
                                TargetPlatform.windows ||
                            Theme.of(context).platform ==
                                TargetPlatform.macOS ||
                            Theme.of(context).platform == TargetPlatform.linux)
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _pdfController.zoomDown();
                                        setState(() {
                                          _zoomLevel = (_zoomLevel - 0.2)
                                              .clamp(0.5, 3.0);
                                        });
                                      },
                                      icon: const Icon(Icons.zoom_out),
                                      tooltip: 'Diminuir zoom',
                                    ),
                                    Text(
                                      '${(_zoomLevel * 100).round()}%',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _pdfController.zoomUp();
                                        setState(() {
                                          _zoomLevel = (_zoomLevel + 0.2)
                                              .clamp(0.5, 3.0);
                                        });
                                      },
                                      icon: const Icon(Icons.zoom_in),
                                      tooltip: 'Aumentar zoom',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
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
                              'Esta cifra não possui arquivo PDF disponível',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
