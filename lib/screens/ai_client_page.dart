import 'package:flutter/material.dart';
import 'package:miao_ji/screens/ai_client_result_page.dart';
import 'package:miao_ji/services/ai_english_client.dart';

class AiClientPage extends StatefulWidget {
  const AiClientPage({super.key});

  @override
  AiClientPageState createState() => AiClientPageState();
}

class AiClientPageState extends State<AiClientPage> {
  int wordNum = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI生成范文'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(padding: const EdgeInsets.all(16), 
        child: Column(children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: (){
                  if(AIEnglishClient.words.isEmpty){
                    ScaffoldMessenger.of(context)
                     ..removeCurrentSnackBar()
                     ..showSnackBar(const SnackBar(content: Text('请添加单词')));
                  }
                  else{
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AiClientResultPage(wordNum: wordNum)));
                  }
                }, 
                child: const Text('使用以下单词生成文章')
              ),
              const SizedBox(width: 16),
              Expanded(child: TextField(
                decoration: InputDecoration(
                  labelText: '文章词数:$wordNum',
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  int num = 100;
                  try{
                    num = int.parse(value);
                    if(num < 100) throw Exception('词数不能少于100');
                    if(num > 2000) throw Exception('词数不能多于2000');
                    wordNum = num;
                    setState(() {});
                  }
                  catch(e){
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),)
            ]
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: '添加用于生成文章的单词',
            ),
            onSubmitted: (String value){
              AIEnglishClient.addWord(value);
              setState(() {});
            },
          ),
          Expanded(child:ListView.builder(
            itemCount: AIEnglishClient.words.length,
            itemBuilder: (context, index){
              return ListTile(
                title: Text(AIEnglishClient.words[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    AIEnglishClient.deleteWord(AIEnglishClient.words[index]);
                    setState(() {});
                  },
                ),
              );
            },
          ))
        ],)
      ),
    );
  }
}