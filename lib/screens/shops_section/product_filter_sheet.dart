import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'product_controller.dart';

const _filterGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ProductFilterSheet extends StatelessWidget {
  final ProductController controller;

  const ProductFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: _filterGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => _filterGradient.createShader(bounds),
                child: Text(
                  'Filters',
                  style: boldTextStyle(size: 22, color: Colors.white),
                ),
              ).expand(),
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: ShaderMask(
                  shaderCallback: (bounds) => _filterGradient.createShader(bounds),
                  child: Text(
                    'Clear All',
                    style: primaryTextStyle(size: 14, color: Colors.white),
                  ),
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
            child: Material(
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  controller.applyFilters();
                  Get.back();
                },
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _filterGradient,
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
                        'Apply Filters',
                        style: boldTextStyle(size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
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
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? _filterGradient : null,
          color: isSelected ? null : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF3E3E3E),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
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
                    borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
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
                    borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? _filterGradient : null,
          color: isSelected ? null : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF3E3E3E),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF9800).withOpacity(0.15)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF2E2E2E),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.replaceAll("_", " ").capitalizeEachWord(),
                          style: primaryTextStyle(
                            size: 14,
                            color: isSelected
                                ? const Color(0xFFFF9800)
                                : Colors.white,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFFFF9800),
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
