import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hinario_flutter/pages/bible/pages/verses_page/widgets/modal_menu.dart';

import '../store/verses.store.dart';
import '../widgets/modal_font_size.dart';
import '../widgets/modal_top.dart';

class VerseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const VerseAppBar({
    Key? key,
    required this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VersesStore controller = GetIt.I.get<VersesStore>();

    return AppBar(
      title: Observer(
        builder: (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (controller.book != null)
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/books'),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          controller.book!.name!,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 20,
                    ),
                    child: Container(
                      height: 25,
                      width: 1,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () => modalChapter(
                      context,
                      controller,
                    ),
                    child: SizedBox(
                      height: 50,
                      width: 40,
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: controller.pageAppBarController,
                        children: [
                          for (var i = 1; i <= controller.chapters; i++)
                            Center(
                              child: Text(
                                '$i',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => showModalFontSize(
                      context,
                    ),
                    child: const Icon(
                      Icons.format_size_rounded,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () => modalMenu(context, controller),
                    icon: const Icon(Icons.more_vert),
                  )
                ],
              ),
            ],
          );
        },
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
