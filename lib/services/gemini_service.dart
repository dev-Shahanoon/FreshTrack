import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
 static const String apiKey =
    String.fromEnvironment('GEMINI_API_KEY');

  static Future<String> generateRecipe(List<String> ingredients) async {
   final url = Uri.parse(
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
);
    

    final prompt = """
You are a professional chef.

Using ONLY these ingredients:

${ingredients.join(", ")}

Generate ONE recipe.

Format exactly like this:

🍽 Recipe Name

🧂 Ingredients
- item
- item

👨‍🍳 Steps
1.
2.
3.
4.
""";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return json["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Error ${response.statusCode}\n${response.body}";
    }
  }
}