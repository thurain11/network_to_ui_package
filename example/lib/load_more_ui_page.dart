import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';
import 'package:network_to_ui_example/models/yangon_townships_ob.dart';

class LoadMoreUiPage extends StatefulWidget {
  const LoadMoreUiPage({super.key});

  @override
  State<LoadMoreUiPage> createState() => _LoadMoreUiPageState();
}

class _LoadMoreUiPageState extends State<LoadMoreUiPage> {
  //
  var refreshKey = GlobalKey<LoadMoreUiBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load More Paginate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshKey.currentState!.func();
            },
          ),
        ],
      ),
      // Type<TownshipsData> is factory type
      body: LoadMoreUiBuilder<TownshipsData>(
        key: refreshKey,
        url: 'https://upplus-mm.com/api/township',
        childWidget: (dynamic data, reload, bool? isList) {
          TownshipsData township = data;

          if (data == null) return const Text('No data');
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("${township.id} - ${township.name}"),
              ),
            ],
          );
        },
      ),
    );
  }
}
