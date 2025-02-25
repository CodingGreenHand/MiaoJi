import 'package:flutter/material.dart';
import 'package:miao_ji/services/ai_english_client.dart';
import 'package:flutter/services.dart';

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
          future: AiEnglishClient.generatePassageByWords(AiEnglishClient.words,wordNum), 
          builder: (context,snapshot){
            if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SingleChildScrollView(child: Text(snapshot.data!)),
                    ElevatedButton(
                      onPressed:()async {
                        try{
                          Clipboard.setData(ClipboardData(text: snapshot.data!));
                        }catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('复制失败')));
                        }
                      },
                      child: const Text('复制全文')
                    )
                  ],
                )
                );
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