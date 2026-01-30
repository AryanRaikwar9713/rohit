import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_list_responce_model.dart';
import '../../components/app_scaffold.dart';
import '../../utils/colors.dart';
import 'order_history_screen.dart';
import 'product_card.dart';
import 'product_controller.dart';
import 'product_details_screen.dart';
import 'product_filter_sheet.dart';
import 'shop_controller.dart';
import 'shop_profile_screen.dart';
import 'shop_registration_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopController shopController = Get.put(ShopController());
    final ProductController productController = Get.put(ProductController());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.grey.shade700,
          Colors.black,
        ])
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Shop",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
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
            // Filter Button
            IconButton(
              icon: Obx(() => Stack(
                    children: [
                      Icon(Icons.filter_list, color: Colors.white),
                      if (productController.selectedCategoryId.value != null ||
                          productController.searchQuery.value.isNotEmpty ||
                          productController.minPrice.value != null ||
                          productController.maxPrice.value != null ||
                          productController.featured.value != null ||
                          productController.inStock.value != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: appColorPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  )),
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
            // Profile Button
            IconButton(
              icon: Image.asset(
                "assets/icons/seller.png",
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              onPressed: () {
                // Navigate to profile or registration based on hasShop
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
            return const Center(
              child: CircularProgressIndicator(color: appColorPrimary),
            );
          }

          if (productController.products.isEmpty) {
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
                    'Try adjusting your filters',
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(
                        size: 16, color: textSecondaryColorGlobal),
                  ).paddingSymmetric(horizontal: 32),
                ],
              ),
            );
          }

          return _buildProductsList(productController);
        }),
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
        color: appColorPrimary,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            mainAxisExtent: 250,
          ),
          padding: const EdgeInsetsGeometry.only(left: 10,right: 10,top: 10,bottom: 100),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => ProductCard(
            product: controller.products[index],
            onTap: () {
              Get.to(() =>
                  ProductDetailsScreen(product: controller.products[index]));
            },
          ),
        ),
      ),
    );
  }
}

class _ShopAvtar extends StatelessWidget {
  final Shop shop;
  const _ShopAvtar({required this.shop, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
            // image: DecorationImage(
            //   image: NetworkImage(shop.logo??''),
            //   fit: BoxFit.cover,
            // ),
          ),

          child: Text(
            shop.logo ?? '',
            style: TextStyle(color: Colors.white),
          ),

          // child: Image.network(shop.logo??'',fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
          //   return const Icon(Icons.error);
          // },),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
            width: 100,
            child: Text(
              shop.name ?? '',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )),
      ],
    );
  }
}
