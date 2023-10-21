import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:sidesail/console.dart';
import 'package:sidesail/deposit_address.dart';
import 'package:sidesail/rpc.dart';

void main() {
  runApp(const MyApp());
}

const appName = 'SideSail';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _depositAddress = "none";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      body: Center(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(child: RpcWidget()),
            ],
          ),
          Row(
            children: [
              DepositAddress(_depositAddress),
              ElevatedButton(
                  onPressed: () async {
                    var address = await generateDepositAddress();
                    setState(() {
                      _depositAddress = address;
                    });
                  },
                  child: Text("Generate"))
            ],
          )
        ],
      )),
    );
  }
}
