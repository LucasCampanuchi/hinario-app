import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/new_hymn.store.dart';

class NewHymnPage extends StatefulWidget {
  const NewHymnPage({Key? key}) : super(key: key);

  @override
  State<NewHymnPage> createState() => _NewHymnPageState();
}

class _NewHymnPageState extends State<NewHymnPage> {
  final NewHymnStore controller = GetIt.I.get<NewHymnStore>();

  @override
  void initState() {
    controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hinos Novos',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: size.width,
                child: Center(
                  child: Wrap(
                    children: [
                      ...controller.hymns.map(
                        (h) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              'newhymnview',
                              arguments: {
                                'hymn': h,
                              },
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: size.width * 0.40,
                              height: 60,
                              child: Center(
                                child: Text(
                                  h.name,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black45,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
