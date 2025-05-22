import 'package:expand/product%20section/data/ProductException.dart';
import 'package:expand/product%20section/data/productModel.dart';
import 'package:expand/product%20section/data/productRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductState {
  final List<ProductModel> product;
  final bool isLoading;
  final ProductException? error;

  ProductState({this.product = const [], this.isLoading = false, this.error});

  ProductState copyWith({
    List<ProductModel>? product,
    bool? isLoading,
    ProductException? error,
  }) {
    return ProductState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class Productviewmodel extends StateNotifier<ProductState> {
  final ProductRepository repository;
  Productviewmodel({required this.repository}) : super(ProductState());

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: false, error: null);
    try {
      final product = await repository.fetch();
      state = state.copyWith(product: product, isLoading: false);
    } on ProductException catch (e) {
      state.copyWith(isLoading: false, error: e);
    }
  }
}
