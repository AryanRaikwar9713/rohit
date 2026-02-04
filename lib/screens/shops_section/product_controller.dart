import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_category_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_list_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/p/product_api.dart';

class ProductController extends GetxController {
  // Products state
  final RxList<Product> products = <Product>[].obs;
  final RxList<Shop> shops = <Shop>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Filters state
  final Rx<int?> selectedShopId = Rx<int?>(null);
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final RxString searchQuery = ''.obs;
  final Rx<double?> minPrice = Rx<double?>(null);
  final Rx<double?> maxPrice = Rx<double?>(null);
  final Rx<bool?> featured = Rx<bool?>(null);
  final Rx<bool?> inStock = Rx<bool?>(null);
  final Rx<String?> sortBy = Rx<String?>(null);
  final Rx<String?> sortOrder = Rx<String?>(null);

  // Product categories
  final RxList<ProductCategory> productCategories = <ProductCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Available filters from API
  final RxList<Category> availableCategories = <Category>[].obs;
  final RxList<String> sortOptions = <String>[
    "price","name","view_count",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadProductCategories();
    loadProducts(refresh: true);
  }

  /// Load product categories
  Future<void> loadProductCategories() async {
    try {
      isLoadingCategories.value = true;
      await ProductAPi().getProductCategories(
        onError: (e) {
          isLoadingCategories.value = false;
          Logger().e("Error in getProductCategories: $e");
        },
        onFailure: (s) {
          isLoadingCategories.value = false;
          _handleResponse(s);
        },
        onSuccess: (response) {
          isLoadingCategories.value = false;
          if (response.success == true && response.data != null) {
            productCategories.value = response.data!.categories ?? [];
            productCategories.refresh();
          }
        },
      );
    } catch (e) {
      isLoadingCategories.value = false;
      Logger().e("Error in loadProductCategories: $e");
    }
  }

  /// Load products with filters
  Future<void> loadProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        products.clear();
        isLoading.value = true;
      } else {
        if (!hasMoreData.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      }

      await ProductAPi().getProductsList(
        page: currentPage.value,
        shopId: selectedShopId.value,
        categoryId: selectedCategoryId.value,
        search:
            searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        featured: featured.value,
        inStock: inStock.value,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        onError: (e) {
          if (refresh) {
            isLoading.value = false;
          } else {
            isLoadingMore.value = false;
          }
          Logger().e("Error in getProductsList: $e");
          Get.snackbar(
            'Error',
            'Failed to load products: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        onFailure: (s) {
          if (refresh) {
            isLoading.value = false;
          } else {
            isLoadingMore.value = false;
          }
          _handleResponse(s);
        },
        onSuccess: (response) {
          if (refresh) {
            isLoading.value = false;
          } else {
            isLoadingMore.value = false;
          }

          if (response.success == true && response.data != null) {
            final newProducts = response.data!.products ?? [];

            if (refresh) {
              products.value = newProducts;
              shops.value = response.data!.shops ?? [];
            } else {
              products.addAll(newProducts);
              shops.addAll(response.data!.shops ?? []);
            }
            products.refresh();

            // Update pagination
            final pagination = response.data!.pagination;
            if (pagination != null) {
              hasMoreData.value = pagination.hasNext ?? false;
              if (hasMoreData.value) {
                currentPage.value++;
              }
            } else {
              hasMoreData.value = false;
            }

            // Update available filters
            if (response.data!.filters != null) {
              availableCategories.value =
                  response.data!.filters!.categories ?? [];
              availableCategories.refresh();

            }
          }
        },
      );
    } catch (e) {
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
      Logger().e("Error in loadProducts: $e");
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadProducts();
  }

  /// Apply filters and reload products
  void applyFilters() {
    loadProducts(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    selectedShopId.value = null;
    selectedCategoryId.value = null;
    searchQuery.value = '';
    minPrice.value = null;
    maxPrice.value = null;
    featured.value = null;
    inStock.value = null;
    sortBy.value = null;
    sortOrder.value = null;
    loadProducts(refresh: true);
  }

  /// Set category filter
  void setCategoryFilter(int? categoryId) {
    selectedCategoryId.value = categoryId;
    applyFilters();
  }

  /// Set shop filter
  void setShopFilter(int? shopId) {
    selectedShopId.value = shopId;
    applyFilters();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  /// Set price range
  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    applyFilters();
  }

  /// Set featured filter
  void setFeaturedFilter(bool? value) {
    featured.value = value;
    applyFilters();
  }

  /// Set in stock filter
  void setInStockFilter(bool? value) {
    inStock.value = value;
    applyFilters();
  }

  /// Set sort options
  void setSortOptions(String? sortByValue, String? sortOrderValue) {
    sortBy.value = sortByValue;
    sortOrder.value = sortOrderValue;
    applyFilters();
  }

  void _handleResponse(http.Response response) {
    Logger().e('Status Code: ${response.statusCode}');
    Logger().e('Response Body: ${response.body}');
    Get.snackbar(
      'Error',
      'Failed to process request. Status: ${response.statusCode}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}
