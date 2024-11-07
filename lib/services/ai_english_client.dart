import 'package:openai_dart/openai_dart.dart';


class AIEnglishClient {
  static const String errorMessage = 'Failed to generate';
  static List<String> words = [];
  static final AIEnglishClient _instance = AIEnglishClient._();
  AIEnglishClient._();
  static AIEnglishClient getInstance() => _instance;
  static final client = OpenAIClient(
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    apiKey: '220fe9c3-1aa6-4a19-ab30-6b31c149b666'
  );
  static Future<String> generate(String prompt,[temperature = 0.5]) async{
    try{
      final response = await client.createChatCompletion(
        request:CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId('ep-20241028171859-dwhpj'),
          messages:[
            const ChatCompletionMessage.system(
              content:'You are supposed to help me study English.'),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt)
            )
          ],
          temperature: temperature,
        )
      );
      return await Future.value(response.choices.first.message.content ?? errorMessage);
    }
    catch(e){
      return errorMessage;
    }
  }

  static Future<String> explainWord(String word) async{
    String requirement = 
      'Explain the meaning of the given word: $word .'
      'Explain in English.'
      'Just output the content, don\'t say anything else.';
    try{
      return await generate(requirement);
    }
    catch(e){
      return errorMessage;
    }
  }

  static Future<String> generateSentence(String word) async{
    String requirement = 
      'Generate a English sentence using the given word: $word .'
      'Just output the content, don\'t say anything else.';
    try{
      return await generate(requirement);
    }
    catch(e){
      return errorMessage;
    }
  }

  static Future<String> generatePassage(String prompt,[int wordNum = 100]) async {
    String requirement = 
      'Generate a English passage using words from the given prompt: $prompt .Every word from the prompt should be included in the passage.'
      'The passage should have about $wordNum words.'
      'Just output the content, don\'t say anything else.';
    try{
      return await generate(requirement);
    }
    catch(e){
      return errorMessage;
    }
  }

  static Future<String> generatePassageByWords(List<String> words,[int wordNum = 100]) async {
    String wordPrompt = '';
    for(int i = 0; i < words.length; i++){
      wordPrompt += ' ${words[i]}';
    }
    return await generatePassage(wordPrompt, wordNum);
  }

  static Future<bool> areSynonyms(String word1, String word2) async {
    String requirement = 'Are $word1 and $word2 synonyms? If yes, output "yes"; else output "no". If any incorrect spelling occurs, also output "no". Don\'t output anything else.';
    String result = await generate(requirement);
    if(result == errorMessage) throw Exception('Failed to judge synonyms');
    return result.toLowerCase() == 'yes';
  }

  static void addWord(String word) {
    if(words.contains(word)) return;
    words.add(word);
  }

  static bool deleteWord(String word){
    return words.remove(word);
  }
}