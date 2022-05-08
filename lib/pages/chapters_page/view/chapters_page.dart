import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../models/book.model.dart';
import '../components/button_chapter.dart';
import '../store/chapter.store.dart';

class ChaptersPage extends StatefulWidget {
  final BookModel book;
  const ChaptersPage({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  final controller = GetIt.I.get<ChapterStore>();

  @override
  void initState() {
    controller.list(widget.book);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name!),
        centerTitle: true,
      ),
      body: SizedBox(
        width: size.width,
        child: SingleChildScrollView(
          child: Observer(
            builder: (_) {
              return Column(
                children: [
                  Wrap(
                    children: [
                      for (int i = 1; i <= controller.qtdeChapters!; i++)
                        ButtonChapter(
                          text: i,
                          book: widget.book,
                          qtdeChapters: controller.qtdeChapters!,
                        )
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
