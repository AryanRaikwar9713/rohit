import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/event/event_create_screen.dart';
import 'package:streamit_laravel/screens/shops_section/product_create_screen.dart';
import 'package:streamit_laravel/screens/shops_section/shop_controller.dart';
import 'package:streamit_laravel/screens/shops_section/shop_products_screen.dart';

import '../../utils/colors.dart';

class ShopProfileScreen extends StatelessWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        final shopData = controller.shopProfile.value?.shopData;
        if (shopData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 100, color: Colors.grey),
                20.height,
                Text(
                  'No Shop Data',
                  style: boldTextStyle(size: 20, color: Colors.white),
                ),
                8.height,
                Text(
                  'Unable to load shop profile',
                  style: secondaryTextStyle(size: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Cover Image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: Colors.grey[900],
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: shopData.coverImage != null &&
                        shopData.coverImage!.isNotEmpty
                    ? Image.network(
                        shopData.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.store,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.store,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),

            // Shop Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Shop Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 2,
                            ),
                            color: Colors.grey[800],
                          ),
                          child: shopData.logo != null &&
                                  shopData.logo!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    shopData.logo!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.store,
                                        size: 50,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.store,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                        ),
                        16.width,

                        Text(
                          "${shopData.id}",
                          style: TextStyle(color: Colors.white),
                        ),

                        // Shop Name and Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopData.name ?? 'Shop Name',
                                style: boldTextStyle(
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              8.height,
                              if (shopData.category != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appColorPrimary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: appColorPrimary),
                                  ),
                                  child: Text(
                                    shopData.category!.name ?? '',
                                    style: primaryTextStyle(
                                      size: 12,
                                      color: appColorPrimary,
                                    ),
                                  ),
                                ),
                              8.height,
                              if (shopData.status != null)
                                Row(
                                  children: [
                                    Icon(
                                      shopData.status == 'approved'
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color: shopData.status == 'approved'
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 16,
                                    ),
                                    4.width,
                                    Text(
                                      shopData.status!.toUpperCase(),
                                      style: primaryTextStyle(
                                        size: 12,
                                        color: shopData.status == 'approved'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    24.height,

                    // Create Product Button (only if verified)
                    if (shopData.status == 'approved')
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Create Product',
                          color: appColorPrimary,
                          textStyle: boldTextStyle(
                            size: 16,
                            color: Colors.white,
                          ),
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            if (shopData.id != null) {
                              Get.to(
                                () => ProductCreateScreen(shopId: shopData.id!),
                              );
                            }
                          },
                        ),
                      ),
                    if (shopData.status == 'approved') 16.height,

                    // Create Event Button (only if verified)
                    if (shopData.status == 'approved')
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Create Event',
                          color: Colors.orange,
                          textStyle: boldTextStyle(
                            size: 16,
                            color: Colors.white,
                          ),
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            Get.to(() => const EventCreateScreen());
                          },
                        ),
                      ),
                    if (shopData.status == 'approved') 16.height,

                    // View All Products Button
                    if (shopData.status == 'approved' && shopData.id != null)
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'View All Products',
                          color: Colors.grey[800],
                          textStyle: boldTextStyle(
                            size: 16,
                            color: Colors.white,
                          ),
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey[700]!,
                              width: 1,
                            ),
                          ),
                          onTap: () {
                            Get.to(
                              () => ShopProductsScreen(
                                shopId: shopData.id!,
                                shopName: shopData.name,
                              ),
                            );
                          },
                        ),
                      ),
                    if (shopData.status == 'approved') 24.height,

                    // Description
                    if (shopData.description != null &&
                        shopData.description!.isNotEmpty) ...[
                      Text(
                        'About',
                        style: boldTextStyle(size: 18, color: Colors.white),
                      ),
                      8.height,
                      Text(
                        shopData.description!,
                        style: primaryTextStyle(
                          size: 16,
                          color: Colors.grey[300],
                        ),
                      ),
                      24.height,
                    ],

                    // Contact Information
                    _buildSection(
                      title: 'Contact Information',
                      children: [
                        if (shopData.contact?.phone != null)
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: shopData.contact!.phone!,
                          ),
                        if (shopData.contact?.email != null)
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: shopData.contact!.email!,
                          ),
                        if (shopData.contact?.website != null)
                          _buildInfoRow(
                            icon: Icons.language,
                            label: 'Website',
                            value: shopData.contact!.website!,
                            isLink: true,
                          ),
                      ],
                    ),

                    // Address
                    if (shopData.address != null) ...[
                      24.height,
                      _buildSection(
                        title: 'Address',
                        children: [
                          if (shopData.address!.line1 != null)
                            _buildInfoRow(
                              icon: Icons.location_on,
                              label: 'Address',
                              value: shopData.address!.line1!,
                            ),
                          if (shopData.address!.city != null)
                            _buildInfoRow(
                              icon: Icons.location_city,
                              label: 'City',
                              value: shopData.address!.city!,
                            ),
                          if (shopData.address!.state != null)
                            _buildInfoRow(
                              icon: Icons.map,
                              label: 'State',
                              value: shopData.address!.state!,
                            ),
                          if (shopData.address!.country != null)
                            _buildInfoRow(
                              icon: Icons.public,
                              label: 'Country',
                              value: shopData.address!.country!,
                            ),
                          if (shopData.address!.postalCode != null)
                            _buildInfoRow(
                              icon: Icons.markunread_mailbox,
                              label: 'Postal Code',
                              value: shopData.address!.postalCode!,
                            ),
                        ],
                      ),
                    ],

                    // Location (Coordinates)
                    if (shopData.location?.coordinates != null &&
                        shopData.location!.coordinates!.latitude != null) ...[
                      24.height,
                      _buildSection(
                        title: 'Location',
                        children: [
                          _buildInfoRow(
                            icon: Icons.gps_fixed,
                            label: 'Coordinates',
                            value:
                                '${shopData.location!.coordinates!.latitude}, ${shopData.location!.coordinates!.longitude}',
                          ),
                        ],
                      ),
                    ],

                    // Additional Info
                    24.height,
                    _buildSection(
                      title: 'Additional Information',
                      children: [
                        if (shopData.isFeatured != null)
                          _buildInfoRow(
                            icon: Icons.star,
                            label: 'Featured',
                            value: shopData.isFeatured! ? 'Yes' : 'No',
                          ),
                        if (shopData.createdAt != null)
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Created',
                            value: _formatDate(shopData.createdAt!),
                          ),
                      ],
                    ),

                    32.height,
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle(size: 18, color: Colors.white)),
        12.height,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appColorPrimary, size: 20),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: secondaryTextStyle(size: 12, color: Colors.grey),
                ),
                4.height,
                if (isLink)
                  GestureDetector(
                    onTap: () {
                      // Open URL
                    },
                    child: Text(
                      value,
                      style: primaryTextStyle(
                        size: 14,
                        color: appColorPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: primaryTextStyle(size: 14, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
