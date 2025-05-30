import 'package:ecom_ai_frontend/views/products/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product.dart';
import '../../routes/app_pages.dart';
import '../cart/cart_screen.dart';
import '../../helpers/navigation_helper.dart';

class ProductListScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialSearchQuery;

  const ProductListScreen({
    Key? key,
    this.initialCategoryId,
    this.initialSearchQuery,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final CartController _cartController = Get.find<CartController>();
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  // Toggle between Grid view and List view
  final RxBool _isGridView = true.obs;

  @override
  void initState() {
    super.initState();

    // Apply initial filters if provided
    if (widget.initialCategoryId != null || widget.initialSearchQuery != null) {
      // Set initial search text
      if (widget.initialSearchQuery != null) {
        _searchController.text = widget.initialSearchQuery!;
      }

      // Apply initial filters with a small delay to ensure UI is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _productController.applyCategory(widget.initialCategoryId);
        if (widget.initialSearchQuery != null) {
          _productController.applySearch(widget.initialSearchQuery);
        }
      });
    } else {
      // No initial filters, load all products
      _productController.fetchProducts(resetPage: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.isEmpty) {
      _productController.applySearch(null);
    } else {
      _productController.applySearch(_searchController.text.trim());
    }
    _refreshController.resetNoData();
  }

  void _onRefresh() async {
    await _productController.fetchProducts(resetPage: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await _productController.loadMoreProducts();

    if (_productController.pagination.page >=
        _productController.pagination.totalPages) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  Widget _buildCategoryChip(int? categoryId, String name, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _productController.applyCategory(categoryId);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("Kéo lên để tải thêm");
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = const Text("Tải thất bại! Nhấn để thử lại!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("Thả để tải thêm");
          } else {
            body = const Text("Không còn dữ liệu");
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _productController.products.length,
        itemBuilder: (context, index) {
          final product = _productController.products[index];
          return _buildProductGridItem(product);
        },
      ),
    );
  }

  Widget _buildProductGridItem(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          NavigationHelper.navigateTo(
            ProductDetailScreen(productId: product.productId),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image - reduce height to prevent overflow
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child:
                  product.imageUrl != null
                      ? Image.network(
                        product.imageUrl!,
                        height: 120, // Reduced from 140
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120, // Reduced from 140
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 120, // Reduced from 140
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
            ),
            // Product info - use tight constraints and optimize space
            Padding(
              padding: const EdgeInsets.all(6.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum size needed
                children: [
                  // Category name
                  Text(
                    product.categoryName ?? 'Danh mục',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ), // Smaller font
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Reduced space
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Smaller font
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced space
                  // Price and add to cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '${_formatCurrency(product.price)} đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Smaller font
                          color: Colors.red,
                        ),
                      ),
                      // Add to cart button
                      Obx(() {
                        final bool isAdding = _cartController.isAdding;
                        return IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                          ), // Smaller icon
                          onPressed:
                              isAdding ? null : () => _addToCart(product),
                          iconSize: 18, // Smaller icon
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ), // Smaller button
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("Kéo lên để tải thêm");
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = const Text("Tải thất bại! Nhấn để thử lại!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("Thả để tải thêm");
          } else {
            body = const Text("Không còn dữ liệu");
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _productController.products.length,
        itemBuilder: (context, index) {
          final product = _productController.products[index];
          return _buildProductListItem(product);
        },
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          NavigationHelper.navigateTo(
            ProductDetailScreen(productId: product.productId),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child:
                  product.imageUrl != null
                      ? Image.network(
                        product.imageUrl!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name
                    Text(
                      product.categoryName ?? 'Danh mục',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatCurrency(product.price)} đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        // Add to cart button
                        Obx(() {
                          final bool isAdding = _cartController.isAdding;
                          return ElevatedButton.icon(
                            onPressed:
                                isAdding ? null : () => _addToCart(product),
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text('Thêm'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final result = await _cartController.addToCart(product.productId, 1);

    if (result) {
      // Không cần hiển thị thông báo vì đã có snackbar trong CartController
    } else {
      // Lỗi đã được xử lý trong CartController
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        elevation: 0,
        actions: [
          // View toggle button
          IconButton(
            icon: Obx(
              () => Icon(_isGridView.value ? Icons.view_list : Icons.grid_view),
            ),
            onPressed: () {
              _isGridView.value = !_isGridView.value;
            },
          ),
          // Recommendation button
          IconButton(
            icon: const Icon(Icons.recommend),
            onPressed: () {
              Get.toNamed(Routes.USER_RECOMMENDATIONS);
            },
            tooltip: 'Đề xuất dành cho bạn',
          ),
          // Cart button with badge
          Obx(() {
            final itemCount = _cartController.cartItemCount;

            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Navigate to cart screen using named route
                    Get.toNamed('/cart');
                  },
                ),
                if (itemCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        itemCount <= 99 ? '$itemCount' : '99+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // Clear search and reload products
                    _productController.applySearch(null);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                // Apply search filter
                _performSearch(); // Use the common search function
              },
              textInputAction:
                  TextInputAction.search, // Show search button on keyboard
            ),
          ),

          // Categories horizontal list
          SizedBox(
            height: 50,
            child: Obx(() {
              // Get current selected category ID to properly highlight
              final int? selectedCategoryId =
                  _productController.filters.categoryId;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount:
                    _productController.categories.length +
                    1, // +1 for "All" category
                itemBuilder: (context, index) {
                  // "All" category (null categoryId)
                  if (index == 0) {
                    return _buildCategoryChip(
                      null,
                      'Tất cả',
                      selectedCategoryId == null,
                    );
                  }

                  // Regular categories
                  final category = _productController.categories[index - 1];
                  return _buildCategoryChip(
                    category.id,
                    category.name,
                    selectedCategoryId == category.id,
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 8),

          // Product list/grid
          Expanded(
            child: Obx(() {
              // Show loading state
              if (_productController.isLoading &&
                  !_productController.isLoadingMore) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error state
              if (_productController.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Có lỗi xảy ra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _productController.errorMessage,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            () => _productController.fetchProducts(
                              resetPage: true,
                            ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              // Show empty state
              if (_productController.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy sản phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy thử tìm kiếm hoặc chọn danh mục khác',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Show grid or list view based on selection
              return _isGridView.value
                  ? _buildProductGrid()
                  : _buildProductList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/orders'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.history),
        tooltip: 'Lịch sử đơn hàng',
      ),
    );
  }

  // Format currency helper function
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
