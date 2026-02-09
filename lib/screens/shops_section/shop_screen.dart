import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'order_history_screen.dart';
import 'product_card.dart';
import 'product_controller.dart';
import 'product_details_screen.dart';
import 'product_filter_sheet.dart';
import 'shop_controller.dart';
import 'shop_profile_screen.dart';
import 'shop_registration_screen.dart';

/// Shop screen gradient: yellow → orange (matches app theme)
const _shopGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopController shopController = Get.put(ShopController());
    final ProductController productController = Get.put(ProductController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
            Color(0xFF000000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) =>
                _shopGradient.createShader(bounds),
            child: const Text(
              "Shop",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _shopGradient.colors.first.withOpacity(0.5),
                    _shopGradient.colors.last.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              onPressed: () => Get.to(() => const OrderHistoryScreen()),
              tooltip: 'Your Orders',
            ),
            IconButton(
              icon: Obx(() => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white),
                      if (productController.selectedCategoryId.value != null ||
                          productController.searchQuery.value.isNotEmpty ||
                          productController.minPrice.value != null ||
                          productController.maxPrice.value != null ||
                          productController.featured.value != null ||
                          productController.inStock.value != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: _shopGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) =>
                        ProductFilterSheet(controller: productController),
                  ),
                );
              },
            ),
            IconButton(
              icon: Image.asset(
                "assets/icons/seller.png",
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              onPressed: () {
                if (shopController.hasShop.value) {
                  Get.to(() => const ShopProfileScreen());
                } else {
                  Get.to(() => const ShopRegistrationScreen());
                }
              },
            ),
          ],
        ),
        body: Obx(() {
          if (productController.isLoading.value) {
            return Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _shopGradient.colors.first,
                  ),
                ),
              ),
            );
          }

          if (productController.products.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      _shopGradient.createShader(bounds),
                  child: Text(
                    'Browse products',
                    style: primaryTextStyle(size: 14, color: Colors.white),
                  ),
                ),
              ),
              Expanded(child: _buildProductsList(productController)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _shopGradient,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: Colors.white,
            ),
          ),
          28.height,
          ShaderMask(
            shaderCallback: (bounds) => _shopGradient.createShader(bounds),
            child: Text(
              'No Products Found',
              style: boldTextStyle(size: 24, color: Colors.white),
            ),
          ),
          12.height,
          Text(
            'Try adjusting your filters or check back later',
            textAlign: TextAlign.center,
            style: primaryTextStyle(
              size: 15,
              color: textSecondaryColorGlobal,
            ),
          ).paddingSymmetric(horizontal: 40),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductController controller) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          controller.loadMoreProducts();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          controller.loadProducts(refresh: true);
        },
        color: _shopGradient.colors.first,
        backgroundColor: const Color(0xFF2A2A2A),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 268,
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => ProductCard(
            product: controller.products[index],
            onTap: () {
              Get.to(() =>
                  ProductDetailsScreen(product: controller.products[index]),);
            },
          ),
        ),
      ),
    );
  }
}
