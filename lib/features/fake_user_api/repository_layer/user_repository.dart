import 'dart:convert';

import 'package:expand/features/fake_user_api/model_layer/user_model.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final http.Client client;

  UserRepository({required this.client});
  Future<List<User>> fetchUser() async {
    final response = await client.get(
      Uri.parse("https://jsonplaceholder.typicode.com/users"),
    );
    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> userJson = json.decode(response.body);
      return userJson.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("failed to load the user");
    }
  }
}
