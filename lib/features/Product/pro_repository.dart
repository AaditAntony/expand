import 'dart:convert';

import 'package:expand/features/Product/pro_exception.dart';
import 'package:expand/features/Product/pro_model.dart';
import 'package:expand/product%20section/data/product_exception.dart';
import 'package:http/http.dart' as http;

class ProRepository {
  final uri = Uri.parse("https://dummyjson.com/products");

  Future<ProModel> fetchApi() async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> c = jsonDecode(response.body);
        return ProModel.fromJson(c);
      } else {
        throw ProApiException("Api request failed");
      }
    } on http.ClientException catch (e) {
      throw ProNetworkApi(e.message);
    } catch (e) {
      ProductUnknownException(e.toString());
    }
    throw ProductUnknownException("this is an unexpect error");
  }
}
