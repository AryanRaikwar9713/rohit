import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/event/event_create_screen.dart';
import 'package:streamit_laravel/screens/shops_section/product_create_screen.dart';
import 'package:streamit_laravel/screens/shops_section/shop_controller.dart';
import 'package:streamit_laravel/screens/shops_section/shop_products_screen.dart';

import '../../utils/colors.dart';

const _shopProfileGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ShopProfileScreen extends StatelessWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopController controller = Get.find<ShopController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(_shopProfileGradient.colors.first),
              ),
            ),
          );
        }

        final shopData = controller.shopProfile.value?.shopData;
        if (shopData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 100, color: Colors.grey),
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
              backgroundColor: const Color(0xFF0D0D0D),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
                          style: const TextStyle(color: Colors.white),
                        ),

                        // Shop Name and Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    _shopProfileGradient.createShader(bounds),
                                child: Text(
                                  shopData.name ?? 'Shop Name',
                                  style: boldTextStyle(size: 24, color: Colors.white),
                                ),
                              ),
                              8.height,
                              if (shopData.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFF9800),
                                      width: 1.5,
                                    ),
                                    color: const Color(0xFFFF9800).withOpacity(0.12),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        _shopProfileGradient.createShader(bounds),
                                    child: Text(
                                      shopData.category!.name ?? '',
                                      style: primaryTextStyle(size: 12, color: Colors.white),
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
                      _gradientButton(
                        label: 'Create Product',
                        onTap: () {
                          if (shopData.id != null) {
                            Get.to(() => ProductCreateScreen(shopId: shopData.id!));
                          }
                        },
                      ),
                    if (shopData.status == 'approved') 14.height,

                    // Create Event Button (only if verified)
                    if (shopData.status == 'approved')
                      _gradientButton(
                        label: 'Create Event',
                        onTap: () => Get.to(() => const EventCreateScreen()),
                      ),
                    if (shopData.status == 'approved') 14.height,

                    // View All Products Button
                    if (shopData.status == 'approved' && shopData.id != null)
                      _outlineGradientButton(
                        label: 'View All Products',
                        onTap: () {
                          Get.to(
                            () => ShopProductsScreen(
                              shopId: shopData.id!,
                              shopName: shopData.name,
                            ),
                          );
                        },
                      ),
                    if (shopData.status == 'approved') 24.height,

                    // Description
                    if (shopData.description != null &&
                        shopData.description!.isNotEmpty) ...[
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            _shopProfileGradient.createShader(bounds),
                        child: Text(
                          'About',
                          style: boldTextStyle(size: 18, color: Colors.white),
                        ),
                      ),
                      10.height,
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
    ),
    );
  }

  Widget _gradientButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _shopProfileGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  label,
                  style: boldTextStyle(size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineGradientButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF9800),
                width: 1.5,
              ),
              color: const Color(0xFFFF9800).withOpacity(0.08),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    _shopProfileGradient.createShader(bounds),
                child: Text(
                  label,
                  style: boldTextStyle(size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              _shopProfileGradient.createShader(bounds),
          child: Text(title, style: boldTextStyle(size: 18, color: Colors.white)),
        ),
        12.height,
        Container(
          padding: const EdgeInsets.all(16),
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
                  decoration: const BoxDecoration(
                    gradient: _shopProfileGradient,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(children: children),
              ),
            ],
          ),
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
          ShaderMask(
            shaderCallback: (bounds) =>
                _shopProfileGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
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
