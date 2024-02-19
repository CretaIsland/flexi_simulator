import 'package:flexi_simulator/communication/my_device_info.dart';

import 'data_io/host_manager.dart';
import 'package:hycop_light/hycop.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'model/host_model.dart';

//import 'model/host_model.dart';

void main() {
  setupLogger();
  Logger.root.level = Level.INFO;
  runApp(const FlexiApp());
}

class FlexiApp extends StatelessWidget {
  const FlexiApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexi Simulator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
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
      home: const FlexiHomePage(title: 'Flexi Simulator'),
    );
  }
}

class FlexiHomePage extends StatefulWidget {
  static HostManager hostManagerHolder = HostManager();

  const FlexiHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<FlexiHomePage> createState() => _FlexiHomePageState();
}

class _FlexiHomePageState extends State<FlexiHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // FlexiHomePage.hostManagerHolder.autoDiscovery.stopBroadcast();
      // FlexiHomePage.hostManagerHolder.autoDiscovery.startBroadcast();
      //_counter++;
      // This call to se
      //tState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  @override
  void initState() {
    super.initState();

    MyDeviceInfo.getDeviceName().then((hostName) {
      FlexiHomePage.hostManagerHolder.autoDiscovery.listenAndRespond(
          hostName: hostName,
          callback: (message) {
            _counter++;
            FlexiHomePage.hostManagerHolder.notify();
          });
      return null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    FlexiHomePage.hostManagerHolder.autoDiscovery.stopBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HostManager>.value(
          value: FlexiHomePage.hostManagerHolder,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the FlexiHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Consumer<HostManager>(builder: (context, hostManager, child) {
          return Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ping count = $_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'host count = ${hostManager.modelList.length}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                hostManager.modelList.isNotEmpty
                    ? ListView(
                        children: hostManager.modelList.map((ele) {
                          HostModel hostModel = ele as HostModel;
                          return Text(
                              '${hostModel.hostName}, ${hostModel.ip}, ${hostModel.isConnected}');
                        }).toList(),
                      )
                    : Text(
                        'no device found',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
