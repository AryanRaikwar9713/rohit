import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_category_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/p/product_api.dart';

class ProductCreateController extends GetxController {
  // Product categories
  final RxList<ProductCategory> productCategories = <ProductCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Form state
  final RxBool isCreating = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool onCreateScreen = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProductCategories();
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

  /// Create product
  Future<void> createProduct({
    required int shopId,
    required String name,
    required String description,
    required String shortDescription,
    required String price,
    required String comparePrice,
    required String costPrice,
    required String quantity,
    required int categoryId,
    required String sku,
    required String barcode,
    required String pointPrice,
    String? weight,
    File? featuredImage,
    List<File>? imageGallery,
  }) async
  {
    try {
      isCreating.value = true;
      uploadProgress.value = 0.0;

      await ProductAPi().createShopProduct(
        shopId: shopId,
        pointPrice: pointPrice,
        name: name,
        description: description,
        shortDescription: shortDescription,
        price: price,
        comparePrice: comparePrice,
        costPrice: costPrice,
        quantity: quantity,
        categoryId: categoryId,
        sku: sku,
        barcode: barcode,
        weight: weight,
        featuredImage: featuredImage,
        imageGallery: imageGallery,
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
        onError: (e) {
          isCreating.value = false;
          uploadProgress.value = 0.0;
          Logger().e("Error in createShopProduct: $e");
          Get.snackbar(
            'Error',
            'Failed to create product: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        onFailure: (s) {
          isCreating.value = false;
          uploadProgress.value = 0.0;
          _handleResponse(s);
        },
        onSuccess: (response) {
          print('this is as ${onCreateScreen.value}');
          print('this is as');
          isCreating.value = false;
          uploadProgress.value = 0.0;


          toast("Product Created");

          // Only pop if user is still on create screen
          if (onCreateScreen.value) {
            Get.back();
            Get.back();
          }
        },
      );
    } catch (e) {
      isCreating.value = false;
      uploadProgress.value = 0.0;
      Logger().e("Error in createProduct: $e");
      Get.snackbar(
        'Error',
        'Failed to create product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
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
