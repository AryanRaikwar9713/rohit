import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation/model/project_detail_responce_model.dart';

class ProjectDetailController extends GetxController
{


  RxBool loading = true.obs;
  Rx<ProjectDetail> detail = ProjectDetail().obs;

  Future<void> getProject(int id) async {
    // try {
      await DonationProject().getImpactProjectDetails(
          projectId: id,
          onSuccess: (d) {

            print("Data get done");
            if(d.data?.project!=null)
              {
                detail.value =  d.data!.project??ProjectDetail();

              }
          },
          onError: (e) {
            toast(e);
          });
    // } catch (e) {
    //   Logger().e(e);
    // }

    loading.value = false;
  }


  Future<void> donate(double amount,String message) async
  {
    try
        {

          await DonationProject().donateToImpactProject(
            projectId: detail.value?.id??0,
            boltAmount: amount,
            message: message,
            onSuccess: (d) {
              getProject(detail.value?.id??0);
            },
            onFailure: (d){
              var n = jsonDecode(d.body);
              toast(n['message']);
            },
            onError: (e) {
              toast(e);
            },

          );

        }
        catch(e)
    {
      Logger().e(e);
    }

  }



}
