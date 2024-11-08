import 'dart:math';

class ListUtils{
  static List<T> getRandomElements<T>(List<T> list, int num){
    List<T> result = [];
    if(list.length < num){
      result = [...list];
      result.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      return result;
    }
    final random = Random();
    final Set<int> selectedIndices = <int>{};
    while(result.length < num){
      final index = random.nextInt(list.length);
      if(!selectedIndices.contains(index)){
        selectedIndices.add(index);
        result.add(list[index]);
      }
    }
    return result;
  }

  static bool hasRepeatedElements(List list){
    Set set = list.toSet();
    return set.length!= list.length;
  }
}