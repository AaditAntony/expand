import 'dart:convert';

import 'package:expand/lean_riverpod/data_model.dart';
import 'package:http/http.dart' as http;

class DataService {
  final url = Uri.parse("https://dummyjson.com/products");

  Future<DataModel> fetchData() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return DataModel.fromJson(jsonMap);
      } else {
        throw DataException(
          message: "Failed with status code ${response.statusCode}",
        );
      }
    } on http.ClientException {
      throw DataException(message: "Client error occurred");
    } catch (e) {
      throw DataException(message: "Unknown error: $e");
    }
  }
}

class DataException implements Exception {
  final String message;
  DataException({required this.message});
}
