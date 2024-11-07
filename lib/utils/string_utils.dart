class StringUtils {
  static List<String> parseEnglishSentence(String sentence){
    RegExp exp = RegExp(r'\b\w+\b|[^\w\s]');
    List<String?> words  = exp.allMatches(sentence).map((match) => match.group(0)).toList();
    List<String> result = [];
    for(String? word in words){
      if(word!= null && word.isNotEmpty){
        result.add(word);
      }
    }
    return result;
  }

  static String joinToSentence(List<String> elements){
    String result = "";
    for(String element in elements){
      result += "$element ";
    }
    return result.trim();
  }
}