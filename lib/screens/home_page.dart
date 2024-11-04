import 'package:flutter/material.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/screens/setting_page.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('妙记 Miao Ji'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:const MemorizingWordComponent(),
      floatingActionButton: Builder(builder: (BuildContext context){
        return FloatingActionButton(
          tooltip: 'Config',
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          elevation: 7.0,
          highlightElevation: 14.0,
          onPressed: (){
            //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: const Text('Config')));
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context){
                return const SettingPage();
              })
            );
          },
          child:const Icon(Icons.settings),
        );
      }
      ),
    );
  }
}

class MemorizingWordComponent extends StatefulWidget{
  const MemorizingWordComponent({super.key});
  @override
  State<MemorizingWordComponent> createState(){
    if(WordMemorizingSystem().currentWord == ''){
      return _DefaultMemorizingWordComponentState();
    }
    return _WordRecognitionCheckState();
  }
}

class _DefaultMemorizingWordComponentState extends State<MemorizingWordComponent>{
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('''
恭喜！您已完成今日学习！
You have finished today\'s word memorizing. Congratulations!''')
    );
  }
}

class _WordRecognitionCheckState extends State<MemorizingWordComponent>{
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Word recognition check')
    );
  }
}