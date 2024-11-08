import 'package:flutter/material.dart';
import 'package:miao_ji/models/word_book.dart';

class WordBookContentPage extends StatefulWidget {
  final WordBook wordBook;

  const WordBookContentPage({super.key,required this.wordBook});

  @override
  WordBookContentPageState createState() => WordBookContentPageState();
}

class WordBookContentPageState extends State<WordBookContentPage> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('单词本：${widget.wordBook.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body:
      Padding(padding: const EdgeInsets.all(16),
        child:Column(children: [
            WordBookContentPageInputComponent(wordBook: widget.wordBook,onWordChanged: () => setState((){}),),
            FutureBuilder(
              future: widget.wordBook.getWords(),
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                  return WordBookContentPageComponent(words: snapshot.data!,wordBook:widget.wordBook,onWordChanged: () => setState((){}));
                }
                else if(snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }
                else{
                  return const Center(child: CircularProgressIndicator());
                }
              }
            )
        ],)
      )
    );
  }
}

class WordBookContentPageComponent extends StatefulWidget{
  final List<String> words;
  final WordBook wordBook;
  final VoidCallback onWordChanged;

  const WordBookContentPageComponent({super.key,required this.words,required this.wordBook,required this.onWordChanged});

  @override
  WordBookContentPageComponentState createState() => WordBookContentPageComponentState();
}

class WordBookContentPageComponentState extends State<WordBookContentPageComponent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListView.builder(
      itemCount: widget.words.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.words[index]),
          trailing: IconButton(icon: const Icon(Icons.delete),onPressed: () async{
            await widget.wordBook.deleteWord(widget.words[index]);
            widget.onWordChanged();
            setState((){});
          }),
        );
      }
    )
    ,);
  }
  
}

class WordBookContentPageInputComponent extends StatefulWidget{
  final WordBook wordBook;
  final VoidCallback onWordChanged;

  const WordBookContentPageInputComponent({super.key,required this.wordBook,required this.onWordChanged});

  @override
  WordBookContentPageInputComponentState createState() => WordBookContentPageInputComponentState();
}

class WordBookContentPageInputComponentState extends State<WordBookContentPageInputComponent> {
  bool isAddingWord = true;

  @override
  Widget build(BuildContext context) {
    return  Row(children: [
      IconButton(icon: const Icon(Icons.autorenew),onPressed: () {
        isAddingWord = !isAddingWord;
        setState((){});
      }),
      Expanded(child:TextField(
        decoration: InputDecoration(
          labelText: isAddingWord? '添加单词' : '删除单词'
        ),
        onSubmitted: (value) async{
          if(isAddingWord){
            await widget.wordBook.addWord(value);
          }
          else{
            await widget.wordBook.deleteWord(value);
          }
          widget.onWordChanged();
          setState((){});
        },
      ))
    ],);
  }
}