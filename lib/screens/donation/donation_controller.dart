import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/campaign_api.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/campain_cat_responce_model.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';

class DonationController extends GetxController {
  // Observable variables

  RxInt page = 1.obs;

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
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchCategories();
  }





  
  @override
  void onClose() {
    super.onClose();
  }
  
  void _initializeData() {
    getProjectlist(refresh: true);
  }





  getProjectlist({bool refresh = false}) async {
    try{

      if(refresh)
        {
          page.value= 1;
        }

      await DonationProject().getImpactProjects(page: 1, onSuccess: (d){
        if(page.value==1)
          {
            projectList.value = d.data?.projects??[];
          }
        else
          {
            projectList.addAll(d.data?.projects??[]);
          }
        projectList.refresh();
        }, onError: (d){
        Logger().e(d);
      });
    }
    catch(e)
    {
      Logger().e(e);
    }
    loading.value = false;

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
