import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/campaign_api.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';

import '../../utils/app_common.dart';

class DonationController extends GetxController {
  // Observable variables

  RxInt page = 1.obs;

  RxList<Project> projectList = <Project>[].obs;
  RxBool loading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
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
  

  

}
