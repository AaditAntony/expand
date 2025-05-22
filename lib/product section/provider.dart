import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expand/product%20section/data/productRepository.dart';
import 'package:expand/product%20section/productViewModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// core providers
final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(
    client: ref.read(httpClientProvider),
    connectivity: ref.read(connectivityProvider),
  ),
);

// view model provider

final productViewModelProvider =
    StateNotifierProvider<Productviewmodel, ProductState>((ref) {
      return Productviewmodel(repository: ref.read(productRepositoryProvider));
    });
