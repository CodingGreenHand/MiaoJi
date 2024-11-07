import 'package:flutter/material.dart';
import 'package:miao_ji/models/user_plan.dart';
import 'package:miao_ji/services/ai_english_client.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/services/memorizing_method.dart';
import 'package:miao_ji/screens/custom_widgets/custom_widgets.dart';
import 'package:miao_ji/services/dictionary.dart';

class HomePageChangeNotifier extends ChangeNotifier {
  HomePageChangeNotifier._();
  static final HomePageChangeNotifier _instance = HomePageChangeNotifier._();
  factory HomePageChangeNotifier() => _instance;
  void notify() {
    notifyListeners();
  }
}

class MemorizingWordComponent extends StatefulWidget {
  final Listenable updateNotifier = HomePageChangeNotifier();

  MemorizingWordComponent({super.key});

  @override
  State<MemorizingWordComponent> createState() {
    return MemorizingWordComponentState();
  }
}

class MemorizingWordComponentState extends State<MemorizingWordComponent> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.updateNotifier,
        builder: (BuildContext context, Widget? child) {
          if (WordMemorizingSystem().currentWord == '') {
            return const MemorizingWordFinishedPageComponent();
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.newWordLearning) {
            return NewWordLearningPageComponent(
              newWordLearning:
                  NewWordLearning(WordMemorizingSystem().currentWord),
            );
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.wordRecognitionCheck) {
            return WordRecognitionCheckPageComponent(
              wordRecognitionCheck:
                  WordRecognitionCheck(WordMemorizingSystem().currentWord),
            );
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.chineseToEnglishSpelling){
                return ChineseToEnglishSpellingPageComponent(
                  chineseToEnglishSpelling:
                  ChineseToEnglishSpelling(WordMemorizingSystem().currentWord),
                );
              }
          if(WordMemorizingSystem().currentMethod == MemorizingMethodName.chineseToEnglishSelection){

          }
          if(WordMemorizingSystem().currentMethod == MemorizingMethodName.englishToChineseSelection){

          }
          if(WordMemorizingSystem().currentMethod == MemorizingMethodName.sentenceGapFilling){

          }
          return DefaultMemorizingPageComponent();
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
  DefaultMemorizingPageComponent({super.key});
  final Listenable updateNotifier = WordMemorizingSystem();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: HomePageChangeNotifier(),
        builder: (BuildContext context, Widget? child) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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

/// 新词学习
class NewWordLearningPageComponent extends StatefulWidget {
  final NewWordLearning newWordLearning;

  const NewWordLearningPageComponent(
      {super.key, required this.newWordLearning});

  @override
  State<NewWordLearningPageComponent> createState() {
    return NewWordLearningPageComponentState();
  }
}

class NewWordLearningPageComponentState
    extends State<NewWordLearningPageComponent> {
  String? _input;
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    if (!answered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(widget.newWordLearning.word,
                style: const TextStyle(fontSize: 30)),
            ElevatedButton(
                onPressed: () {
                  _input = NewWordLearning.recognized;
                  widget.newWordLearning.checkInput(_input!);
                  WordMemorizingSystem().memorizeNextWord();
                  HomePageChangeNotifier().notify();
                },
                child: const Text('认识')),
            ElevatedButton(
                onPressed: () {
                  _input = NewWordLearning.ambiguous;
                  setState(
                    () {
                      answered = true;
                    },
                  );
                },
                child: const Text('模糊')),
            StyleChangeableButton(
                finalButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                onPressed: () {
                  _input = NewWordLearning.notRecognized;
                  setState(() {
                    answered = true;
                  });
                },
                child: const Text('不认识')),
          ],
        ),
      );
    }
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(widget.newWordLearning.word, style: const TextStyle(fontSize: 30)),
        FutureBuilder(
          future: LocalDictionary.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.query(widget.newWordLearning.word));
            } else if (snapshot.hasError) {
              return const Text('');
            }
            return const Text('本地词典加载中......');
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              answered = false;
              widget.newWordLearning.checkInput(_input!);
              WordMemorizingSystem().memorizeNextWord();
              HomePageChangeNotifier().notify();
            },
            child: const Text('继续学习'),
          ),
        )
      ],
    ));
  }
}

/// 复习方法一：单词卡
class WordRecognitionCheckPageComponent extends StatefulWidget {
  final WordRecognitionCheck wordRecognitionCheck;

