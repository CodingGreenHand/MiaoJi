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
  final String _name = "本地词典";
  LocalDictionary._();  

  @override get name => _name;

  Future<void> init() async {  
    try {  
      String textFileString = await load(); 
      //logger.d('Dictionary file loaded');  
      var temporaryWordList = textFileString.split(RegExp(r'\s+')); // 使用 RegExp 确保正确分割  
      //logger.d('Dictionary file parsed');
      String lastWord = "";
      for (int i = 0; i < temporaryWordList.length; i ++) {
        if(RegExp(r'^[A-Za-z]+$').hasMatch(temporaryWordList[i])){
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
      //logger.d('Dictionary initialized');  
    } catch (e) {  
      // 处理异常，例如打印错误或重新抛出异常  
      logger.e('Failed to initialize dictionary: $e');  
      rethrow;  
    }  
  }  
  
  static Future<LocalDictionary> getInstance() async {  
    if (_singleton != null) return _singleton!;  
    _singleton = LocalDictionary._();  
    await _singleton!.init();  
    return _singleton!;  
  }  
  
  Future<String> load() async {  
    try {  
      //logger.d('Loading dictionary file...');  
      return await rootBundle.loadString('assets/basic_word_dictionary.txt');  
    } catch (e) {  
      // 处理加载文件时的异常  
      logger.e('Failed to load dictionary file: $e');  
      rethrow;  
    }  
  }  
  
  @override  
  String query(String word) {  
    return _data.containsKey(word) ? _data[word]! : "";  
  }  
}