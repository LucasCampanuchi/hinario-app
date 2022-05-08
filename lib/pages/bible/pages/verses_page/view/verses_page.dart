import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../../models/book.model.dart';
import '../../../../../models/verse.model.dart';
import '../components/chapter_title.dart';
import '../components/verse_appbar.dart';
import '../components/verse_text.dart';
import '../store/verses.store.dart';

class VersesPage extends StatefulWidget {
  final BookModel book;
  final int chapter;

  const VersesPage({
    Key? key,
    required this.book,
    required this.chapter,
  }) : super(key: key);

  @override
  State<VersesPage> createState() => _VersesPageState();
}

class _VersesPageState extends State<VersesPage> {
  final VersesStore controller = GetIt.I.get<VersesStore>();

  @override
  void initState() {
    controller.list(
      widget.book,
      widget.chapter,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    VerseAppBar appBar = VerseAppBar(
      appBar: AppBar(),
    );

    double heigth = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: SizedBox(
          height: heigth,
          child: Observer(
            builder: (_) {
              return PageView(
                onPageChanged: (value) {
                  controller.setChapter(value);
                },
                controller: controller.pageController,
                children: <Widget>[
                  for (List<VerseModel> list in controller.listVerses)
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChapterTitle(
                            text: (list[0].chapter).toString(),
                          ),
                          for (VerseModel verse in list)
                            VerseText(verse: verse),
                        ],
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
