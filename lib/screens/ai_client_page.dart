import 'package:flutter/material.dart';

class AiClientPage extends StatefulWidget {
  @override
  _AiClientPageState createState() => _AiClientPageState();
}

class _AiClientPageState extends State<AiClientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Client'),
      ),
      body: Center(
        child: Text('AI Client'),
      ),
    );
  }
}