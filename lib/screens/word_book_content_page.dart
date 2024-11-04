import 'package:flutter/material.dart';

class WordBookContent extends StatefulWidget {
  const WordBookContent({super.key});

  @override
  WordBookContentState createState() => WordBookContentState();
}

class WordBookContentState extends State<WordBookContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('单词本单词'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body:Column(children: [
        Text('单词本'),
      ],)
    );
  }
}