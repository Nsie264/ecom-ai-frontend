import 'package:ecom_ai_frontend/controllers/product_management_controller.dart';
import 'package:ecom_ai_frontend/models/product.dart';
import 'package:ecom_ai_frontend/models/product_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductManagementController controller = Get.put(
      ProductManagementController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          // PopupMenuButton<bool?>(
          //   // Filter by isActive
          //   icon: const Icon(Icons.filter_list),
          //   onSelected: (bool? value) {
          //     controller.activeFilter.value = value;
          //   },
          //   itemBuilder:
          //       (BuildContext context) => <PopupMenuEntry<bool?>>[
          //         const PopupMenuItem<bool?>(value: null, child: Text('All')),
          //         const PopupMenuItem<bool?>(
          //           value: true,
          //           child: Text('Active'),
          //         ),
          //         const PopupMenuItem<bool?>(
          //           value: false,
          //           child: Text('Inactive'),
          //         ),
          //       ],
          // ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredProducts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredProducts.isEmpty) {
                return const Center(child: Text('No products found.'));
              }
              return ListView.builder(
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  final price = product.price.toStringAsFixed(2);
                  final stock = product.stockQuantity.toString();
                  final status = product.isActive == true ? 'Active' : 'Inactive';

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Price: ${price}\n'
                      'Stock: ${stock}\n'
                      'Status: ${status}\n'

                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showProductDialog(
                              context,
                              controller,
                              product: product,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                              context,
                              controller,
                              product.productId,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductDialog(context, controller);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    ProductManagementController controller, {
    Product? product,
  }) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final TextEditingController stockQuantityController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    bool currentIsActive =
        product?.isActive ?? true; // Default to true for new products

    Get.dialog(
      AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator:
                      (value) =>
                          value!.isEmpty || double.tryParse(value) == null
                              ? 'Please enter a valid price'
                              : null,
                ),
                TextFormField(
                  controller: stockQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value!.isEmpty || int.tryParse(value) == null
                              ? 'Please enter a valid stock quantity'
                              : null,
                ),
                DropdownButtonFormField<bool>(
                  value: currentIsActive,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      currentIsActive = newValue;
                      // If using a stateful dialog part, you would call setState here.
                    }
                  },
                  validator:
                      (value) =>
                          value == null ? 'Please select a status' : null,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: Text(product == null ? 'Create' : 'Save'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final productRequest = ProductRequest(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  categoryId: 1, // Set categoryId to 1 by default
                  stockQuantity: int.parse(stockQuantityController.text),
                  attributes: product?.attributes ?? {},
                  isActive: currentIsActive, // Use the selected isActive state
                );
                if (product == null) {
                  controller.createProduct(productRequest);
                } else {
                  controller.updateProduct(product.productId, productRequest);
                }
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ProductManagementController controller,
    int productId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: <Widget>[
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              controller.deleteProduct(productId);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
