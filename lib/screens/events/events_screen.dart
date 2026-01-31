import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/event_card_component.dart';
import 'events_controller.dart';
import 'event_detail_screen.dart';

/// Apna gradient - Impact/Donation jaisa yellow-orange
const LinearGradient _eventsGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EventsController eventsController = Get.put(EventsController());

    return AppScaffoldNew(
      isLoading: eventsController.isLoading,
      currentPage: eventsController.page,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      topBarBgColor: transparentColor,
      appBartitleText: 'Events',
      hasLeadingWidget: false,
      body: Column(
        children: [
          // Search Bar (gradient border accent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _eventsGradient.colors.first.withOpacity(0.4),
                  width: 1,
                ),
                color: Colors.grey.withOpacity(0.15),
              ),
              child: CupertinoSearchTextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {},
                placeholder: 'Search Events',
                placeholderStyle: const TextStyle(color: Colors.white70),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: ShaderMask(
                  shaderCallback: (b) => _eventsGradient.createShader(b),
                  child: const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
          // Events List
          Expanded(
            child: Obx(() {
              if (eventsController.isLoading.value &&
                  eventsController.eventsList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventsController.eventsList.isEmpty) {
                return NoDataWidget(
                  titleTextStyle: boldTextStyle(color: white),
                  subTitleTextStyle: primaryTextStyle(color: white),
                  title: locale.value.noDataFound,
                  retryText: locale.value.reload,
                  imageWidget: const EmptyStateWidget(),
                  onRetry: () {
                    eventsController.getEvents(isRefresh: true);
                  },
                ).paddingSymmetric(horizontal: 16);
              }

              return AnimatedListView(
                shrinkWrap: true,
                itemCount: eventsController.eventsList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                onSwipeRefresh: () async {
                  eventsController.getEvents(
                      showLoader: false, isRefresh: true);
                  return Future.delayed(const Duration(seconds: 2));
                },
                onNextPage: () async {
                  if (!eventsController.isLastPage.value) {
                    eventsController.loadMoreEvents();
                  }
                },
                itemBuilder: (ctx, index) {
                  final event = eventsController.eventsList[index];
                  return EventCardComponent(
                    event: event,

                    // on ShopClick
                    onShopClip: (shopId) {},

                    // on EventClick
                    onTap: () {
                      eventsController.selectEvent(event);
                      Get.to(
                        () => EventDetailScreen(
                          event: event,
                          eventsController: eventsController,
                        ),
                      );
                    },
                  ).paddingOnly(
                    bottom: index == eventsController.eventsList.length - 1
                        ? 50
                        : 0,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
