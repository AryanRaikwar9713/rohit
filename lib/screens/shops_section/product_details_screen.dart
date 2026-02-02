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

const _detailsGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Material(
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: isOutOfStock
                        ? null
                        : () {
                            Get.to(() => OrderFormScreen(
                                  product: product,
                                  quantity: 1,
                                ));
                          },
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isOutOfStock
                            ? null
                            : _detailsGradient,
                        color: isOutOfStock ? Colors.grey[700] : null,
                        boxShadow: isOutOfStock
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          12.width,
                          Text(
                            isOutOfStock ? 'Out of Stock' : 'Order Now',
                            style: boldTextStyle(size: 17, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: const Color(0xFF0D0D0D),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Get.to(() => const OrderHistoryScreen()),
                    tooltip: 'Order History',
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (product.featuredImage != null &&
                          product.featuredImage!.isNotEmpty)
                        CachedImageWidget(
                          url: product.featuredImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      // Gradient overlay at bottom of image
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.isFeatured == true)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: _detailsGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18, color: Colors.white),
                            8.width,
                            Text(
                              'Featured Product',
                              style:
                                  boldTextStyle(size: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          _detailsGradient.createShader(bounds),
                      child: Text(
                        product.name ?? 'Product Name',
                        style: boldTextStyle(size: 24, color: Colors.white),
                      ),
                    ),
                    14.height,
                    if (product.shop != null)
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to shop profile
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2E2E2E)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  if (product.shop!.logo != null &&
                                      product.shop!.logo!.isNotEmpty)
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF3E3E3E)),
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: product.shop!.logo!,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.store_rounded,
                                            size: 22,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (product.shop!.logo != null &&
                                      product.shop!.logo!.isNotEmpty)
                                    14.width,
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
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    gradient: _detailsGradient,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (product.shop != null) 16.height,
                    _gradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.price != null)
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  _detailsGradient.createShader(bounds),
                              child: Text(
                                '${product.price!.toStringAsFixed(2)} Bolts',
                                style: boldTextStyle(
                                    size: 28, color: Colors.white),
                              ),
                            ),
                          if (product.comparePrice != null &&
                              product.comparePrice! >
                                  (product.price ?? 0)) ...[
                            10.height,
                            Row(
                              children: [
                                Text(
                                  '${product.comparePrice!.toStringAsFixed(2)} Bolts',
                                  style: secondaryTextStyle(
                                    size: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                10.width,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: discountColor.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${((product.comparePrice! - (product.price ?? 0)) / product.comparePrice! * 100).toStringAsFixed(0)}% OFF',
                                    style: boldTextStyle(
                                        size: 12, color: discountColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          14.height,
                          Row(
                            children: [
                              if (product.quantity != null &&
                                  product.quantity! > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 20, color: Colors.green),
                                    8.width,
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
                                    const Icon(Icons.cancel_rounded,
                                        size: 20, color: Colors.red),
                                    8.width,
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
                    if (product.category != null &&
                        product.category!.name != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0xFFFF9800),
                          ),
                          color: const Color(0xFFFF9800).withOpacity(0.12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  _detailsGradient.createShader(bounds),
                              child: const Icon(Icons.category_rounded,
                                  size: 18, color: Colors.white),
                            ),
                            8.width,
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  _detailsGradient.createShader(bounds),
                              child: Text(
                                product.category!.name!,
                                style: primaryTextStyle(
                                    size: 14, color: Colors.white),
                              ),
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
                          _sectionHeading('Quick Info'),
                          12.height,
                          _gradientCard(
                            child: Text(
                              product.shortDescription!,
                              style: primaryTextStyle(
                                  size: 14, color: Colors.grey[300]),
                            ),
                          ),
                          16.height,
                        ],
                      ),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('Description'),
                          12.height,
                          Text(
                            product.description!,
                            style: primaryTextStyle(
                                size: 14, color: Colors.grey[300]),
                          ),
                          16.height,
                        ],
                      ),
                    _gradientCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (product.viewsCount != null)
                            _buildStatItem(
                              icon: Icons.visibility_rounded,
                              label: 'Views',
                              value: '${product.viewsCount}',
                            ),
                          if (product.salesCount != null)
                            _buildStatItem(
                              icon: Icons.shopping_cart_rounded,
                              label: 'Sold',
                              value: '${product.salesCount}',
                            ),
                          if (product.quantity != null)
                            _buildStatItem(
                              icon: Icons.inventory_2_rounded,
                              label: 'Stock',
                              value: '${product.quantity}',
                            ),
                        ],
                      ),
                    ),
                    16.height,
                    if (product.imageGallery != null &&
                        product.imageGallery!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('More Images'),
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
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFF3E3E3E)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9800)
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
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
                    _gradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('Product Details'),
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
                    if (product.variants != null &&
                        product.variants!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('Variants'),
                          12.height,
                          ...product.variants!.map((variant) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: variant.isDefault == true
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFF2E2E2E),
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
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: _detailsGradient,
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
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            _detailsGradient.createShader(bounds),
                                        child: Text(
                                          'Price: ${variant.price!.toStringAsFixed(2)} Bolts',
                                          style: primaryTextStyle(
                                              size: 14, color: Colors.white),
                                        ),
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
                                            size: 12,
                                            color: Colors.grey[400]),
                                      ),
                                    ],
                                  ],
                                ),
                              )),
                        ],
                      ),
                    16.height,
                    if (product.tags != null && product.tags!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('Tags'),
                          12.height,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.tags!.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: const Color(0xFFFF9800)
                                          .withOpacity(0.5)),
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
                    24.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _sectionHeading(String text) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          _detailsGradient.createShader(bounds),
      child: Text(
        text,
        style: boldTextStyle(size: 18, color: Colors.white),
      ),
    );
  }

  Widget _gradientCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: _detailsGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16 + 3, 16, 16),
            child: child,
          ),
        ],
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
        ShaderMask(
          shaderCallback: (bounds) =>
              _detailsGradient.createShader(bounds),
          child: Icon(icon, size: 26, color: Colors.white),
        ),
        10.height,
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
