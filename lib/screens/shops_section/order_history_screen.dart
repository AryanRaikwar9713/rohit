import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'order_history_controller.dart';
import 'model/user_order_history_model.dart';

const _orderGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderHistoryController controller = Get.put(OrderHistoryController());

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => _orderGradient.createShader(bounds),
            child: Text(
              'Order History',
              style: boldTextStyle(size: 20, color: Colors.white),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _orderGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => controller.loadOrders(refresh: true),
              tooltip: 'Refresh',
            ),
          ],
        ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(_orderGradient.colors.first),
              ),
            ),
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
                Material(
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => controller.loadOrders(refresh: true),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: _orderGradient,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Text(
                          'Retry',
                          style: boldTextStyle(size: 16, color: Colors.white),
                        ),
                      ),
                    ),
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
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _orderGradient,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                28.height,
                ShaderMask(
                  shaderCallback: (bounds) => _orderGradient.createShader(bounds),
                  child: Text(
                    'No Orders Yet',
                    style: boldTextStyle(size: 24, color: Colors.white),
                  ),
                ),
                12.height,
                Text(
                  'Your order history will appear here',
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(size: 15, color: Colors.grey[400]),
                ).paddingSymmetric(horizontal: 40),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.loadOrders(refresh: true),
          color: _orderGradient.colors.first,
          backgroundColor: const Color(0xFF2A2A2A),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.totalOrders.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${controller.totalOrders.value} Order${controller.totalOrders.value != 1 ? 's' : ''}',
                      style: secondaryTextStyle(size: 14, color: Colors.grey[400]),
                    ),
                  ),
                if (controller.totalOrders.value > 0) 12.height,
                ...controller.orders.map((order) => OrderCard(order: order)),
              ],
            ),
          ),
        );
      }),
    ),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient strip at top
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: _orderGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                _orderGradient.createShader(bounds),
                            child: Text(
                              '${order.finalAmount} Bolts',
                              style: boldTextStyle(size: 20, color: Colors.white),
                            ),
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
