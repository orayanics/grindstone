import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExerciseApi {
  ExerciseApi._();
  static final ExerciseApi _instance = ExerciseApi._();
  factory ExerciseApi() => _instance;

  static String? get _baseUrl => dotenv.env['EXERCISE_API'];

  static Future<T> _handleApiCall<T>(Future<http.Response> apiCall,
      T Function(Map<String, dynamic> data) mapper) async {
    try {
      final response = await apiCall;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return mapper(data);
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ExerciseApi error: $e');
      throw Exception('Failed to complete API request: $e');
    }
  }

  static Future<List<Map<String, String>>> fetchSearch(String query) async {
    return _handleApiCall(
        http.get(Uri.parse(
            '${_baseUrl ?? ''}/exercises/autocomplete?search=$query')),
        (data) => (data['data'] as List)
            .map((exercise) => {
                  'exerciseId': exercise['exerciseId'].toString(),
                  'name': exercise['name'].toString(),
                })
            .toList());
  }

  static Future<Map<String, String>> fetchExerciseById(
      String exerciseId) async {
    print('${_baseUrl ?? ''}/exercises/$exerciseId');
    return _handleApiCall(
        http.get(Uri.parse('${_baseUrl ?? ''}/exercises/$exerciseId')),
        (data) => {
              'exerciseId': data['data']['exerciseId'].toString(),
              'name': data['data']['name'].toString(),
              'gifUrl': data['data']['gifUrl'].toString(),
              'targetMuscles': data['data']['targetMuscles'].toString(),
              'bodyParts': data['data']['bodyParts'].toString(),
              'equipments': data['data']['equipments'].toString(),
              'secondaryMuscles': data['data']['secondaryMuscles'].toString(),
              'instructions': data['data']['instructions'].toString(),
            });
  }
}
