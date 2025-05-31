import 'package:expand/product%20section/product_view_model.dart';
import 'package:expand/product%20section/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Productscreen extends ConsumerWidget {
  const Productscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productViewModelProvider);
    final viewModel = ref.read(productViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: _buildBody(state, viewModel),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.fetchProducts();
        },
      ),
    );
  }
}

Widget _buildBody(ProductState state, Productviewmodel viewModel) {
  if (state.isLoading) return const Center(child: CircularProgressIndicator());

  if (state.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.error!.toString(), style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: viewModel.fetchProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  return ListView.builder(
    itemCount: state.product.length,
    itemBuilder: (context, index) {
      final product = state.product[index];
      return ListTile(
        title: Text(product.products[index].title),
        subtitle: Text('\$${product.products[index].price}'),
      );
    },
  );
}
