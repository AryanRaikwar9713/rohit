import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/shops_section/model/user_order_history_model.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';

class OrderHistoryController extends GetxController {
  // Orders state
  final RxList<UserOrder> orders = <UserOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalOrders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Load user orders
  Future<void> loadOrders({bool refresh = true}) async {
    if (refresh) {
      orders.clear();
      errorMessage.value = '';
    }

    if (isLoading.value) return;

    isLoading.value = true;

    await OrderApi().getUserProductOrders(
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = error;
        Logger().e("Error in getUserProductOrders: $error");
        Get.snackbar(
          'Error',
          'Failed to load orders: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      },
      onFailure: (response) {
        isLoading.value = false;
        String errorMsg = 'Failed to load orders';
        try {
          final body = response.body;
          if (body.isNotEmpty) {
            final decoded = jsonDecode(body);
            errorMsg = decoded['message'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Status: ${response.statusCode}';
        }
        errorMessage.value = errorMsg;
        Logger().e("Failure in getUserProductOrders: ${response.statusCode}");
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      },
      onSuccess: (response) {
        isLoading.value = false;
        errorMessage.value = '';

        if (response.success == true && response.data != null) {
          final orderList = response.data!.orders ?? [];
          orders.value = orderList;
          orders.refresh();
          totalOrders.value = response.data!.totalOrders ?? 0;
        } else {
          orders.clear();
          totalOrders.value = 0;
        }
      },
    );
  }
}
