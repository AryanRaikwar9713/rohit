import 'package:get/get.dart';
import 'package:streamit_laravel/screens/walletSection/models/point_history_responce_model.dart';
import 'package:streamit_laravel/screens/walletSection/models/walletModel.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';
// apna DB helper class ka path sahi se adjust kar lena

class WalletController extends GetxController {


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

  }

  void initWalletData() {
    clearData();
    getWallet();
    getPointHistory();
  }


  RxBool isLoading = true.obs;
  Rx<WalletData> walletData= WalletData().obs;
  RxList<PointHistory> pointHistory= <PointHistory>[].obs;
  RxString errorMessage = ''.obs;
  RxInt page= 1.obs;



  Future<void> getWallet() async {
    isLoading.value = true;
    try {

      await WalletApi().getWallet(
        onSuccess: (data) {
          walletData.value = data;
        },
        onError: (error) {
          errorMessage.value = error;
        },
        onFailure: (response) {
          errorMessage.value = response.body;
        },
      );

      isLoading.value = false;

    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getPointHistory({bool refresh = false}) async {

    try {

      if(refresh)
        {
          page.value = 1;
          pointHistory.clear();
          isLoading.value = true;
        }

      await WalletApi().getPointHistory(
        onSuccess: (data) {
         if(page.value==1)
           {
             pointHistory.value = data.data?.history ?? [];
           }
         else
           {
             pointHistory.addAll(data.data?.history ?? []);
           }
         if(data.data!.history!.isNotEmpty)
           {
             page.value++;
           }
         pointHistory.refresh();
        },
        onError: (error) {
          errorMessage.value = error;
        },
        onFailure: (response) {
          errorMessage.value = response.body;
        },
      );

      isLoading.value = false;

    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void loadMorePointHistory() {
    if(page.value>1)
      {
        getPointHistory();
      }
  }


  void clearData() {
    walletData.value = WalletData();
    pointHistory.clear();
    errorMessage.value = '';
    page.value = 1;
  }
}
