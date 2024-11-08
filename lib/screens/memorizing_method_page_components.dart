import 'package:flutter/material.dart';
import 'package:miao_ji/models/user_plan.dart';
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
              MemorizingMethodName.chineseToEnglishSpelling) {
            return ChineseToEnglishSpellingPageComponent(
              chineseToEnglishSpelling:
                  ChineseToEnglishSpelling(WordMemorizingSystem().currentWord),
            );
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.chineseToEnglishSelection) {
            return ChineseToEnglishSelectionPageComponent(
              chineseToEnglishSelection:
                  ChineseToEnglishSelection(WordMemorizingSystem().currentWord),
            );
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.englishToChineseSelection) {
            return EnglishToChineseSelectionPageComponent(
              englishToChineseSelection:
                  EnglishToChineseSelection(WordMemorizingSystem().currentWord),
            );
          }
          if (WordMemorizingSystem().currentMethod ==
              MemorizingMethodName.sentenceGapFilling) {
            return SentenceGapFillingPageComponent(
              sentenceGapFilling:
                  SentenceGapFilling(WordMemorizingSystem().currentWord),
            );
          }
          return const DefaultMemorizingPageComponent();
        });
  }
}

class MemorizingWordFinishedPageComponent extends StatelessWidget {
  const MemorizingWordFinishedPageComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      const Text('''
恭喜！您已完成今日学习！
You have finished today's word memorizing. Congratulations!'''),
      ElevatedButton(
          onPressed: () async {
            await WordMemorizingSystem()
                .currentWordBook!
                .userProcess!
                .startNewRound();
            HomePageChangeNotifier().notify();
          },
          child: const Text('再来一轮学习'))
    ]));
  }
}

class DefaultMemorizingPageComponent extends StatelessWidget {
  const DefaultMemorizingPageComponent({super.key});

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
            OptionSizedBox(
              child: ElevatedButton(
                  onPressed: () {
                    _input = NewWordLearning.recognized;
                    widget.newWordLearning.checkInput(_input!);
                    WordMemorizingSystem().memorizeNextWord();
                    HomePageChangeNotifier().notify();
                  },
                  child: const Text('认识')),
            ),
            OptionSizedBox(child:ElevatedButton(
                onPressed: () {
                  _input = NewWordLearning.ambiguous;
                  setState(
                    () {
                      answered = true;
                    },
                  );
                },
                child: const Text('模糊'))),
            OptionSizedBox(child:ElevatedButton(
                onPressed: () {
                  _input = NewWordLearning.notRecognized;
                  setState(() {
                    answered = true;
                  });
                },
                child: const Text('不认识'))),
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
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data!.query(widget.newWordLearning.word));
            } else if (snapshot.hasError) {
              return const Text('');
            }
            return const Text('本地词典加载中......');
          },
        ),
        Center(
          child: OptionSizedBox(child:ElevatedButton(
            onPressed: () {
              answered = false;
              widget.newWordLearning.checkInput(_input!);
              WordMemorizingSystem().memorizeNextWord();
              HomePageChangeNotifier().notify();
            },
            child: const Text('继续学习'),
          )),
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
            OptionSizedBox(child:ElevatedButton(
                onPressed: () {
                  _input = WordRecognitionCheck.recognized;
                  widget.wordRecognitionCheck.checkInput(_input!);
                  WordMemorizingSystem().memorizeNextWord();
                  HomePageChangeNotifier().notify();
                },
                child: const Text('认识'))),
            OptionSizedBox(child:ElevatedButton(
                onPressed: () {
                  _input = WordRecognitionCheck.ambiguous;
                  setState(
                    () {
                      answered = true;
                    },
                  );
                },
                child: const Text('模糊'))),
            OptionSizedBox(child:ElevatedButton(
                onPressed: () {
                  _input = WordRecognitionCheck.notRecognized;
                  setState(() {
                    answered = true;
                  });
                },
                child: const Text('不认识'))),
          ],
        ),
      );
    }
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(widget.wordRecognitionCheck.word,
            style: const TextStyle(fontSize: 30)),
        FutureBuilder(
          future: LocalDictionary.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return Text(
                  snapshot.data!.query(widget.wordRecognitionCheck.word));
            } else if (snapshot.hasError) {
              return const Text('');
            }
            return const Text('本地词典加载中......');
          },
        ),
        Center(
          child: OptionSizedBox(child:ElevatedButton(
            onPressed: () {
              answered = false;
              widget.wordRecognitionCheck.checkInput(_input!);
              WordMemorizingSystem().memorizeNextWord();
              HomePageChangeNotifier().notify();
            },
            child: const Text('继续学习')),
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
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FutureBuilder(
              future: LocalDictionary.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Text(
                      snapshot.data!
                          .query(widget.chineseToEnglishSpelling.word),
                      style: const TextStyle(fontSize: 30));
                } else if (snapshot.hasError) {
                  return Text('Error:${snapshot.error}');
                }
                return const Text('加载中文意思......');
              }),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '请输入对应的英文单词',
                  ),
                  onSubmitted: (value) {
                    _input = value;
                    answered = true;
                    if (judgeResult == 'synonyms') setState(() {});
                  })),
          Builder(
            builder: (BuildContext context) {
              if (answered) {
                return FutureBuilder(
                    future: widget.chineseToEnglishSpelling.checkInput(_input!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        judgeResult = snapshot.data!;
                        if (judgeResult == 'synonyms') {
                          return Text('是 $_input 的近义词,请尝试输入其它词汇');
                        }

                        return Column(
                          children: [
                            judgeResult == 'correct'
                                ? const Text('恭喜你，回答正确！')
                                : Text(
                                    '回答错误，正确答案是 ${widget.chineseToEnglishSpelling.word}'),
                            OptionSizedBox(child:ElevatedButton(
                                onPressed: () {
                                  answered = false;
                                  judgeResult = 'synonyms';
                                  WordMemorizingSystem().memorizeNextWord();
                                  HomePageChangeNotifier().notify();
                                },
                                child: const Text('继续学习')))
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Text('正在判定......');
                    });
              }
              return const Text('请输入对应英文单词');
            },
          ),
        ],
      ),
    );
  }
}

