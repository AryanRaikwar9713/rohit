import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_list_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/p/product_api.dart';

class ShopProductsController extends GetxController {
  final int shopId;

  // Products state
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  ShopProductsController({required this.shopId});

  @override
  void onInit() {
    super.onInit();
    // Delay the initial load to avoid calling setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadProducts(refresh: true);
    });
  }

  /// Load products for this shop
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
        limit: 10,
        shopId: shopId,
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
            } else {
              products.addAll(newProducts);
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
    await loadProducts(refresh: false);
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
