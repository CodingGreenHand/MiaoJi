import 'package:flutter/material.dart';
import 'package:miao_ji/services/ai_english_client.dart';

class AiClientResultPage extends StatelessWidget{
  final int wordNum;

  const AiClientResultPage({super.key,required this.wordNum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 范文生成结果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child:FutureBuilder(
          future: AIEnglishClient.generatePassageByWords(AIEnglishClient.words,wordNum), 
          builder: (context,snapshot){
            if(snapshot.hasData){
              return Center(child: SingleChildScrollView(child: Text(snapshot.data!)),);
            }
            else if(snapshot.hasError){
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
        ),
      )
    );
  }
}