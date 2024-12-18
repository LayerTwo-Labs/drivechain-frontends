import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
      ),
      body: Center(
        child: const Text(
          'Tools Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}