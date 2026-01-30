


import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/boalt_wallet_responce_model.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_api.dart';
import 'package:http/http.dart' as http;
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_transection_responce_model.dart';


class BoaltWalletController extends GetxController
{


  Rx<BoltWalletApiResponce> dashboardData = BoltWalletApiResponce().obs;
  RxBool isLoading = false.obs;
  RxBool historyLoading = false.obs;
  RxBool hasMore = true.obs;


  RxList<BolTransection> transactionList = <BolTransection>[].obs;

  RxInt historyPage = 1.obs;



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _init();
  }



  _init(){
    getDashBoardData();
    getTransectiom(refresh:  true);
  }



  refresh() async
  {
    getDashBoardData();
    getTransectiom(refresh: true);
  }

  getDashBoardData() async
  {
      // try
      //     {
          isLoading.value = true;

          await BoltApi().getBoltDashboard(
            onSuccess: (data) {
              dashboardData.value = data;
            },
            onError:_handelError,
            onFailure: _handelResponce,
          );
    //     }
    //     catch(e)
    // {
    //   Logger().e("Error $e");
    // }
    isLoading.value = false;

  }


  getTransectiom({bool refresh =false}) async
  {

    if(refresh)
      {
        historyPage.value=1;
      }
    historyLoading.value = true;

    await BoltApi().getBoltTransactions(
        page: historyPage.value, onError: onError, onFailure: _handelResponce, onSuccess: (d){

          if(historyPage.value==1)
            {
              transactionList.value = d.data?.transactions??[];
            }
          else
            {
              transactionList.addAll(d.data?.transactions??[]);
            }
          hasMore.value = d.data?.pagination?.hasNext??false;

          transactionList.refresh();
        });

  }

  loadMore()async
  {
    if(hasMore.value)
      {
        historyPage.value++;
        getTransectiom(refresh: false);
      }
  }



  _handelResponce(http.Response resp)
  {
    try
    {

    }
    catch(e)
    {
      Logger().e("Error $e");
    }
  }

  _handelError(String e)
  {
    Logger().e('Errpr $e');
    toast(e);
  }



}