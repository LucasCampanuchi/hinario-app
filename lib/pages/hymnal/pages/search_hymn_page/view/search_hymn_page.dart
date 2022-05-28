import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/pages/hymnal/pages/search_hymn_page/components/card_text.dart';

import '../../../../../components/search.dart';
import '../../../../../models/hymn.model.dart';
import '../store/search_hymn.store.dart';

class SearchHymnPage extends StatelessWidget {
  const SearchHymnPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchHymnStore controller = GetIt.I.get<SearchHymnStore>();
    final AppBar appBar = AppBar(
      title: Text(
        'Buscar Hino',
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
            SearchBox(
              search: () => controller.setSearch(
                controller,
                context,
              ),
              text: controller.text,
            ),
            Observer(
              builder: (_) => SizedBox(
                height: height,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (controller.hymns != null)
                          for (HymnModel hymn in controller.hymns!)
                            CardText(
                              hymn: hymn,
                              controller: controller,
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
