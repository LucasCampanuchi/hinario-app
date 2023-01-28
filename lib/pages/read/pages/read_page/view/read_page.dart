import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/pages/read/pages/read_page/store/read.store.dart';
import 'package:hinario_flutter/services/supabase.service.dart';
import 'package:supabase/supabase.dart';

class ReadPage extends StatefulWidget {
  final FileObject file;
  const ReadPage({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  final ReadStore controller = ReadStore();
  final SupabaseService supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    controller.setFile(
      supabaseService.getPublicUrl(
        widget.file.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name.replaceAll('.pdf', '')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Observer(builder: (_) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.isError || controller.file == null) {
          return RefreshIndicator(
            onRefresh: () async => controller.setFile(
              supabaseService.getPublicUrl(widget.file.name),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.4,
                  bottom: MediaQuery.of(context).size.height * 0.5,
                ),
                child: const Center(
                  child: Text(
                    'Erro ao carregar o pdf, tente novamente mais tarde.',
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: PDFView(
                filePath: controller.file!.path,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: true,
                pageFling: true,
                onRender: (int? pages) {
                  controller.pages = pages ?? 0;
                },
                onPageError: (int? page, dynamic error) {},
                onViewCreated: (PDFViewController p) {
                  controller.setPdfViewController(p);
                },
                onPageChanged: (int? page, int? total) {
                  controller.currentPage = page ?? 0;
                },
              ),
            ),
            SizedBox(
              height: 75,
              child: Column(
                children: [
                  if (controller.pages != 0) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      child: Text(
                        '${(controller.currentPage + 1)}/${controller.pages}',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Slider(
                      value: controller.currentPage.toDouble(),
                      min: 0,
                      max: (controller.pages - 1).toDouble(),
                      divisions: (controller.pages - 1),
                      label: (controller.currentPage + 1).toString(),
                      onChanged: (double value) {
                        controller.setPage(
                          value.toInt(),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
