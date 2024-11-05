import 'package:flutter/material.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/screens/setting_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('妙记 Miao Ji'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Stack(
          children: [
            const MemorizingWordComponent(),
            Positioned(
              top:15.0,
              right: 15.0,
              child:Column(children: [
                FloatingActionButton(
                  heroTag: 'generate_passage_button',
                  tooltip: 'AI passage generation',
                  elevation: 7.0,
                  highlightElevation: 14.0,
                  child:const Icon(Icons.article),
                  onPressed: () {
                    
                  },
                ),
                const SizedBox(height: 10.0),
                FloatingActionButton(
                  heroTag: 'config_button',
                  tooltip: 'Config',
                  elevation: 7.0,
                  highlightElevation: 14.0,
                  child: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const SettingPage();
                    }));
                  },
                )
              ],)
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.article),
            ),
          ],
        )));
  }
}

class MemorizingWordComponent extends StatefulWidget {
  const MemorizingWordComponent({super.key});
  @override
  State<MemorizingWordComponent> createState() {
    if (WordMemorizingSystem().currentWord == '') {
      return _DefaultMemorizingWordComponentState();
    }
    return _WordRecognitionCheckState();
  }
}

class _DefaultMemorizingWordComponentState
    extends State<MemorizingWordComponent> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('''
恭喜！您已完成今日学习！
You have finished today\'s word memorizing. Congratulations!'''));
  }
}

class _WordRecognitionCheckState extends State<MemorizingWordComponent> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Word recognition check'));
  }
}
