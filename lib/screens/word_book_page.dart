import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:miao_ji/screens/word_book_content_page.dart';
import 'package:miao_ji/models/word_book.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'dart:io';

class WordBookPage extends StatefulWidget {
  const WordBookPage({super.key});

  @override
  WordBookPageState createState() => WordBookPageState();
}

class WordBookPageState extends State<WordBookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('单词本管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body:FutureBuilder(
        future: WordBookManager.getInstance(), 
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
            return WordBookComponent(wordBookManager: snapshot.data!);
          }
          else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        }
      )
    );
  }
}

class WordBookComponent extends StatefulWidget {
  final WordBookManager wordBookManager;

  const WordBookComponent({super.key,required this.wordBookManager});

  @override
  WordBookComponentState createState() => WordBookComponentState();
}

class WordBookComponentState extends State<WordBookComponent> {
  @override
  Widget build(BuildContext context){
    return Center(
      child:Column(children: [
        ElevatedButton(
          child: const Text('添加单词本'),
          onPressed: () async {
            showDialog(
              context: context, 
              builder: (context){
                return SimpleDialog(
                  title: const Text('添加单词本'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child:TextField(
                        decoration: const InputDecoration(labelText: '单词本名称'),
                        onSubmitted: (value) async {
                          Navigator.pop(context);
                          await widget.wordBookManager.createWordBook(value);
                          setState((){});
                        }
                      ),
                    )
                  ]
                );
              }
            );
          }
        ),
        Expanded(
          child: ListView.builder(
            itemCount: WordBookManager.wordBooks!.length,
            prototypeItem: const ListTile(
              title: Text('单词本'),
            ),
            itemBuilder: (context, index) {
              TextStyle titleTextStyle = const TextStyle(
                color: Colors.black
              );
              String suffix = '';
              if(WordBookManager.wordBooks![index] == WordMemorizingSystem().currentWordBook?.name){
                suffix = '(当前单词本)';
                titleTextStyle = TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold
                );
              }
              return ListTile(
                title: Text(WordBookManager.wordBooks![index] + suffix),
                titleTextStyle: titleTextStyle,
                onTap: (){
                  showDialog(
                    context: context, 
                    builder: (context)=>SimpleDialog(
                      title: Text(WordBookManager.wordBooks![index]),
                      children:[
                        SimpleDialogOption(
                          child: const Text('删除'),
                          onPressed: () async{
                            Navigator.of(context).pop();
                            if(WordBookManager.wordBooks![index] == WordBookManager.defaultWordBookName){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('默认单词本不能删除')));
                              return;
                            }
                            if(WordBookManager.wordBooks![index] == WordMemorizingSystem().currentWordBook?.name){
                              WordMemorizingSystem().changeWordBook(WordBookManager.defaultWordBookName);
                            }
                            await widget.wordBookManager.deleteWordBook(WordBookManager.wordBooks![index]);
                            setState((){});
                          },
                        ),
                        SimpleDialogOption(
                          child: const Text('选为当前单词本'),
                          onPressed: (){
                            Navigator.of(context).pop();
                            if(WordMemorizingSystem().currentWordBook?.name == WordBookManager.wordBooks![index]) return;
                            WordMemorizingSystem().changeWordBook(WordBookManager.wordBooks![index]);
                            setState((){});
                          },
                        ),
                        SimpleDialogOption(
                          child: const Text('查看'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            WordBook wordBook = await widget.wordBookManager.getWordBook(WordBookManager.wordBooks![index]);
                            if(!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => WordBookContentPage(wordBook: wordBook),)
                            );
                          },
                        ),
                        SimpleDialogOption(
                          child: const Text('从文件中导入单词'),
                          onPressed: () async {
                            try{
                              FilePickerResult? result = await FilePicker.platform.pickFiles();
                              if(result == null){
                                throw Exception('未选择文件');
                              }
                              WordBook wordBook = await widget.wordBookManager.getWordBook(WordBookManager.wordBooks![index]);
                              wordBook.loadFromFile(File(result.files.single.path!));
                              if(!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                 ..removeCurrentSnackBar()
                                 ..showSnackBar(const SnackBar(content: Text('导入成功')));
                            }
                            catch(e){
                              if(!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        ),
                      ]
                    )
                  );
                },
              );
            },
          )
        )
      ],)
    );
  }
}