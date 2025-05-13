import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expand/features/product/product_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final productList = ref.read(showProductProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("purchase your product "),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.favorite))],
      ),

      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Text(productList[index].name),
                Text(productList[index].price.toString()),
                if (productList[index].price < 20)
                  Text(productList[index].sizes[0]),
              ],
            ),
          );
        },
      ),
    );
  }
}
