import 'dart:core';  
import 'package:flutter/services.dart' show rootBundle;  
import 'package:logger/logger.dart';

var logger = Logger();
  
abstract class Dictionary {  
  String query(String word);
  String get name;
}  


class LocalDictionary implements Dictionary {  
  static LocalDictionary? _singleton;  
  static final Map<String, String> _data = {}; 
  late final List<String> words;
  final String _name = "本地词典";
  LocalDictionary._();  

  @override get name => _name;

  Future<void> _init() async {  
    try {  
      String textFileString = await _load(); 
      var temporaryWordList = textFileString.split(RegExp(r'\s+')); 
      String lastWord = "";
      for (int i = 0; i < temporaryWordList.length; i ++) {
        if(RegExp(r'^[A-Za-z-]+$').hasMatch(temporaryWordList[i])){
          lastWord = temporaryWordList[i];
        }
        else{
          if(_data.containsKey(lastWord)){
            _data[lastWord] = "${_data[lastWord]!} ${temporaryWordList[i]}";
          }
          else{
            _data[lastWord] = temporaryWordList[i];
          }
        }  
      } 
      words = _data.keys.toList();
    } catch (e) {  
      logger.e('Failed to initialize dictionary: $e');  
      rethrow;  
    }  
  }  
  
  static Future<LocalDictionary> getInstance() async {  
    if (_singleton != null) return _singleton!;  
    _singleton = LocalDictionary._();  
    await _singleton!._init();  
    return _singleton!;  
  }  
  
  Future<String> _load() async {  
    try {  
      return await rootBundle.loadString('assets/basic_word_dictionary.txt');  
    } catch (e) {  
      logger.e('Failed to load dictionary file: $e');  
      rethrow;  
    }  
  }  
  
  @override  
  String query(String word) {  
    return _data.containsKey(word) ? _data[word]! : "";  
  }  
}