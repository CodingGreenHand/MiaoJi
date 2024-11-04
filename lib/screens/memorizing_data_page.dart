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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body:FutureBuilder(
        future: MemorizingData.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MemorizingDataPageComponent(memorizingData: snapshot.data!);
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

class MemorizingDataPageComponent extends StatefulWidget{
  final MemorizingData memorizingData;

  const MemorizingDataPageComponent({required this.memorizingData, super.key});

  @override
  MemorizingDataPageComponentState createState() => MemorizingDataPageComponentState();
}

class MemorizingDataPageComponentState extends State<MemorizingDataPageComponent> {
  int? year,month,day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(children: [
        ElevatedButton(
          onPressed: () async{
            showDialog(
              context: context, 
              builder:(context){
                return AlertDialog(
                  title: const Text('确认清空记忆数据？'),
                  actions: [
                    TextButton(
                      onPressed: () async{
                        Navigator.of(context).pop();
                        await widget.memorizingData.clear();
                        setState(() {});
                      },
                      child: const Text('确认')
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消')
                    )
                  ]
                );
              }
            );
          },
          child:const Text('清空记忆数据')
        ),
        TextField(
          decoration: const InputDecoration(
            hintText:'添加单词',
            constraints: BoxConstraints(minWidth: 100, maxWidth: 1000),
          ),
          onSubmitted: (String value) async {
            await widget.memorizingData.update(value,0);
            setState(() {});
          },
        ),
        FutureBuilder(
          future: widget.memorizingData.queryAll(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> data = snapshot.data!;
              //print(data);
              return Expanded(
                child:ListView.builder(
                  itemCount: data.length,
                  prototypeItem: const ListTile(
                    title:Text('记忆过的单词')
                  ),
                  itemBuilder: (context, index) {
                    DateTime lastMemorizingTime = DateTime.parse(data[index]['last_memorizing_time']);
                    return ListTile(
                      onTap:(){
                        showDialog(context: context, 
                          builder: (context){
                            return SimpleDialog(
                              title:const Text ('修改单词记忆数据'),
                              children: [
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '记忆分数',
                                  ),
                                  onSubmitted: (String value) async{
                                    int? num;
                                    try{
                                      num = int.parse(value);
                                    }
                                    catch(e){
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                                    }
                                    Navigator.of(context).pop();
                                    if(num!= null) await widget.memorizingData.update(data[index]['word'],num);
                                    setState(() {});
                                  }
                                ),
                                TextButton(
                                  onPressed: () async{
                                    DateTime? selectedDate = await showDatePicker(
                                      context: context, 
                                      firstDate: DateTime(2000), 
                                      lastDate: DateTime.now()
                                    );
                                    if(selectedDate == null) return;
                                    await widget.memorizingData.updateLastMemorizingTime(data[index]['word'],selectedDate);
                                    setState((){});
                                  },
                                  child:const Text('修改上次记忆时间')
                                )
                                /*
                                Row(children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                      hintText:'年',
                                    ),
                                    onSubmitted: (String value){
                                      year = int.parse(value);
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      hintText:'月',
                                    ),
                                    onSubmitted: (String value){
                                      month = int.parse(value);
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      hintText:'日',
                                    ),
                                    onSubmitted: (String value){
                                      day = int.parse(value);
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ],),
                                ElevatedButton(
                                  onPressed: () async{
                                    if(year!= null && month!= null && day!= null){
                                      DateTime dateTime = DateTime(year!, month!, day!);
                                      await widget.memorizingData.updateLastMemorizingTime(dateTime.toIso8601String());
                                    }
                                  },
                                  child: const Text('修改时间'),
                                )*/
                              ],
                            );
                          }
                        );
                      },
                      title: Text('${data[index]['word']} score:${data[index]['score']}'),
                      subtitle: Text('上次记忆时间:${lastMemorizingTime.year.toString()}-${lastMemorizingTime.month.toString().padLeft(2,'0')}-${lastMemorizingTime.day.toString().padLeft(2,'0')}'),
                    );
                  },
                ),
              );
            }
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }
        )
      ],)
    );
  }
}