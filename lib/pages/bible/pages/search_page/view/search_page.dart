import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/pages/bible/pages/search_page/components/card_text.dart';
import 'package:hinario_flutter/pages/bible/pages/search_page/store/search_bible.store.dart';

import '../components/search.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchBibleStore controller = GetIt.I.get<SearchBibleStore>();
    final AppBar appBar = AppBar(
      title: Text(
        'Buscar',
        style: GoogleFonts.roboto(
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );

    final double height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        60;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBox(),
            Observer(
              builder: (_) => SizedBox(
                height: height,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (controller.listVerses != null)
                          ...controller.listVerses!.map(
                            (e) => CardText(verse: e),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
