import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/models/hymn.model.dart';
import 'package:hinario_flutter/pages/hymnal/pages/hymn_view_page/store/hymv_view.store.dart';

import '../utils/test_number.dart';
import '../widgets/modal_menu.dart';

class HymnView extends StatefulWidget {
  final HymnModel hymn;

  const HymnView({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  State<HymnView> createState() => _HymnViewState();
}

class _HymnViewState extends State<HymnView> {
  HymnViewStore hymnViewStore = HymnViewStore();

  double _fontSize = 20;
  final double _baseFontSize = 20;
  double _fontScale = 1;
  double _baseFontScale = 1;

  @override
  void initState() {
    hymnViewStore.verifyIndice(widget.hymn.number);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () => modalMenu(
                    context,
                    hymnViewStore.indices,
                  ),
                  icon: const Icon(Icons.more_vert),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.hymn.name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onScaleStart: (ScaleStartDetails scaleStartDetails) {
              _baseFontScale = _fontScale;
            },
            onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
              // don't update the UI if the scale didn't change
              if (scaleUpdateDetails.scale == 1.0) {
                return;
              }
              setState(() {
                _fontScale =
                    (_baseFontScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
                _fontSize = _fontScale * _baseFontSize;
              });
            },
            child: Column(
              children: [
                for (String item in widget.hymn.text.split('\n\n'))
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: SizedBox(
                          width: size.width - 56,
                          child: Text(
                            (item),
                            style: GoogleFonts.roboto(
                                fontWeight: testNumber(item.split(' ')[0])
                                    ? FontWeight.w400
                                    : FontWeight.bold,
                                fontSize: _fontSize,
                                color: Colors.black45),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
