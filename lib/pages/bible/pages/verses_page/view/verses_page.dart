import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../models/book.model.dart';
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
      context,
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
                  controller.savePage(
                    value + 1,
                  );
                },
                controller: controller.pageController,
                children: <Widget>[
                  for (int i = 0; i < controller.listVerses.length; i++)
                    ScrollablePositionedList.builder(
                      itemCount: controller.listVerses[i].length,
                      itemBuilder: (c, index) => VerseText(
                        verse: controller.listVerses[i][index],
                      ),
                      itemScrollController: controller.listItemController[i],
                      itemPositionsListener:
                          controller.listItemPositionsListener[i],
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
