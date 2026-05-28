import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Configured strictly for Flutter Web communicating with your local Python 3.14 instance
  static const String baseUrl = 'http://10.225.158.81:8000';

  /// Posts crop parameters to FastAPI and returns the predicted market seed variety string
  static Future<String> fetchSeedRecommendation({
    required String cropType, // Accepts: 'maize', 'wheat', 'rice', or 'cotton'
    required Map<String, dynamic> payload,
  }) async {
    // Generates dynamic URLs matching your main.py endpoints (e.g., http://127.0.0.1:8000/predict/maize)
    final url = Uri.parse('$baseUrl/predict/$cropType');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Explicitly informs FastAPI of JSON body format
        },
        body: jsonEncode(payload), // Encodes the Dart Map into a valid JSON payload string
      );

      if (response.statusCode == 200) {
        // Decodes the successful string response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // extracts the 'seed_variety' field from your FastAPI json response dictionary
        return responseData['seed_variety'].toString();
      } else {
        // Catches data schema variations or HTTP 422 validations thrown by Pydantic
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'The server rejected the crop input criteria.');
      }
    } catch (e) {
      // Catches server-down events, CORS errors, or routing breaks
      throw Exception('Failed to connect to backend: $e');
    }
  }
}