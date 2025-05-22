import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expand/product%20section/data/ProductException.dart';
import 'package:expand/product%20section/data/productModel.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final http.Client client;
  final Connectivity connectivity;

  ProductRepository({required this.client, required this.connectivity});

  Future<List<ProductModel>> fetch({
    int maxRetry = 4,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    int attempt = 0;

    // Check connectivity first
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ProductNetworkException('No internet connection');
    }

    // Retry loop
    while (attempt < maxRetry) {
      try {
        final response = await client
            .get(
              Uri.parse('https://dummyjson.com/products'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> products = data['products'];
          return products.map((e) => ProductModel.fromJson(e)).toList();
        } else {
          throw ProductApiException('API request failed', response.statusCode);
        }
      } on TimeoutException {
        attempt++;
        if (attempt >= maxRetry) {
          throw ProductTimeoutException(attempt: attempt, maxAttempt: maxRetry);
        }
        await Future.delayed(
          Duration(seconds: 2 * attempt),
        ); // Exponential backoff
      } on http.ClientException catch (e) {
        throw ProductNetworkException(e.message);
      } on FormatException catch (e) {
        throw ProductParseException('Data parsing failed: ${e.message}');
      } catch (e) {
        throw ProductUnknownException(e.toString());
      }
    }

    throw ProductUnknownException('Unexpected error occurred after retries');
  }
}
