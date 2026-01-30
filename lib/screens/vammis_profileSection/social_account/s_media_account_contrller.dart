import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/social_account/s_media_account_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/social_account/socila_media_account_model.dart';


class SocialMediaController extends GetxController
{

  RxList<SocialMediaAccount> account = <SocialMediaAccount>[].obs;
  RxBool isLoading = true.obs;
  final api = SocialMediaApi();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getSocialAccount();
  }

  getSocialAccount() async
  {
    await api.getSocialMedia(onSuccess: (d){
      account.value = d.socialMedia??[];
    }, onError: (e){
      Logger().e("Error in Api ${e}");
    }, onFail: (d){
      Logger().e("Failed ${d}");
    });

    isLoading.value = false;
  }





}