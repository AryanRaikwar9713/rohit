import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/shops_section/model/get_shop_profile_model.dart';
import 'package:streamit_laravel/screens/shops_section/model/shop_category_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/shop_api.dart';

class ShopController extends GetxController {
  // Shop profile state
  final Rx<ShopProfileResponceModel?> shopProfile =
      Rx<ShopProfileResponceModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasShop = false.obs;

  // Registration state
  final RxBool isRegistering = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool onRegistrationScreen = false.obs;

  // Categories state
  final RxList<ShopCategory> categories = <ShopCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadShopProfile();
  }

  /// Load shop profile
  Future<void> loadShopProfile() async {
    try {
      isLoading.value = true;
      await ShopApi().getShopProfile(
        onError: (e) {
          isLoading.value = false;
          Logger().e("Error in getShopProfile: $e");
          Get.snackbar(
            'Error',
            'Failed to load shop profile: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        onFailure: (s) {
          isLoading.value = false;
          _handleResponse(s);
        },
        onSuccess: (response) {
          isLoading.value = false;
          shopProfile.value = response;
          hasShop.value = response.hasShop ?? false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Logger().e("Error in loadShopProfile: $e");
    }
  }

  /// Register shop
  Future<void> registerShop({
    required String shopName,
    required String description,
    required int categoryId,
    required String city,
    required String country,
    required String phone,
    required String email,
    required String addressLine1,
    required String state,
    required String postalCode,
    String? website,
    String? latitude,
    String? longitude,
    required String? logoPath,
    required String? coverImagePath,
  }) async
  {
    try {
      isRegistering.value = true;
      uploadProgress.value = 0.0;

      await ShopApi().registerShop(
        shopName: shopName,
        description: description,
        categoryId: categoryId,
        city: city,
        country: country,
        phone: phone,
        email: email,
        addressLine1: addressLine1,
        state: state,
        postalCode: postalCode,
        website: website,
        latitude: latitude,
        longitude: longitude,
        logo: logoPath != null ? await _getFile(logoPath) : null,
        coverImage:
            coverImagePath != null ? await _getFile(coverImagePath) : null,
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
        onError: (e) {
          isRegistering.value = false;
          uploadProgress.value = 0.0;
          Logger().e("Error in registerShop: $e");
          Get.snackbar(
            'Error',
            'Failed to register shop: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        onFailure: (s) {
          isRegistering.value = false;
          uploadProgress.value = 0.0;
          _handleResponse(s);
        },
        onSuccess: (response) {
          isRegistering.value = false;
          uploadProgress.value = 0.0;
          shopProfile.value = response;
          hasShop.value = response.hasShop ?? false;

          Get.snackbar(
            'Success',
            'Shop registered successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );

          // Only pop if user is still on registration screen
          if (onRegistrationScreen.value) {
            Get.back();
          }
        },
      );
    } catch (e) {
      isRegistering.value = false;
      uploadProgress.value = 0.0;
      Logger().e("Error in registerShop: $e");
      Get.snackbar(
        'Error',
        'Failed to register shop: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<File?> _getFile(String path) async {
    try {
      return File(path);
    } catch (e) {
      return null;
    }
  }

  /// Load shop categories
  Future<void> loadShopCategories() async {
    try {
      isLoadingCategories.value = true;
      await ShopApi().getShopCategories(
        onError: (e) {
          isLoadingCategories.value = false;
          Logger().e("Error in getShopCategories: $e");
          Get.snackbar(
            'Error',
            'Failed to load categories: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        onFailure: (s) {
          isLoadingCategories.value = false;
          _handleResponse(s);
        },
        onSuccess: (response) {
          isLoadingCategories.value = false;
          if (response.success == true && response.data != null) {
            categories.value = response.data!.categories ?? [];
            categories.refresh();
          }
        },
      );
    } catch (e) {
      isLoadingCategories.value = false;
      Logger().e("Error in loadShopCategories: $e");
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
