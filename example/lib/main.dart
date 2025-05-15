import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';
import 'package:network_to_ui_example/load_more_ui_page.dart';

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
                child: const Text('load')),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const DataRequestScreen();
                  }));
                },
                child: const Text('Data Request Screen')),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoadMoreUiPage();
                  }));
                },
                child: const Text('Load More Page')),
          ],
        ),
      ),
    );
  }
}

// Data Request Widget
class DataRequestScreen extends StatelessWidget {
  const DataRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: DataRequestWidget(
                  url: 'https://api.example.com/login',
                  text: 'Login',
                  isShowDialog: true,
                  //RequestType default is post
                  // requestType: ReqType.get,
                  loadingWidget: const CircularProgressIndicator(),
                  // onPress: () {
                  //   return {
                  //     'email': 'user@example.com',
                  //     'password': 'password123',
                  //   };
                  // },
                  onAsyncPress: () async {
                    return {
                      'email': 'user@example.com',
                      'password': 'password123',
                    };
                  },
                  // Success Function
                  successFunc: (ResponseOb resp) {
                    Map<String, dynamic> dataMap = resp.data['data'];

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful')),
                    );
                  },
                  // Validation Function
                  validFunc: (ResponseOb resp) {
                    Map<String, dynamic> errors = resp.data['errors'];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errors.toString())),
                    );
                  },
                  //// Error Function
                  errorFunc: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
