import 'package:flutter/material.dart';
import 'package:miao_ji/models/user_plan.dart';
import 'package:miao_ji/screens/memorizing_data_page.dart';
import 'package:miao_ji/services/word_memorizing_system.dart';
import 'package:miao_ji/screens/word_book_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('设置'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: Center(
          child: FutureBuilder<UserPlan>(
            future: UserPlan.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return SettingPageComponent(snapshot.data!);
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ));
  }
}

class SettingPageComponent extends StatefulWidget {
  final UserPlan userPlan;
  const SettingPageComponent(this.userPlan, {super.key});

  @override
  SettingPageComponentState createState() => SettingPageComponentState();
}

class SettingPageComponentState extends State<SettingPageComponent> {
  bool setMemorizingMethodState(bool? value, String method) {
    if (value == true) {
      widget.userPlan.addMemorizingMethod(method);
      return true;
    }
    if (widget.userPlan.methodNum() == 1) return true;
    widget.userPlan.cancelMemorizingMethod(method);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText:
                  '每日学习单词数目: ${widget.userPlan.dailyLearnNum.toString()}',
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 1000)),
          onSubmitted: (value) {
            int num;
            try {
              num = int.parse(value);
              if (num < 0) throw Exception('学到的东西不要还回去啊！');
              if (num == 0) throw Exception('至少学一个吧......');
              if (num > 100000) throw Exception('一天学不了这么多吧......');
              widget.userPlan.setDailyLearnNum(num);
              ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('每日学习单词数目更新为 $num')));
              setState(() {});
            } catch (e) {
              ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.toString())));
              return;
            }
          },
        ),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText:
                  '每日复习单词数目: ${widget.userPlan.dailyReviewNum.toString()}',
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 1000)),
          onSubmitted: (value) {
            int num;
            try {
              num = int.parse(value);
              if (num < 0) throw Exception('学到的东西不要还回去啊！');
              if (num == 0) throw Exception('至少复习一个吧......');
              if (num > 100000) throw Exception('一天学不了这么多吧......');
              widget.userPlan.setDailyReviewNum(num);
              ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('每日复习单词数目更新为 $num')));
              setState(() {});
            } catch (e) {
              ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.toString())));
              return;
            }
          },
        ),
        const Text('单词记忆顺序:'),
        MemorizingOrderToggleButtons(widget.userPlan),
        const Text('单词记忆方法:'),
        TitledCheckBox(
            '卡片模式',
            widget.userPlan
                .isMethodAvailable(MemorizingMethodName.wordRecognitionCheck),
            (bool? value) {
          return setMemorizingMethodState(
              value, MemorizingMethodName.wordRecognitionCheck);
        }),
        TitledCheckBox(
            '拼写模式',
            widget.userPlan.isMethodAvailable(
                MemorizingMethodName.chineseToEnglishSpelling), (bool? value) {
          return setMemorizingMethodState(
              value, MemorizingMethodName.chineseToEnglishSpelling);
        }),
        TitledCheckBox(
            '中文选词',
            widget.userPlan.isMethodAvailable(
                MemorizingMethodName.chineseToEnglishSelection), (bool? value) {
          return setMemorizingMethodState(
              value, MemorizingMethodName.chineseToEnglishSelection);
        }),
        TitledCheckBox(
            '英文选词',
            widget.userPlan.isMethodAvailable(
                MemorizingMethodName.englishToChineseSelection), (bool? value) {
          return setMemorizingMethodState(
              value, MemorizingMethodName.englishToChineseSelection);
        }),
        TitledCheckBox(
            '例句拼写',
            widget.userPlan
                .isMethodAvailable(MemorizingMethodName.sentenceGapFilling),
            (bool? value) {
          return setMemorizingMethodState(
              value, MemorizingMethodName.sentenceGapFilling);
        }),
        ElevatedButton(
          onPressed: () async{
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const MemorizingDataPage()));
          },
          child: const Text('查看单词记忆数据'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async{
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const WordBookPage()
            ));
            setState(() {});
          },
          child:Text('管理单词本（当前单词本：${WordMemorizingSystem().currentWordBook!.name}）')
        )
      ],
    );
  }
}

class MemorizingOrderToggleButtons extends StatefulWidget {
  final UserPlan userPlan;
  const MemorizingOrderToggleButtons(this.userPlan, {super.key});

  @override
  MemorizingOrderToggleButtonsState createState() =>
      MemorizingOrderToggleButtonsState();
}

class MemorizingOrderToggleButtonsState
    extends State<MemorizingOrderToggleButtons> {
  List<bool> isSelected = [false, false, false];

  static const Map<int, String> _orderMap = {
    0: MemorizingOrder.random,
    1: MemorizingOrder.sequential,
    2: MemorizingOrder.reverse,
  };

  static const Map<String, int> _orderReverseMap = {
    MemorizingOrder.random: 0,
    MemorizingOrder.sequential: 1,
    MemorizingOrder.reverse: 2,
  };

  void handleToggle(int index) {
    setState(() {
      widget.userPlan.setMemorizingOrder(_orderMap[index]!);
      for (int i = 0; i < isSelected.length; i++) {
        if (i == index) {
          isSelected[i] = true;
        } else {
          isSelected[i] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    isSelected[_orderReverseMap[widget.userPlan.memorizingOrder]!] = true;
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int index) {
        handleToggle(index);
      },
      children: const <Widget>[
        Text('随机'),
        Text('顺序'),
        Text('倒序'),
      ],
    );
  }
}

class TitledCheckBox extends StatefulWidget {
  final String title;
  final bool Function(bool?) onChanged;
  final bool? initialState;

  const TitledCheckBox(this.title, this.initialState, this.onChanged,
      {super.key});

  @override
  TitledCheckBoxState createState() => TitledCheckBoxState();
}

class TitledCheckBoxState extends State<TitledCheckBox> {
  TitledCheckBoxState({this.isChecked});

  bool? isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      side:
          BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
      title: Text(widget.title),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = widget.onChanged(value);
        });
      },
    );
  }
}
