import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/cached_image_widget.dart';
import '../../utils/colors.dart';
import 'model/product_list_responce_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock =
        product.quantity != null && product.quantity! <= 0;
    final bool hasDiscount = product.comparePrice != null &&
        product.comparePrice! > (product.price ?? 0);

    double bRRR= 5;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(bRRR),
          border: Border.all(
            color: Colors.grey[900]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: bRRR,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:  BorderRadius.only(
                      topLeft: Radius.circular(bRRR),
                      topRight: Radius.circular(bRRR),
                    ),
                    child: product.featuredImage != null &&
                            product.featuredImage!.isNotEmpty
                        ? CachedImageWidget(
                            url: product.featuredImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),

                  // Overlay for out of stock
                  if (isOutOfStock)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),

                  // Badges
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Out of Stock Badge
                        if (isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: boldTextStyle(
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Featured Badge
                        if (product.isFeatured == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appColorPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                4.width,
                                Text(
                                  'Featured',
                                  style: boldTextStyle(
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Discount Badge
                  if (hasDiscount && !isOutOfStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((product.comparePrice! - (product.price ?? 0)) / product.comparePrice! * 100).toStringAsFixed(0)}% OFF',
                          style: boldTextStyle(
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    product.name ?? 'Product Name',
                    style: boldTextStyle(
                      size: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  3.height,

                  Text(
                    product.shortDescription ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      // height: 1,
                      fontWeight: FontWeight.w300
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Current Price
                      if (product.price != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${product.price!.toInt()}',
                              style: boldTextStyle(
                                size: 18,
                                color: appColorPrimary,
                              ),
                            ),
                            4.width,
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                'Bolts',
                                style: secondaryTextStyle(
                                  size: 11,
                                  color: appColorPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Compare Price (if discount exists)
                      if (hasDiscount) ...[
                        8.width,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${product.comparePrice!.toInt()}',
                              style: secondaryTextStyle(
                                size: 12,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            4.width,
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Text(
                                'Bolts',
                                style: secondaryTextStyle(
                                  size: 10,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
