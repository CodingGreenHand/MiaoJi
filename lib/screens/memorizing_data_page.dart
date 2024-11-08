import 'package:flutter/material.dart';
import 'package:miao_ji/models/memorizing_data.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';

class MemorizingDataPage extends StatefulWidget {
  const MemorizingDataPage({super.key});

  @override
  MemorizingDataPageState createState() => MemorizingDataPageState();
}

class MemorizingDataPageState extends State<MemorizingDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('单词记忆数据'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const SimpleDialog(
                          title: Text('单词记忆数据说明'),
                          children: [
                            Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child: SingleChildScrollView(child: Text('''
这里的记忆分数衡量你对单词的熟练程度，分数越高，代表你越熟练。
每回答正确一次，记忆分数会增加；如果答错，或在回答其它单词问题的时候误回答了此单词，记忆分数减少。
默认情况下，记忆分数每次增加20，每次减少5。你也可以根据自己的情况设置不同的记忆分数增减值。
每日学习计划会根据记忆分数调整单词的出现频率。
具体而言：
0-20：1天内出现
21-40：1天后出现
41-60：2天后出现
61-80：4天后出现
81-100：7天后出现
101-120：15天后出现
120+：视为已掌握该单词
'''))))
                          ]);
                    });
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: MemorizingData.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return MemorizingDataPageComponent(
                  memorizingData: snapshot.data!);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        )
        //body:Text('MemorizingDataPage')
        );
  }
}

class MemorizingDataPageComponent extends StatefulWidget {
  final MemorizingData memorizingData;

  const MemorizingDataPageComponent({required this.memorizingData, super.key});

  @override
  MemorizingDataPageComponentState createState() =>
      MemorizingDataPageComponentState();
}

class MemorizingDataPageComponentUpdateNotifier extends ChangeNotifier {
  MemorizingDataPageComponentUpdateNotifier._();
  static final MemorizingDataPageComponentUpdateNotifier _instance =
      MemorizingDataPageComponentUpdateNotifier._();

  factory MemorizingDataPageComponentUpdateNotifier() => _instance;

  void notify() {
    notifyListeners();
  }
}

class MemorizingDataPageComponentState
    extends State<MemorizingDataPageComponent> {
  int? year, month, day;
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      searchText = _searchController.text;
      MemorizingDataPageComponentUpdateNotifier().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Padding(padding: const EdgeInsets.only(left:16.0,right:16.0,top: 16.0),
          child:Row(children: [
            TextField(
              decoration: InputDecoration(
                labelText: '加分：${WordMemorizingSystem().userPlan!.scoreAward}',
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100)
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (String value) async {
                int? num;
                try {
                  num = int.parse(value);
                  if(num < 0) throw Exception('增加分数不能为负数');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
                if (num != null) {
                  WordMemorizingSystem().userPlan!.setScoreAward(num);
                }
                setState(() {});
              },
            ),
            const SizedBox(width: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '减分：${WordMemorizingSystem().userPlan!.scorePenalty}',
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (String value) async {
                int? num;
                try {
                  num = int.parse(value);
                  if(num < 0) throw Exception('减少分数不能为负数');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
                if (num != null) {
                  WordMemorizingSystem().userPlan!.setScorePenalty(num);
                }
                setState(() {});
              },
            ),
            Expanded(child: 
        ElevatedButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: const Text('确认清空记忆数据？'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await widget.memorizingData.clear();
                                setState(() {});
                              },
                              child: const Text('确认')),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'))
                        ]);
                  });
            },
            child: const Text('清空数据')),

            )
          ],)
        ),
        Padding(
          padding: const EdgeInsets.only(left:16.0,right:16.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '添加/搜索单词',
              constraints: BoxConstraints(minWidth: 100, maxWidth: 1000),
            ),
            controller: _searchController,
            onSubmitted: (String value) async {
              await widget.memorizingData.update(value, 0);
              setState(() {});
            },
          ),
        ),
        FutureBuilder(
            future: widget.memorizingData.queryAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return ListenableBuilder(
                    listenable: MemorizingDataPageComponentUpdateNotifier(),
                    builder: (context, child) {
                      List<Map<String, dynamic>> originalData = snapshot.data!;
                      List<Map<String, dynamic>> data = [];
                      for (Map<String, dynamic> row in originalData) {
                        if ((row['word'] as String).startsWith(searchText)) {
                          data.add(row);
                        }
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          prototypeItem: const ListTile(title: Text('记忆过的单词')),
                          itemBuilder: (context, index) {
                            DateTime lastMemorizingTime = DateTime.parse(
                                data[index]['last_memorizing_time']);
                            return ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: const Text('修改单词记忆数据'),
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: '记忆分数',
                                                  ),
                                                  onSubmitted:
                                                      (String value) async {
                                                    int? num;
                                                    try {
                                                      num = int.parse(value);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      '$e')));
                                                    }
                                                    Navigator.of(context).pop();
                                                    if (num != null) {
                                                      await widget
                                                          .memorizingData
                                                          .update(
                                                              data[index]
                                                                  ['word'],
                                                              num);
                                                    }
                                                    setState(() {});
                                                  })),
                                          TextButton(
                                              onPressed: () async {
                                                DateTime? selectedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        firstDate:
                                                            DateTime(2000),
                                                        lastDate:
                                                            DateTime.now());
                                                if (selectedDate == null) {
                                                  return;
                                                }
                                                await widget.memorizingData
                                                    .updateLastMemorizingTime(
                                                        data[index]['word'],
                                                        selectedDate);
                                                setState(() {});
                                              },
                                              child: const Text('修改上次记忆时间'))
                                        ],
                                      );
                                    });
                              },
                              title: Text(
                                  '${data[index]['word']} score:${data[index]['score']}'),
                              subtitle: Text(
                                  '上次记忆时间:${lastMemorizingTime.year.toString()}-${lastMemorizingTime.month.toString().padLeft(2, '0')}-${lastMemorizingTime.day.toString().padLeft(2, '0')}'),
                            );
                          },
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            })
      ],
    ));
  }
}
