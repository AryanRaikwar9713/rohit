import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/campaign_api.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/campain_cat_responce_model.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';

class DonationController extends GetxController {
  // Observable variables
  RxInt page = 1.obs;
  RxBool hasMorePages = true.obs;
  RxBool isLoadingMore = false.obs;

  RxList<Project> projectList = <Project>[].obs;
  RxBool loading = true.obs;

  // Filters from API
  RxList<Datum> categories = <Datum>[].obs;
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  RxBool categoriesLoading = true.obs;

  /// Filtered list by selected category (client-side filter)
  List<Project> get filteredProjectList {
    if (selectedCategoryId.value == null) return projectList;
    return projectList.where((p) => p.category?.id == selectedCategoryId.value).toList();
  }

  /// Only categories that have at least one project - no dummy/blank categories
  List<Datum> get categoriesWithProjects {
    if (projectList.isEmpty) return [];
    final categoryIdsWithProjects = projectList
        .where((p) => p.category?.id != null)
        .map((p) => p.category!.id!)
        .toSet();
    return categories.where((c) => categoryIdsWithProjects.contains(c.id)).toList();
  }
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchCategories();
  }





  
  
  void _initializeData() {
    getProjectlist(refresh: true);
  }





  Future<void> getProjectlist({bool refresh = false}) async {
    try {
      if (refresh) {
        page.value = 1;
        hasMorePages.value = true;
        loading.value = true;
      } else {
        if (!hasMorePages.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      }

      final currentPage = page.value;
      await DonationProject().getImpactProjects(
        page: currentPage,
        onSuccess: (d) {
          final projects = d.data?.projects ?? [];
          final pagination = d.data?.pagination;

          if (currentPage == 1) {
            projectList.value = projects;
          } else {
            projectList.addAll(projects);
          }

          // Update pagination info
          if (pagination != null) {
            hasMorePages.value = pagination.hasNextPage ?? false;
            if (pagination.hasNextPage == true && pagination.currentPage != null) {
              // Increment page for next load
              page.value = pagination.currentPage! + 1;
            } else {
              hasMorePages.value = false;
            }
          } else {
            // Fallback: if no pagination info, assume no more pages if returned list is empty
            hasMorePages.value = projects.isNotEmpty;
            if (projects.isNotEmpty && currentPage == 1) {
              page.value = 2; // Assume there might be more
            }
          }

          projectList.refresh();
          loading.value = false;
          isLoadingMore.value = false;
        },
        onError: (d) {
          Logger().e(d);
          loading.value = false;
          isLoadingMore.value = false;
          toast('Failed to load projects');
        },
      );
    } catch (e) {
      Logger().e(e);
      loading.value = false;
      isLoadingMore.value = false;
      toast('Error loading projects');
    }
  }

  /// Load more projects (for pagination)
  Future<void> loadMoreProjects() async {
    if (!hasMorePages.value || isLoadingMore.value || loading.value) { return; }
    await getProjectlist();
  }

  /// Fetch categories from API (for filter chips)
  Future<void> fetchCategories() async {
    categoriesLoading.value = true;
    try {
      await MyCampaignApi().getCategories(
        onSuccess: (data) {
          categoriesLoading.value = false;
          if (data.success == true && data.data != null) {
            categories.value = data.data!;
            categories.refresh();
          }
        },
        onError: (error) {
          categoriesLoading.value = false;
          Logger().e('Categories error: $error');
        },
        onFailure: (_) {
          categoriesLoading.value = false;
        },
      );
    } catch (e) {
      categoriesLoading.value = false;
      Logger().e(e);
    }
  }

  void setSelectedCategoryId(int? id) {
    selectedCategoryId.value = id;
    selectedCategoryId.refresh();
  }

}
