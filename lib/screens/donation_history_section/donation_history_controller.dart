import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation_history_section/model/donation_history_history_responce.dart';

class DonationHistoryController extends GetxController {
  // State
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isLoadingMore = false.obs;

  // Data
  Rx<DonationHistoryReponceModel?> donationHistoryResponse =
      Rx<DonationHistoryReponceModel?>(null);
  RxList<Donation> donations = <Donation>[].obs;
  Rx<UserStats?> userStats = Rx<UserStats?>(null);

  // Pagination
  RxInt currentPage = 1.obs;
  RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDonationHistory();
  }

  /// Load Donation History
  Future<void> loadDonationHistory({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      donations.clear();
    }

    if (!hasMorePages.value || isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await DonationProject().getUserDonationHistory(
        page: currentPage.value,
        onSuccess: (response) {
          isLoading.value = false;

          if (response.success == true && response.data != null) {
            donationHistoryResponse.value = response;

            // Update user stats
            if (response.data!.userStats != null) {
              userStats.value = response.data!.userStats;
            }

            // Update donations list
            final newDonations = response.data!.donations ?? [];
            if (refresh) {
              donations.value = newDonations;
            } else {
              donations.addAll(newDonations);
            }
            donations.refresh();

            // Update pagination
            if (response.data!.pagination != null) {
              hasMorePages.value =
                  response.data!.pagination!.hasNextPage ?? false;
            } else {
              hasMorePages.value = false;
            }
          } else {
            errorMessage.value =
                response.message ?? 'Failed to load donation history';
            if (refresh) {
              toast(errorMessage.value);
            }
          }
        },
        onError: (error) {
          isLoading.value = false;
          errorMessage.value = error;
          Logger().e('Error loading donation history: $error');
          if (refresh) {
            toast(error);
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Something went wrong: $e';
      Logger().e('Exception loading donation history: $e');
      if (refresh) {
        toast(errorMessage.value);
      }
    }
  }

  /// Load More Donations
  Future<void> loadMoreDonations() async {
    if (hasMorePages.value && !isLoadingMore.value && !isLoading.value) {
      currentPage.value++;
      isLoadingMore.value = true;

      try {
        await DonationProject().getUserDonationHistory(
          page: currentPage.value,
          onSuccess: (response) {
            isLoadingMore.value = false;

            if (response.success == true && response.data != null) {
              final newDonations = response.data!.donations ?? [];
              donations.addAll(newDonations);
              donations.refresh();

              // Update pagination
              if (response.data!.pagination != null) {
                hasMorePages.value =
                    response.data!.pagination!.hasNextPage ?? false;
              } else {
                hasMorePages.value = false;
              }
            } else {
              hasMorePages.value = false;
            }
          },
          onError: (error) {
            isLoadingMore.value = false;
            currentPage.value--; // Revert page on error
            Logger().e('Error loading more donations: $error');
          },
        );
      } catch (e) {
        isLoadingMore.value = false;
        currentPage.value--; // Revert page on error
        Logger().e('Exception loading more donations: $e');
      }
    }
  }

  /// Refresh Donation History
  Future<void> refreshDonationHistory() async {
    await loadDonationHistory(refresh: true);
  }

  /// Format Date
  String formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
