import 'package:flutter/material.dart';
import 'package:miao_ji/services/dictionary.dart';
import 'package:miao_ji/services/ai_english_client.dart';

class WordQueryResultPage extends StatelessWidget {
  final String word;

  const WordQueryResultPage({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('单词释义'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: FutureBuilder(
            future: LocalDictionary.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return WordQueryResultPageBody(
                    word: word, dictionary: snapshot.data!);
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class WordQueryResultPageBody extends StatefulWidget {
  final String word;
  final Dictionary dictionary;
  final AIEnglishClient aiEnglishClient = AIEnglishClient.getInstance();
  WordQueryResultPageBody(
      {super.key, required this.word, required this.dictionary});

  @override
  State<WordQueryResultPageBody> createState() =>
      WordQueryResultPageBodyState();
}

class WordQueryResultPageBodyState extends State<WordQueryResultPageBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Text(
            widget.word,
            textScaler: const TextScaler.linear(2),
          ),
          const Divider(height: 10),
          const Text(
            '本地词典释义',
            textScaler: TextScaler.linear(1.5),
          ),
          Text(widget.dictionary.query(widget.word)),
          const Divider(height: 10),
          const Text(
            'AI英语释义',
            textScaler: TextScaler.linear(1.5),
          ),
          FutureBuilder(
              future: AIEnglishClient.explainWord(widget.word),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          const Divider(height: 10),
          const Text(
            'AI例句',
            textScaler: TextScaler.linear(1.5),
          ),
          FutureBuilder(
              future: AIEnglishClient.generateSentence(widget.word),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ]));
  }
}
