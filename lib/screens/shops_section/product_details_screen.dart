import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/cached_image_widget.dart';
import '../../utils/colors.dart';
import '../../widgets/bottom_navigation_wrapper.dart';
import 'model/product_list_responce_model.dart';
import 'order_form_screen.dart';
import 'order_history_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock =
        product.quantity == null || product.quantity! <= 0;

    return BottomNavigationWrapper(
      child: Scaffold(
        backgroundColor: appScreenBackgroundDark,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isOutOfStock
                    ? null
                    : () {
                        Get.to(() => OrderFormScreen(
                              product: product,
                              quantity: 1,
                            ));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isOutOfStock ? Colors.grey[700] : appColorPrimary,
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                    12.width,
                    Text(
                      isOutOfStock ? 'Out of Stock' : 'Order Now',
                      style: boldTextStyle(size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            // App Bar with Product Image
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: Colors.grey[900],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () {
                    Get.to(() => const OrderHistoryScreen());
                  },
                  tooltip: 'Order History',
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: product.featuredImage != null &&
                        product.featuredImage!.isNotEmpty
                    ? CachedImageWidget(
                        url: product.featuredImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Product Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Badge
                    if (product.isFeatured == true)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: appColorPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.white),
                            6.width,
                            Text(
                              'Featured Product',
                              style:
                                  boldTextStyle(size: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                    // Product Name
                    Text(
                      product.name ?? 'Product Name',
                      style: boldTextStyle(size: 24, color: Colors.white),
                    ),
                    12.height,

                    // Shop Info
                    if (product.shop != null)
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to shop profile
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Row(
                            children: [
                              if (product.shop!.logo != null &&
                                  product.shop!.logo!.isNotEmpty)
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.grey[700]!),
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: product.shop!.logo!,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.store,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              if (product.shop!.logo != null &&
                                  product.shop!.logo!.isNotEmpty)
                                12.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sold by',
                                      style: secondaryTextStyle(
                                          size: 12, color: Colors.grey[400]),
                                    ),
                                    4.height,
                                    Text(
                                      product.shop!.name ?? 'Shop Name',
                                      style: boldTextStyle(
                                          size: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    if (product.shop != null) 16.height,

                    // Price Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (product.price != null)
                                Text(
                                  '${product.price!.toStringAsFixed(2)} Bolts',
                                  style: boldTextStyle(
                                      size: 28, color: appColorPrimary),
                                ),
                              if (product.comparePrice != null &&
                                  product.comparePrice! >
                                      (product.price ?? 0)) ...[
                                12.width,
                                Text(
                                  '${product.comparePrice!.toStringAsFixed(2)} Bolts',
                                  style: secondaryTextStyle(
                                    size: 18,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                8.width,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: discountColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${((product.comparePrice! - (product.price ?? 0)) / product.comparePrice! * 100).toStringAsFixed(0)}% OFF',
                                    style: boldTextStyle(
                                        size: 12, color: discountColor),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          12.height,
                          // Stock Status
                          Row(
                            children: [
                              if (product.quantity != null &&
                                  product.quantity! > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 18, color: Colors.green),
                                    6.width,
                                    Text(
                                      'In Stock (${product.quantity} available)',
                                      style: primaryTextStyle(
                                          size: 14, color: Colors.green),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(Icons.cancel,
                                        size: 18, color: Colors.red),
                                    6.width,
                                    Text(
                                      'Out of Stock',
                                      style: primaryTextStyle(
                                          size: 14, color: Colors.red),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    16.height,

                    // Category
                    if (product.category != null &&
                        product.category!.name != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: appColorPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: appColorPrimary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.category,
                                size: 16, color: appColorPrimary),
                            6.width,
                            Text(
                              product.category!.name!,
                              style: primaryTextStyle(
                                  size: 14, color: appColorPrimary),
                            ),
                          ],
                        ),
                      ),
                    if (product.category != null &&
                        product.category!.name != null)
                      16.height,

                    if (product.shortDescription != null &&
                        product.shortDescription!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Info',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          12.height,
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[700]!),
                            ),
                            child: Text(
                              product.shortDescription!,
                              style: primaryTextStyle(
                                  size: 14, color: Colors.grey[300]),
                            ),
                          ),
                          16.height,
                        ],
                      ),

                    // Description
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          12.height,
                          Container(
                            // padding: const EdgeInsets.all(16),
                            // decoration: BoxDecoration(
                            //   color: Colors.grey[900],
                            //   borderRadius: BorderRadius.circular(12),
                            //   border: Border.all(color: Colors.grey[700]!),
                            // ),
                            child: Text(
                              product.description!,
                              style: primaryTextStyle(
                                  size: 14, color: Colors.grey[300]),
                            ),
                          ),
                          16.height,
                        ],
                      ),

                    // Product Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (product.viewsCount != null)
                            _buildStatItem(
                              icon: Icons.visibility,
                              label: 'Views',
                              value: '${product.viewsCount}',
                            ),
                          if (product.salesCount != null)
                            _buildStatItem(
                              icon: Icons.shopping_cart,
                              label: 'Sold',
                              value: '${product.salesCount}',
                            ),
                          if (product.quantity != null)
                            _buildStatItem(
                              icon: Icons.inventory_2,
                              label: 'Stock',
                              value: '${product.quantity}',
                            ),
                        ],
                      ),
                    ),
                    16.height,

                    // Image Gallery
                    if (product.imageGallery != null &&
                        product.imageGallery!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More Images',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          12.height,
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: product.imageGallery!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    var pageContrller =
                                        PageController(initialPage: index);
                                    await showDialog(
                                      context: context,
                                      builder: (context) => Blur(
                                        child: PageView(
                                          controller: pageContrller,
                                          children: product.imageGallery!
                                              .map((image) =>
                                                  CachedImageWidget(url: image))
                                              .toList(),
                                        ),
                                      ),
                                    );
                                    pageContrller.dispose();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedImageWidget(
                                        url: product.imageGallery![index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          16.height,
                        ],
                      ),

                    // Short Description

                    // Product Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Details',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          16.height,
                          if (product.sku != null && product.sku!.isNotEmpty)
                            _buildDetailRow('SKU', product.sku!),
                          if (product.barcode != null &&
                              product.barcode!.isNotEmpty)
                            _buildDetailRow('Barcode', product.barcode!),
                          if (product.weight != null)
                            _buildDetailRow('Weight', '${product.weight} kg'),
                          if (product.isDigital == true)
                            _buildDetailRow('Type', 'Digital Product'),
                          if (product.trackQuantity == true)
                            _buildDetailRow('Track Quantity', 'Yes'),
                          if (product.allowBackorders == true)
                            _buildDetailRow('Allow Backorders', 'Yes'),
                        ],
                      ),
                    ),
                    16.height,

                    // Variants
                    if (product.variants != null &&
                        product.variants!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Variants',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          12.height,
                          ...product.variants!.map((variant) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: variant.isDefault == true
                                          ? appColorPrimary
                                          : Colors.grey[700]!,
                                      width: variant.isDefault == true ? 2 : 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            variant.name ?? 'Variant',
                                            style: boldTextStyle(
                                                size: 16, color: Colors.white),
                                          ),
                                        ),
                                        if (variant.isDefault == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: appColorPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Default',
                                              style: boldTextStyle(
                                                  size: 10,
                                                  color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                    8.height,
                                    if (variant.price != null)
                                      Text(
                                        'Price: ${variant.price!.toStringAsFixed(2)} Bolts',
                                        style: primaryTextStyle(
                                            size: 14, color: appColorPrimary),
                                      ),
                                    if (variant.options != null) ...[
                                      8.height,
                                      if (variant.options!.size != null)
                                        Text(
                                          'Size: ${variant.options!.size}',
                                          style: secondaryTextStyle(
                                              size: 12,
                                              color: Colors.grey[400]),
                                        ),
                                      if (variant.options!.color != null)
                                        Text(
                                          'Color: ${variant.options!.color}',
                                          style: secondaryTextStyle(
                                              size: 12,
                                              color: Colors.grey[400]),
                                        ),
                                    ],
                                    if (variant.quantity != null) ...[
                                      8.height,
                                      Text(
                                        'Stock: ${variant.quantity}',
                                        style: secondaryTextStyle(
                                            size: 12, color: Colors.grey[400]),
                                      ),
                                    ],
                                  ],
                                ),
                              )),
                        ],
                      ),
                    16.height,

                    // Tags
                    if (product.tags != null && product.tags!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                          12.height,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.tags!.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[600]!),
                                ),
                                child: Text(
                                  tag,
                                  style: secondaryTextStyle(
                                      size: 12, color: Colors.grey[300]),
                                ),
                              );
                            }).toList(),
                          ),
                          16.height,
                        ],
                      ),

                    // Bottom spacing for fixed button
                    20.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: appColorPrimary),
        8.height,
        Text(
          value,
          style: boldTextStyle(size: 18, color: Colors.white),
        ),
        4.height,
        Text(
          label,
          style: secondaryTextStyle(size: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: secondaryTextStyle(size: 14, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: primaryTextStyle(size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
