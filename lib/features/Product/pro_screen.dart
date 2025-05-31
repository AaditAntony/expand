import 'package:expand/features/Product/pro_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              // Top section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: TopSection(),
              ),
              // Product list
              const Expanded(child: ProductList()),
            ],
          ),
        ),
      ),
    );
  }
}

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            'https://via.placeholder.com/150',
          ), // Replace with profile image
        ),
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 30),
            SizedBox(width: 15),
            Icon(Icons.search, size: 30),
          ],
        ),
      ],
    );
  }
}

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productshowstate = ref.watch(dataNotiferProvider);
    return productshowstate.when(
      data:
          (proModel) => GridView.builder(
            itemCount: 20,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = proModel.products[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Image.network(
                          product.thumbnail,
                          width: 50,
                          height: 40,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${error.toString()}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      () => ref.read(dataNotiferProvider.notifier).loadData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
