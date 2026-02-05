import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bold_wallet_controller.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_transection_responce_model.dart';

class BoltWalletScreen extends StatefulWidget {
  const BoltWalletScreen({super.key});

  @override
  State<BoltWalletScreen> createState() => _BoltWalletScreenState();
}

class _BoltWalletScreenState extends State<BoltWalletScreen> {
  late BoaltWalletController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setContrller();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        controller.loadMore();
      }
    });
  }

  setContrller() {
    controller = Get.put(BoaltWalletController());
  }

  final ScrollController _scrollController = ScrollController();

  Widget cardDecoration(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            //
            // Color(0xff000428),
            // Color(0xff004e92),

            Color(0xff000000),
            Color(0xff434343)
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              //
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff232526),
                          Color(0xff414345),
                        ]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]),
                height: 180,
                margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                width: double.infinity,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Balance",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${controller.dashboardData.value.data?.wallet?.totalBolt ?? 0} 🪙",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          cardDecoration("Conversion Rate",
                              '${controller.dashboardData.value.data?.wallet?.conversionRate ?? 0} 🔁'),
                          const SizedBox(width: 8),
                          cardDecoration("Bolt Value",
                              '${controller.dashboardData.value.data?.wallet?.inrValue ?? 0} Bolts')
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Your Balance: ",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            Text(
                              "${controller.dashboardData.value.data?.wallet?.displayValue ?? 0} Bolts",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Ads Earning Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade700.withOpacity(0.3),
                        Colors.yellow.shade600.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ads Earnings",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.getAdsEarnings().toStringAsFixed(2)} 🪙",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      // Watch Ads Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.isWatchingAd.value ? null : () => controller.watchAdForReward(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.yellow.shade400,
                                  Colors.orange.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.isWatchingAd.value)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(Icons.play_circle_outline, color: Colors.black, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  controller.isWatchingAd.value ? 'Loading...' : 'Watch Ad',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ),

              const SizedBox(height: 20),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', controller.selectedFilter.value, () => controller.setFilter('all')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Ads', 'ads', controller.selectedFilter.value, () => controller.setFilter('ads')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Social', 'social', controller.selectedFilter.value, () => controller.setFilter('social')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Donation', 'donation', controller.selectedFilter.value, () => controller.setFilter('donation')),
                    ],
                  ),
                )),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff232526),
                            Color(0xff414345),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Transaction History",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(child: Obx(
                () {
                  if (controller.historyLoading.value &&
                      controller.transactionList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Loading Transactions...",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.transactionList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "No Transactions Found",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      controller.refresh();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      itemCount: controller.transactionList.length,
                      itemBuilder: (context, index) {
                        return _TransactionTile(
                          transection: controller.transactionList[index],
                        );
                      },
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value, String selected, VoidCallback onTap) {
    final isSelected = selected == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xff232526),
                      Color(0xff414345),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final BolTransection transection;
  const _TransactionTile({required this.transection});

  @override
  Widget build(BuildContext context) {
    final isPositive = (transection.boltAmount ?? 0) >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff232526),
            Color(0xff414345),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPositive
                    ? [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.1),
                      ]
                    : [
                        Colors.red.withOpacity(0.3),
                        Colors.red.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (transection.actionType ?? '')
                      .replaceAll('_', " ")
                      .capitalizeEachWord(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transection.formattedDate ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${transection.boltAmount ?? 0} 🪙',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
