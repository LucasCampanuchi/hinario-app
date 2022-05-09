import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/search_bible.store.dart';

// ignore: must_be_immutable
class SearchBox extends StatefulWidget {
  const SearchBox({Key? key}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final SearchBibleStore controller = GetIt.I.get<SearchBibleStore>();
  UnfocusDisposition disposition = UnfocusDisposition.scope;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.5,
                  color: Colors.black12,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: InkWell(
                      onTap: () => controller.setSearch(
                        controller,
                        context,
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.7,
                    child: TextField(
                      onEditingComplete: () => controller.setSearch(
                        controller,
                        context,
                      ),
                      controller: controller.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar...',
                        hintStyle: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
