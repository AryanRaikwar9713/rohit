import 'dart:developer';
import 'package:get/get.dart';
import '../event/get_event_responce_modle.dart';
import '../event/event_api.dart';

class EventsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  RxList<ShopEvents> eventsList = RxList<ShopEvents>();
  Rx<ShopEvents?> selectedEvent = Rx<ShopEvents?>(null);

  final Event _eventApi = Event();

  @override
  void onInit() {
    super.onInit();
    getEvents();
  }

  Future<void> getEvents({
    bool showLoader = true,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      page.value = 1;
    }

    isLoading(showLoader);

    try {
      await _eventApi.getEvents(
        page: page.value,
        onError: (error) {
          log("Get Events Error: $error");
          isLoading(false);
        },
        onFailure: (response) {
          log(
            "Get Events Failure: ${response.statusCode ?? 'Unknown'} - ${response.body ?? 'No body'}",
          );
          isLoading(false);
        },
        onSuccess: (data) {
          if (page.value == 1) {
            eventsList.clear();
          }
          if (data.status == "success" || data.status == "true") {

            if (data.data != null && data.data!.isNotEmpty) {


              eventsList.addAll(data.data!);

              if (data.pagination != null) {
                isLastPage(!(data.pagination!.hasNextPage ?? false));
                if (data.pagination!.hasNextPage == true) {
                  page.value++;
                }
              }
              else {
                isLastPage(true);
              }
            } else {
              isLastPage(true);
            }
          }
          isLoading(false);
        },
      );
    } catch (e) {
      log("Get Events Exception: $e");
      isLoading(false);
    }
  }

  void selectEvent(ShopEvents event) {
    selectedEvent(event);
  }

  void loadMoreEvents() {
    if (!isLastPage.value && !isLoading.value) {
      getEvents(showLoader: false);
    }
  }
}
