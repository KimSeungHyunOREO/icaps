import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const _apiKey = 'AIzaSyC1p9V3tMLdIZSlkMT7F0eGgy68X7PFoAQ';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey';

  static Future<String> getChatResponse(String userMessage) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': userMessage}
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);
    return data['candidates']?[0]['content']['parts']?[0]['text'] ??
        'AI 응답을 가져올 수 없습니다.';
  }
}
