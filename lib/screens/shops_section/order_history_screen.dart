import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/colors.dart';
import 'order_history_controller.dart';
import 'model/user_order_history_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderHistoryController controller = Get.put(OrderHistoryController());

    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Order History',
          style: boldTextStyle(size: 20, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.loadOrders(refresh: true);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.red.withOpacity(0.5),
                ),
                24.height,
                Text(
                  'Error Loading Orders',
                  style: boldTextStyle(size: 24, color: white),
                ),
                16.height,
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(
                    size: 16,
                    color: textSecondaryColorGlobal,
                  ),
                ).paddingSymmetric(horizontal: 32),
                24.height,
                ElevatedButton(
                  onPressed: () => controller.loadOrders(refresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: boldTextStyle(size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 100,
                  color: appColorPrimary.withOpacity(0.5),
                ),
                24.height,
                Text(
                  'No Orders Yet',
                  style: boldTextStyle(size: 24, color: white),
                ),
                16.height,
                Text(
                  'Your order history will appear here',
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(
                    size: 16,
                    color: textSecondaryColorGlobal,
                  ),
                ).paddingSymmetric(horizontal: 32),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadOrders(refresh: true);
          },
          color: appColorPrimary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Orders Count
                if (controller.totalOrders.value > 0)
                  Text(
                    '${controller.totalOrders.value} Order${controller.totalOrders.value != 1 ? 's' : ''}',
                    style:
                        secondaryTextStyle(size: 14, color: Colors.grey[400]),
                  ),
                if (controller.totalOrders.value > 0) 16.height,
                // Orders List
                ...controller.orders.map((order) => OrderCard(order: order)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class OrderCard extends StatelessWidget {
  final UserOrder order;

  const OrderCard({super.key, required this.order});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                // Shop Logo
                if (order.shopLogo != null && order.shopLogo!.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: order.shopLogo!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.store,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                if (order.shopLogo != null && order.shopLogo!.isNotEmpty)
                  12.width,
                // Shop Name and Order Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.shopName != null)
                        Text(
                          order.shopName!,
                          style: boldTextStyle(size: 16, color: Colors.white),
                        ),
                      4.height,
                      if (order.orderNumber != null)
                        Text(
                          'Order #${order.orderNumber}',
                          style: secondaryTextStyle(
                              size: 12, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
                // Status Badge
                if (order.status != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      order.status!.toUpperCase(),
                      style: boldTextStyle(
                        size: 10,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items Count
                if (order.itemsCount != null)
                  Row(
                    children: [
                      Icon(Icons.shopping_cart,
                          size: 16, color: Colors.grey[400]),
                      8.width,
                      Text(
                        '${order.itemsCount} Item${order.itemsCount != 1 ? 's' : ''}',
                        style: secondaryTextStyle(
                            size: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                if (order.itemsCount != null) 12.height,

                // Amount Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: secondaryTextStyle(
                              size: 12, color: Colors.grey[400]),
                        ),
                        4.height,
                        if (order.finalAmount != null)
                          Text(
                            '${order.finalAmount} Bolts',
                            style:
                                boldTextStyle(size: 20, color: appColorPrimary),
                          ),
                      ],
                    ),
                    // Payment Status
                    if (order.paymentStatus != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Payment',
                            style: secondaryTextStyle(
                                size: 12, color: Colors.grey[400]),
                          ),
                          4.height,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor(order.paymentStatus)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _getPaymentStatusColor(
                                      order.paymentStatus)),
                            ),
                            child: Text(
                              order.paymentStatus!.toUpperCase(),
                              style: boldTextStyle(
                                size: 10,
                                color:
                                    _getPaymentStatusColor(order.paymentStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                12.height,

                // Payment Method
                if (order.paymentMethod != null)
                  Row(
                    children: [
                      Icon(Icons.payment, size: 14, color: Colors.grey[400]),
                      6.width,
                      Text(
                        _formatPaymentMethod(order.paymentMethod!),
                        style: secondaryTextStyle(
                            size: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                12.height,

                // Order Date
                if (order.createdAt != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[400]),
                      6.width,
                      Text(
                        'Ordered on ${_formatDate(order.createdAt!)}',
                        style: secondaryTextStyle(
                            size: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                if (order.estimatedDelivery != null) ...[
                  8.height,
                  Row(
                    children: [
                      Icon(Icons.local_shipping,
                          size: 14, color: Colors.grey[400]),
                      6.width,
                      Text(
                        'Est. Delivery: ${order.estimatedDelivery}',
                        style: secondaryTextStyle(
                            size: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'online_payment':
        return 'Online Payment';
      case 'wallet':
        return 'Wallet';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
