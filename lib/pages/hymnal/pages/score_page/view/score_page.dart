import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/pages/hymnal/pages/score_page/components/image_viewer.dart';

import '../../../../../models/hymn.model.dart';

class ScorePage extends StatelessWidget {
  final HymnModel hymn;

  const ScorePage({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
      title: Text(
        hymn.name,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );

    final double height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: SizedBox(
        height: height,
        child: ImageViewer(
          hymn: hymn,
        ),
      ),
    );
  }
}