  const WordRecognitionCheckPageComponent(
      {super.key, required this.wordRecognitionCheck});

  @override
  State<WordRecognitionCheckPageComponent> createState() {
    return WordRecognitionCheckPageComponentState();
  }
}

class WordRecognitionCheckPageComponentState
    extends State<WordRecognitionCheckPageComponent> {
  String? _input;
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    if (!answered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(widget.wordRecognitionCheck.word,
                style: const TextStyle(fontSize: 30)),
            ElevatedButton(
                onPressed: () {
                  _input = WordRecognitionCheck.recognized;
                  widget.wordRecognitionCheck.checkInput(_input!);
                  WordMemorizingSystem().memorizeNextWord();
                  HomePageChangeNotifier().notify();
                },
                child: const Text('认识')),
            ElevatedButton(
                onPressed: () {
                  _input = WordRecognitionCheck.ambiguous;
                  setState(
                    () {
                      answered = true;
                    },
                  );
                },
                child: const Text('模糊')),
            StyleChangeableButton(
                finalButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                onPressed: () {
                  _input = WordRecognitionCheck.notRecognized;
                  setState(() {
                    answered = true;
                  });
                },
                child: const Text('不认识')),
          ],
        ),
      );
    }
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(widget.wordRecognitionCheck.word, style: const TextStyle(fontSize: 30)),
        FutureBuilder(
          future: LocalDictionary.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.query(widget.wordRecognitionCheck.word));
            } else if (snapshot.hasError) {
              return const Text('');
            }
            return const Text('本地词典加载中......');
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              answered = false;
              widget.wordRecognitionCheck.checkInput(_input!);
              WordMemorizingSystem().memorizeNextWord();
              HomePageChangeNotifier().notify();
            },
            child: const Text('继续学习'),
          ),
        )
      ],
    ));
  }
}

/// 复习方法二：中文拼写
class ChineseToEnglishSpellingPageComponent extends StatefulWidget {
  final ChineseToEnglishSpelling chineseToEnglishSpelling;

  const ChineseToEnglishSpellingPageComponent(
      {super.key, required this.chineseToEnglishSpelling});

  @override
  State<ChineseToEnglishSpellingPageComponent> createState() {
    return ChineseToEnglishSpellingPageComponentState();
  }
}

class ChineseToEnglishSpellingPageComponentState
    extends State<ChineseToEnglishSpellingPageComponent> {
  String? _input;
  bool answered = false;
  String judgeResult = 'synonyms';

  @override
  Widget build(BuildContext context){
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FutureBuilder(
            future: LocalDictionary.getInstance(), 
            builder: (context,snapshot){
              if (snapshot.hasData) {
                return Text(snapshot.data!.query(widget.chineseToEnglishSpelling.word), style: const TextStyle(fontSize: 30));
              }
              else if (snapshot.hasError) {
                return const Text('Error');
              }
              return const Text('加载中文意思......');
            }),
          Padding(padding: const EdgeInsets.all(16.0),
            child:TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '请输入对应的英文单词',
              ),
              onSubmitted:(value){
                _input = value;
                answered = true;
                if(judgeResult == 'synonyms') setState(() {});
              }
            )),
            Builder(builder: (BuildContext context){
              if(answered){
                return FutureBuilder(
                  future:widget.chineseToEnglishSpelling.checkInput(_input!),
                  builder:(context,snapshot){
                    if(snapshot.hasData){
                      judgeResult = snapshot.data!;
                      if(judgeResult == 'synonyms'){
                        return Text('是 $_input 的近义词,请尝试输入其它词汇');
                      }
                      
                        return Column(children: [
                          judgeResult == 'correct' ? const Text('恭喜你，回答正确！') : Text('回答错误，正确答案是 ${widget.chineseToEnglishSpelling.word}'),
                          ElevatedButton(
                            onPressed: (){
                              answered = false;
                              judgeResult = 'synonyms';
                              WordMemorizingSystem().memorizeNextWord();
                              HomePageChangeNotifier().notify();
                            }, 
                            child: const Text('继续学习'))
                        ],);
                      
                    }
                    else if(snapshot.hasError){
                      return Text('${snapshot.error}');
                    }
                    return const Text('正在判定......');
                  }
                );
              }
              return const Text('请输入对应英文单词');
            },),
      ],),);
  }
}