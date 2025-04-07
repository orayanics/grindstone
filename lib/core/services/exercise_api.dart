import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExerciseApi {
  ExerciseApi._();
  static final ExerciseApi _instance = ExerciseApi._();
  factory ExerciseApi() => _instance;

  static Future<List<Map<String, String>>> fetchSearch(String query) async {
    final response = await http.get(Uri.parse(
        '${dotenv.env['EXERCISE_API'] ?? ''}/exercises/autocomplete?search=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((exercise) => {
                'exerciseId': exercise['exerciseId'].toString(),
                'name': exercise['name'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  static Future<Map<String, String>> fetchExerciseById(
      String exerciseId) async {
    final response = await http.get(
        Uri.parse('${dotenv.env['EXERCISE_API'] ?? ''}/exercises/$exerciseId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return {
        'exerciseId': data['exerciseId'].toString(),
        'name': data['name'].toString(),
      };
    } else {
      throw Exception('Failed to load exercise');
    }
  }
}
