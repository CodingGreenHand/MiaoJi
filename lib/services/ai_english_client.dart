import 'package:openai_dart/openai_dart.dart';


class AIEnglishClient {
  static final AIEnglishClient _instance = AIEnglishClient._();
  AIEnglishClient._();
  static getInstance() => _instance;
  final client = OpenAIClient(
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    apiKey: '220fe9c3-1aa6-4a19-ab30-6b31c149b666'
  );
  Future<String> generate(String prompt,[temperature = 0.5]) async{
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
      return Future.value(response.choices.first.message.content ?? 'Failed to generate');
    }
    catch(e){
      return 'Failed to generate';
    }
  }

  Future<String> generateSentence(String word) async{
    String requirement = 
      'Generate a English sentence using the given word: $word .'
      'Just output the content, don\'t say anything else.';
    try{
      return await generate(requirement);
    }
    catch(e){
      return 'Failed to generate';
    }
  }

  Future<String> generatePassage(String prompt,[int wordNum = 100]) async {
    String requirement = 
      'Generate a English passage using words from the given prompt: $prompt .'
      'The passage should have about $wordNum words.'
      'Just output the content, don\'t say anything else.';
    try{
      return await generate(requirement);
    }
    catch(e){
      return 'Failed to generate';
    }
  }
}