import 'package:flutter_test/flutter_test.dart';  
import 'package:miao_ji/services/database.dart'; // 假设这是你的数据库提供程序  
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  
  
// 假设DBProvider是一个管理数据库连接的类，你需要根据实际情况调整  
import 'package:miao_ji/services/history_search.dart';   
  
void main() {  
  TestWidgetsFlutterBinding.ensureInitialized();  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('plugins.flutter.io/path_provider', (message) async {  
    return null;  
  });  
  group('HistorySearchHandler tests', () {  
    late HistorySearchHandler historySearchHandler;  
  
    setUpAll(() async {
      sqfliteFfiInit();  
      historySearchHandler = await HistorySearchHandler.instance;  
      await historySearchHandler.createHistorySearchTable();  
    });  
  
    tearDownAll(() async {  
      DBProvider.closeDataBase();
    });  
  
    test('insert and get history search', () async {  
      await historySearchHandler.insertHistorySearch('test search');  
      List<Map<String, dynamic>> searches = await historySearchHandler.getHistorySearch();  
      expect(searches.length, equals(1));  
      expect(searches[0]['search_text'], equals('test search'));  
    });  
  
    test('delete history search', () async {  
      await historySearchHandler.insertHistorySearch('test search to delete');  
      List<Map<String, dynamic>> searches = await historySearchHandler.getHistorySearch();  
      int idToDelete = searches[0]['id'];  
      await historySearchHandler.deleteHistorySearch(idToDelete);  
      searches = await historySearchHandler.getHistorySearch();  
      expect(searches.length, equals(1));  
    });  
  
    test('delete all history search', () async {  
      await historySearchHandler.insertHistorySearch('test search 1');  
      await historySearchHandler.insertHistorySearch('test search 2');  
      await historySearchHandler.deleteAllHistorySearch();  
      List<Map<String, dynamic>> searches = await historySearchHandler.getHistorySearch();  
      expect(searches.length, equals(0));  
    });  
  });  
}