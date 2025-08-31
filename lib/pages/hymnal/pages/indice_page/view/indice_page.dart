import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hinario_flutter/models/image.model.dart';

import '../../hymn_view_page/store/hymv_view.store.dart';

class IndicePage extends StatefulWidget {
  final String hymn;

  const IndicePage({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  State<IndicePage> createState() => _IndicePageState();
}

class _IndicePageState extends State<IndicePage> {
  HymnViewStore hymnViewStore = HymnViewStore();

  @override
  void initState() {
    hymnViewStore.verifyIndice(widget.hymn);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Índice'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Observer(builder: (_) {
        if (hymnViewStore.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: hymnViewStore.indices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                hymnViewStore.indices[index]['nome_formatado'].toString(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/read_image',
                  arguments: {
                    'image': ImageModel(
                      path: hymnViewStore.indices[index]['url'],
                      fromAssets: false,
                    ),
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
