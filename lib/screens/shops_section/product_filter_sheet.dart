import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/colors.dart';
import 'product_controller.dart';

class ProductFilterSheet extends StatelessWidget {
  final ProductController controller;

  const ProductFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Text(
                'Filters',
                style: boldTextStyle(size: 20, color: Colors.white),
              ).expand(),
              TextButton(
                onPressed: () {
                  controller.clearFilters();
                },
                child: Text(
                  'Clear All',
                  style: primaryTextStyle(size: 14, color: appColorPrimary),
                ),
              ),
            ],
          ),
          20.height,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  _buildSearchField(),
                  20.height,

                  // Category Filter
                  _buildCategoryFilter(),
                  20.height,

                  // Price Range
                  _buildPriceRange(),
                  20.height,

                  // Featured Filter
                  _buildFeaturedFilter(),
                  20.height,

                  // In Stock Filter
                  _buildInStockFilter(),
                  20.height,

                  // Sort Options
                  _buildSortOptions(),
                  20.height,
                ],
              ),
            ),
          ),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Apply Filters',
              color: appColorPrimary,
              textStyle: boldTextStyle(size: 16, color: Colors.white),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                controller.applyFilters();
                Get.back();
              },
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        TextField(
          onChanged: (value) {
            controller.searchQuery.value = value;
          },
          controller: TextEditingController(text: controller.searchQuery.value),
          style: primaryTextStyle(size: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appColorPrimary),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    // return Text("shf");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Obx(() {
          if (controller.availableCategories.isEmpty) {
            return Text(
              'No categories available',
              style: secondaryTextStyle(size: 14, color: Colors.grey),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // All Categories option
              _buildChip(
                label: 'All',
                isSelected: controller.selectedCategoryId.value == null,
                onTap: () {
                  controller.selectedCategoryId.value = null;
                },
              ),
              ...controller.availableCategories.map((category) => _buildChip(
                    label: category.name ?? '',
                    isSelected:
                        controller.selectedCategoryId.value == category.id,
                    onTap: () {
                      controller.selectedCategoryId.value = category.id;
                    },
                  )),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {


    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColorPrimary : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? appColorPrimary : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: primaryTextStyle(
            size: 14,
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.minPrice.value = double.tryParse(value);
                },
                controller: TextEditingController(
                  text: controller.minPrice.value != null
                      ? controller.minPrice.value!.toString()
                      : '',
                ),
                style: primaryTextStyle(size: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Min',
                  hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColorPrimary),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
            ),
            16.width,
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.maxPrice.value = double.tryParse(value);
                },
                controller: TextEditingController(
                  text: controller.maxPrice.value != null
                      ? controller.maxPrice.value!.toString()
                      : '',
                ),
                style: primaryTextStyle(size: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Max',
                  hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColorPrimary),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Row(
          children: [
            _buildOptionChip(
              label: 'All',
              isSelected: controller.featured.value == null,
              onTap: () => controller.featured.value = null,
            ),
            8.width,
            _buildOptionChip(
              label: 'Yes',
              isSelected: controller.featured.value == true,
              onTap: () => controller.featured.value = true,
            ),
            8.width,
            _buildOptionChip(
              label: 'No',
              isSelected: controller.featured.value == false,
              onTap: () => controller.featured.value = false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInStockFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Status',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Row(
          children: [
            _buildOptionChip(
              label: 'All',
              isSelected: controller.inStock.value == null,
              onTap: () => controller.inStock.value = null,
            ),
            8.width,
            _buildOptionChip(
              label: 'In Stock',
              isSelected: controller.inStock.value == true,
              onTap: () => controller.inStock.value = true,
            ),
            8.width,
            _buildOptionChip(
              label: 'Out of Stock',
              isSelected: controller.inStock.value == false,
              onTap: () => controller.inStock.value = false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColorPrimary : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? appColorPrimary : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: primaryTextStyle(
            size: 14,
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Obx(() {
          return Column(
            children: controller.sortOptions.map((option) {

              final isSelected = controller.sortBy.value == option;
              return GestureDetector(
                onTap: () {
                  if(controller.sortBy.value==option)
                    {
                      controller.sortBy.value=null;
                      controller.sortOrder.value=null;
                    }
                  else
                    {
                      controller.sortBy.value=option;
                      controller.sortOrder.value="asc";
                    }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? appColorPrimary.withOpacity(0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? appColorPrimary : Colors.grey[700]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                    option.replaceAll("_", " ").capitalizeEachWord(),
                          style: primaryTextStyle(
                            size: 14,
                            color: isSelected ? appColorPrimary : Colors.white,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: appColorPrimary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
