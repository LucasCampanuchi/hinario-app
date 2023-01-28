import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      width: 30,
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
                  PopupMenuButton(
                    position: PopupMenuPosition.under,
                    onSelected: (value) {
                      if (value == 1) {
                        Navigator.pushNamed(context, '/searchbible');
                      } else if (value == 2) {
                        Navigator.pushNamed(context, '/configuration');
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Pesquisa',
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          value: 1,
                        ),
                        /* PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tune,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Ajustes',
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          value: 2,
                        ), */
                      ];
                    },
                  ),
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