/// 复习方法三：中文选词
class ChineseToEnglishSelectionPageComponent extends StatefulWidget {
  final ChineseToEnglishSelection chineseToEnglishSelection;

  const ChineseToEnglishSelectionPageComponent(
      {super.key, required this.chineseToEnglishSelection});

  @override
  State<ChineseToEnglishSelectionPageComponent> createState() {
    return ChineseToEnglishSelectionPageComponentState();
  }
}

class ChineseToEnglishSelectionPageComponentState
    extends State<ChineseToEnglishSelectionPageComponent> {
  bool answered = false;
  String? _input;
  List<String>? options;

  void optionOnPressed() {
    setState(() {
      widget.chineseToEnglishSelection.checkInput(_input!);
      answered = true;
      if (_input == widget.chineseToEnglishSelection.word) {
        answered = false;
        WordMemorizingSystem().memorizeNextWord();
        HomePageChangeNotifier().notify();
      }
    });
  }

  @override
  Widget build(context) {
    return FutureBuilder(
        future: widget.chineseToEnglishSelection.getOptions(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            options = snapshot.data!;
            return Center(
              child: Column(
                children: [
                  FutureBuilder(
                    future: LocalDictionary.getInstance(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        return Text(
                            snapshot.data!
                                .query(widget.chineseToEnglishSelection.word),
                            style: const TextStyle(fontSize: 30));
                      } else if (snapshot.hasError) {
                        return Text('Error:${snapshot.error}');
                      }
                      return const Text('加载中文意思......');
                    },
                  ),
                  Expanded(child: Builder(builder: (context) {
                    if (!answered) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OptionSizedBox(child:ElevatedButton(
                              onPressed: () {
                                _input = options![0];
                                optionOnPressed();
                              },
                              child: Text(options![0]))),
                          OptionSizedBox(child:ElevatedButton(
                              onPressed: () {
                                _input = options![1];
                                optionOnPressed();
                              },
                              child: Text(options![1]))),
                          OptionSizedBox(child:ElevatedButton(
                              onPressed: () {
                                _input = options![2];
                                optionOnPressed();
                              },
                              child: Text(options![2]))),
                          OptionSizedBox(child:ElevatedButton(
                              onPressed: () {
                                _input = options![3];
                                optionOnPressed();
                              },
                              child: Text(options![3]))),
                        ],
                      );
                    } else {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                '回答错误，正确答案是 ${widget.chineseToEnglishSelection.word}'),
                            OptionSizedBox(child:ElevatedButton(
                                onPressed: () {
                                  answered = false;
                                  WordMemorizingSystem().memorizeNextWord();
                                  HomePageChangeNotifier().notify();
                                },
                                child: const Text('继续学习'))),
                          ]);
                    }
                  }))
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Text('正在获取选项......');
        });
  }
}

/// 复习方法四：英文选词
class EnglishToChineseSelectionPageComponent extends StatefulWidget {
  final EnglishToChineseSelection englishToChineseSelection;

  const EnglishToChineseSelectionPageComponent(
      {super.key, required this.englishToChineseSelection});

  @override
  State<EnglishToChineseSelectionPageComponent> createState() {
    return EnglishToChineseSelectionPageComponentState();
  }
}

