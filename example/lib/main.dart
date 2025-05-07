import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';

import 'factory_manager/factory_manager.dart';
import 'models/user_ob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageInterface storage = await initializeNetwork();
  FactoryManager.setupFactories();

  DioBaseNetworkConfig().updateConfig(
    nowVersionIos: "1.0.0",
    nowVersionAndroid: "1.0.0",
    additionalHeaders: {
      "Content-Type": "application/json",
    },
    authorizationToken: await storage.getString("token"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var singleKey = GlobalKey<NetWorkToUiBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NetWorkToUiBuilder<UserOb>(
              key: singleKey,
              url: "https://jsonplaceholder.typicode.com/todos/1",
              widget: (a, b) {
                debugPrint(a.runtimeType.toString());
                UserOb userOb = a;
                return Text("${userOb.title}");
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  singleKey.currentState!.blocFunc();
                },
                child: const Text('load'))
          ],
        ),
      ),
    );
  }
}
