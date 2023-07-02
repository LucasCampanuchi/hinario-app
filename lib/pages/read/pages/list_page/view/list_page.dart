import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hinario_flutter/pages/read/pages/list_page/store/list.store.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
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
        title: const Text('Livros'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Observer(builder: (_) {
        if (controller.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: controller.files.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                controller.files[index].name,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/read',
                  arguments: {
                    'file': controller.files[index],
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
