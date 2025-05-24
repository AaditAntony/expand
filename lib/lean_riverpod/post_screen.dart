import 'package:expand/lean_riverpod/data_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(dataNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: postState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${error.toString()}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(dataNotifierProvider.notifier).loadData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data:
            (dataModel) => ListView.builder(
              itemCount: dataModel.products.length,
              itemBuilder: (context, index) {
                final product = dataModel.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                    title: Text(product.title),
                    subtitle: Text(product.description),
                    trailing: Text("\$${product.price.toStringAsFixed(2)}"),
                  ),
                );
              },
            ),
      ),
    );
  }
}
