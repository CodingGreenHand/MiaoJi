import 'package:flutter/material.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/services/ai_english_client.dart';
import 'package:miao_ji/screens/word_query_result_page.dart';
import 'package:miao_ji/screens/setting_page.dart';
import 'package:miao_ji/screens/ai_client_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with ChangeNotifier {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('妙记 Miao Ji'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const SettingPage();
                }));
                await WordMemorizingSystem().initialize();
                setState(() {
                  notifyListeners();
                });
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const AiClientPage();
                }));
              },
              icon: const Icon(Icons.article),
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: '查询单词',
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WordQueryResultPage(word: value),
                    ));
                  },
                ),
                MemorizingWordComponent(homePageUpdatedNotifier: this),
              ],
            ),
          ],
        ),
        bottomNavigationBar: WordMemorizingSystem().currentWord == ''
            ? null
            : BottomAppBar(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('提示'),
                              content: const Text(
                                  '确定删除当前单词吗？若确定，将从单词本中删除该单词，并将其的记忆分数设置为满分。'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    Future.wait([
                                      WordMemorizingSystem()
                                          .currentWordBook!
                                          .deleteWord(WordMemorizingSystem()
                                              .currentWord),
                                      WordMemorizingSystem()
                                          .memorizingData
                                          .update(
                                              WordMemorizingSystem()
                                                  .currentWord,
                                              121),
                                    ]);
                                    await WordMemorizingSystem().initialize();
                                    setState(() {});
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () {
                      AIEnglishClient.addWord(
                          WordMemorizingSystem().currentWord);
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                            const SnackBar(content: Text('已添加至AI文章生成待用词')));
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return WordQueryResultPage(
                            word: WordMemorizingSystem().currentWord);
                      }));
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              )));
  }
}

class MemorizingWordComponent extends StatelessWidget {
  final Listenable homePageUpdatedNotifier;

  const MemorizingWordComponent(
      {super.key, required this.homePageUpdatedNotifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: homePageUpdatedNotifier,
        builder: (BuildContext context, Widget? child) {
          if (WordMemorizingSystem().currentWord == '') {
            return const MemorizingWordFinishedPageComponent();
          }
          return DefaultMemorizingPageComponent(
            homePageUpdatedNotifier: homePageUpdatedNotifier,
          );
        });
  }
}

class MemorizingWordFinishedPageComponent extends StatelessWidget {
  const MemorizingWordFinishedPageComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('''
恭喜！您已完成今日学习！
You have finished today's word memorizing. Congratulations!'''));
  }
}

class DefaultMemorizingPageComponent extends StatelessWidget {
  const DefaultMemorizingPageComponent(
      {super.key, required this.homePageUpdatedNotifier});
  final Listenable homePageUpdatedNotifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: homePageUpdatedNotifier,
        builder: (BuildContext context, Widget? child) {
          return Center(
              child: Column(
            children: [
              Text(
                WordMemorizingSystem().currentWord,
                style: const TextStyle(fontSize: 30),
              ),
              Text('current method: ${WordMemorizingSystem().currentMethod}'),
              Text(
                  'current word book: ${WordMemorizingSystem().currentWordBook!.name}'),
              Text(
                  'Words to learn: ${WordMemorizingSystem().currentWordBook!.userProcess!.wordsToLearn}'),
              Text(
                  'Words to review: ${WordMemorizingSystem().currentWordBook!.userProcess!.wordsToReview}'),
              Text(
                  'Today learned ${WordMemorizingSystem().currentWordBook!.userProcess!.todayLearnCount}'),
              Text(
                  'Today reviewed ${WordMemorizingSystem().currentWordBook!.userProcess!.todayReviewCount}'),
            ],
          ));
        });
  }
}
