import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/verses.store.dart';

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
              SizedBox(
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
              )
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
