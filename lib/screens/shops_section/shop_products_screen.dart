import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/colors.dart';
import 'order_history_screen.dart';
import 'product_card.dart';
import 'product_details_screen.dart';
import 'shop_products_controller.dart';

class ShopProductsScreen extends StatelessWidget {
  final int shopId;
  final String? shopName;

  const ShopProductsScreen({super.key, required this.shopId, this.shopName});

  @override
  Widget build(BuildContext context) {
    // Use tag based on shopId to ensure we get the right controller
    final String tag = 'shop_products_$shopId';
    final ShopProductsController controller = Get.put(
      ShopProductsController(shopId: shopId),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          shopName != null ? '$shopName Products' : 'Shop Products',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Your Orders Button
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            onPressed: () {
              Get.to(() => const OrderHistoryScreen());
            },
            tooltip: 'Your Orders',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 100,
                  color: appColorPrimary.withOpacity(0.5),
                ),
                24.height,
                Text(
                  'No Products Found',
                  style: boldTextStyle(size: 24, color: white),
                ),
                16.height,
                Text(
                  'This shop has not created any products yet',
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(
                    size: 16,
                    color: textSecondaryColorGlobal,
                  ),
                ).paddingSymmetric(horizontal: 32),
              ],
            ),
          );
        }

        return Expanded(child: _buildProductsList(controller));
      }),
    );
  }

  Widget _buildProductsList(ShopProductsController controller) {

    // return Center(child: Text("alkljkdfa00",style: TextStyle(color: Colors.white),));

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
        color: appColorPrimary,
        


        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
          itemCount:
              controller.products.length, // +2 for header and load more
          itemBuilder: (context, index) {

            return ProductCard(
              product: controller.products[index],
              onTap: () {
                Get.to(() => ProductDetailsScreen(product: controller.products[index]));
              },
            );
          },
        ),
      ),
    );
  }
}