class EnglishToChineseSelectionPageComponentState
    extends State<EnglishToChineseSelectionPageComponent> {
  bool answered = false;
  String? _input;
  List<String>? options;

  void optionOnPressed() {
    setState(() {
      widget.englishToChineseSelection.checkInput(_input!);
      answered = true;
      if (_input! == widget.englishToChineseSelection.word) {
        answered = false;
        WordMemorizingSystem().memorizeNextWord();
        HomePageChangeNotifier().notify();
      }
    });
  }

  @override
  Widget build(context) {
    return FutureBuilder(
        future: widget.englishToChineseSelection.getOptions(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            options = snapshot.data!;
            return Center(
              child: Column(
                children: [
                  Text(widget.englishToChineseSelection.word,
                      style: const TextStyle(fontSize: 30)),
                  FutureBuilder(
                    future: LocalDictionary.getInstance(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        return Expanded(child: Builder(builder: (context) {
                          if (!answered) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OptionSizedBox(child:ElevatedButton(
                                    onPressed: () {
                                      _input = options![0];
                                      optionOnPressed();
                                    },
                                    child: Text(
                                        snapshot.data!.query(options![0])))),
                                OptionSizedBox(child:ElevatedButton(
                                    onPressed: () {
                                      _input = options![1];
                                      optionOnPressed();
                                    },
                                    child: Text(
                                        snapshot.data!.query(options![1])))),
                                OptionSizedBox(child:ElevatedButton(
                                    onPressed: () {
                                      _input = options![2];
                                      optionOnPressed();
                                    },
                                    child: Text(
                                        snapshot.data!.query(options![2])))),
                                OptionSizedBox(child:ElevatedButton(
                                    onPressed: () {
                                      _input = options![3];
                                      optionOnPressed();
                                    },
                                    child: Text(
                                        snapshot.data!.query(options![3])))),
                              ],
                            );
                          } else {
                            return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      '回答错误，正确答案是 ${snapshot.data!.query(widget.englishToChineseSelection.word)}'),
                                  OptionSizedBox(child:ElevatedButton(
                                      onPressed: () {
                                        answered = false;
                                        WordMemorizingSystem()
                                            .memorizeNextWord();
                                        HomePageChangeNotifier().notify();
                                      },
                                      child: const Text('继续学习'))),
                                ]);
                          }
                        }));
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Text('加载选项中......');
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Text('正在获取选项......');
        });
  }
}

/// 复习方法五：例句拼写
class SentenceGapFillingPageComponent extends StatefulWidget {
  final SentenceGapFilling sentenceGapFilling;

  const SentenceGapFillingPageComponent(
      {super.key, required this.sentenceGapFilling});

  @override
  State<SentenceGapFillingPageComponent> createState() {
    return SentenceGapFillingPageComponentState();
  }
}

class SentenceGapFillingPageComponentNotifier extends ChangeNotifier {
  SentenceGapFillingPageComponentNotifier._();
  static final SentenceGapFillingPageComponentNotifier _instance =
      SentenceGapFillingPageComponentNotifier._();
  factory SentenceGapFillingPageComponentNotifier() => _instance;
  void notify() {
    notifyListeners();
  }
}

class SentenceGapFillingPageComponentState
    extends State<SentenceGapFillingPageComponent> {
  String? _input;
  bool answered = false;
  String judgeResult = 'synonyms';

  ChangeNotifier notifier = ChangeNotifier();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.sentenceGapFilling.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              widget.sentenceGapFilling.gapIndex >= 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(widget.sentenceGapFilling.getSentenceWithGap(),
                      style: const TextStyle(fontSize: 30)),
                  Text(widget.sentenceGapFilling.translation,
                      style: const TextStyle(fontSize: 20)),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: '请输入句子空缺部分的单词',
                        ),
                        onSubmitted: (value) {
                          answered = true;
                          _input = value;
                          if (judgeResult == 'synonyms') {
                            SentenceGapFillingPageComponentNotifier().notify();
                          }
                        },
                      )),
                  ListenableBuilder(
                    listenable: SentenceGapFillingPageComponentNotifier(),
                    builder: (context, Widget? child) {
                      if (answered) {
                        return FutureBuilder(
                          future: widget.sentenceGapFilling.checkInput(_input!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              judgeResult = snapshot.data!;
                              if (judgeResult == 'synonyms') {
                                return Text('是 $_input 的近义词,请尝试输入其它词汇');
                              }
                              return Column(
                                children: [
                                  judgeResult == 'correct'
                                      ? const Text('恭喜你，回答正确！')
                                      : Text(
                                          '回答错误，正确答案是 ${widget.sentenceGapFilling.word}'),
                                  OptionSizedBox(child:ElevatedButton(
                                    onPressed: () {
                                      answered = false;
                                      judgeResult = 'synonyms';
                                      WordMemorizingSystem().memorizeNextWord();
                                      HomePageChangeNotifier().notify();
                                      setState(() {});
                                    },
                                    child: const Text('继续学习')),
                                  )
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Text('正在判定......');
                          },
                        );
                      }
                      return const Text('请输入句子空缺部分的单词');
                    },
                  )
                ],
              ),
            );
          } else if (snapshot.hasError ||
              (snapshot.connectionState == ConnectionState.done &&
                  widget.sentenceGapFilling.gapIndex < 0)) {
            WordMemorizingSystem()
                .changeMethod(MemorizingMethodName.wordRecognitionCheck);
            return Center(
                child: OptionSizedBox(child:ElevatedButton(
                    onPressed: () {
                      HomePageChangeNotifier().notify();
                    },
                    child: const Text('AI造句填词暂无法使用，点此继续'))));
          }
          return const Center(
            child: Text('加载中...'),
          );
        });
  }
}
