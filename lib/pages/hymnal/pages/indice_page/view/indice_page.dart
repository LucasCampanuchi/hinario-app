import 'package:flutter/material.dart';
import 'package:hinario_flutter/models/image.model.dart';
import 'package:hinario_flutter/pages/read/pages/list_page/store/list.store.dart';

class IndicePage extends StatefulWidget {
  final List<String> hymns;

  const IndicePage({
    Key? key,
    required this.hymns,
  }) : super(key: key);

  @override
  State<IndicePage> createState() => _IndicePageState();
}

class _IndicePageState extends State<IndicePage> {
  ListStore controller = ListStore();

  @override
  void initState() {
    controller.listFiles();

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
      body: ListView.builder(
        itemCount: widget.hymns.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              widget.hymns[index],
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
                    path: 'assets/images/${widget.hymns[index]}.jpg',
                    fromAssets: true,
                  ),
                },
              );
            },
          );
        },
      ),
    );
  }
}
