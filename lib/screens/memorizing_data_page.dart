import 'package:flutter/material.dart';
import 'package:miao_ji/models/memorizing_data.dart';

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
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: FutureBuilder(
          future: MemorizingData.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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

class MemorizingDataPageComponentState
    extends State<MemorizingDataPageComponent> {
  int? year, month, day;
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
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
            child: const Text('清空记忆数据')),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration:  InputDecoration(
              hintText: isSearching? '搜索单词' :'添加单词',//TODO:添加搜索单词功能
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 1000),
            ),
            onSubmitted: (String value) async {
              if(!isSearching) await widget.memorizingData.update(value, 0);
              setState(() {});
            },
          ),
        ),
        FutureBuilder(
            future: widget.memorizingData.queryAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Map<String, dynamic>> data = snapshot.data!;
                //print(data);
                return Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    prototypeItem: const ListTile(title: Text('记忆过的单词')),
                    itemBuilder: (context, index) {
                      DateTime lastMemorizingTime =
                          DateTime.parse(data[index]['last_memorizing_time']);
                      return ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  title: const Text('修改单词记忆数据'),
                                  children: [
                                    Padding(padding: const EdgeInsets.all(16.0),
                                      child:TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: '记忆分数',
                                        ),
                                        onSubmitted: (String value) async {
                                          int? num;
                                          try {
                                            num = int.parse(value);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text('$e')));
                                          }
                                          Navigator.of(context).pop();
                                          if (num != null) {
                                            await widget.memorizingData.update(
                                                data[index]['word'], num);
                                          }
                                          setState(() {});
                                        })),
                                    TextButton(
                                        onPressed: () async {
                                          DateTime? selectedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime.now());
                                          if (selectedDate == null) return;
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
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            })
      ],
    ));
  }
}
