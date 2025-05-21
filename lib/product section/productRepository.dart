import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expand/product%20section/productModel.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final http.Client client;
  ProductRepository({required this.client});

  Future<List<ProductModel>> fetch({
    int maxRetry = 4,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    int attempt = 0;
    try {
      final response = await client
          .get(
            Uri.parse('https://dummyjson.com/products'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> products = data['products'];
        return products.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw HttpException(
          'request failed with the status:${response.statusCode}',
          uri: Uri.parse('https://dummyjson.com/products'),
        );
      }
    } on TimeoutException catch (_) {
      attempt++;
      if (attempt == maxRetry) {
        throw TimeoutException("Requested time out after $maxRetry attempts");
      }
      await Future.delayed(Duration(seconds: 2));
    } on http.ClientException catch (e) {
      throw Exception('network error:${e.message}');
    } on FormatException catch (e) {
      throw Exception("data parsing error: ${e.message}");
    }
    throw Exception('unexcepted exception occur');
  }
}
