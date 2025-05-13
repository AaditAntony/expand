import 'package:expand/features/product/product_model.dart';
import 'package:expand/features/product/product_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductViewmodel extends StateNotifier<List<Product>> {
  ProductViewmodel() : super([]) {
    loadProducts();
  }
  Future<void> loadProducts() async {
    ProductData productData = ProductData();

    state =
        productData.clothingProducts.map((e) => Product.fromMap(e)).toList();
    print(state);
  }

  // this is the price that is less than 20

  List<Product> get affordableProducts =>
      state.where((product) => product.price < 20).toList();
}

final productViewmodelProvider =
    StateNotifierProvider<ProductViewmodel, List<Product>>(
      (ref) => ProductViewmodel(),
    );

final showProductProvider = Provider<List<Product>>((ref) {
  return ref.watch(productViewmodelProvider);
});
