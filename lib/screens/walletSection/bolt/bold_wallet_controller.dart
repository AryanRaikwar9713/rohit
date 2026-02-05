
import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/app_lovin_ads/add_helper.dart';
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
  RxList<BolTransection> allTransactions = <BolTransection>[].obs; // Store all transactions

  RxInt historyPage = 1.obs;
  
  // Filter for transaction types
  RxString selectedFilter = 'all'.obs; // 'all', 'ads', 'social', 'donation'



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
    selectedFilter.value = 'all'; // Reset filter on refresh
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
              allTransactions.value = d.data?.transactions??[];
            }
          else
            {
              allTransactions.addAll(d.data?.transactions??[]);
            }
          hasMore.value = d.data?.pagination?.hasNext??false;
          
          // Apply filter
          applyFilter();

          allTransactions.refresh();
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

  // Filter transactions by type
  void applyFilter() {
    if (selectedFilter.value == 'all') {
      transactionList.value = allTransactions;
    } else {
      transactionList.value = allTransactions.where((transaction) {
        final type = (transaction.actionType ?? '').toLowerCase();
        switch (selectedFilter.value) {
          case 'ads':
            return type.contains('ad') || type.contains('reward');
          case 'social':
            return type.contains('like') || 
                   type.contains('comment') || 
                   type.contains('view') || 
                   type.contains('upload') || 
                   type.contains('reel') ||
                   type.contains('post');
          case 'donation':
            return type.contains('donation') || type.contains('donate');
          default:
            return true;
        }
      }).toList();
    }
    transactionList.refresh();
  }
  
  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }
  
  // Calculate total earnings by type
  double getAdsEarnings() {
    return allTransactions
        .where((t) => (t.actionType ?? '').toLowerCase().contains('ad') || 
                      (t.actionType ?? '').toLowerCase().contains('reward'))
        .fold(0.0, (sum, t) => sum + (t.boltAmount ?? 0));
  }
  
  double getSocialEarnings() {
    return allTransactions
        .where((t) {
          final type = (t.actionType ?? '').toLowerCase();
          return type.contains('like') || 
                 type.contains('comment') || 
                 type.contains('view') || 
                 type.contains('upload') || 
                 type.contains('reel') ||
                 type.contains('post');
        })
        .fold(0.0, (sum, t) => sum + (t.boltAmount ?? 0));
  }
  
  double getDonationSpent() {
    return allTransactions
        .where((t) => (t.actionType ?? '').toLowerCase().contains('donation') || 
                      (t.actionType ?? '').toLowerCase().contains('donate'))
        .fold(0.0, (sum, t) => sum + (t.boltAmount ?? 0).abs());
  }

  // Watch Ad and get reward
  RxBool isWatchingAd = false.obs;

  Future<void> watchAdForReward() async {
    if (isWatchingAd.value) {
      toast('Please wait, ad is loading...');
      return;
    }
    
    if (!AdLovinHelper.isRewardedReady) {
      toast('Ad is not ready yet. Please wait...');
      AdLovinHelper.loadRewarded();
      return;
    }
    
    try {
      isWatchingAd.value = true;
      
      // Set reward callback before showing ad
      AdLovinHelper.setRewardCallback(() async {
        Logger().i('Reward received, calling API...');
        // Call API to reward 0.01 bolt
        await BoltApi().watchAdRewardBolt(
          showToast: true,
          onError: (e) {
            Logger().e('Error rewarding bolt: $e');
            toast('Failed to reward bolt: $e');
            isWatchingAd.value = false;
          },
          onFailure: (response) {
            Logger().e('Failed to reward bolt: ${response.statusCode}');
            try {
              final error = jsonDecode(response.body);
              toast(error['message'] ?? 'Failed to reward bolt');
            } catch (_) {
              toast('Failed to reward bolt');
            }
            isWatchingAd.value = false;
          },
          onSuccess: (data) {
            Logger().i('Bolt rewarded successfully: $data');
            toast('🎉 You earned 0.01 Bolt!');
            // Refresh wallet data
            getDashBoardData();
            getTransectiom(refresh: true);
            isWatchingAd.value = false;
          },
        );
      });
      
      // Show rewarded ad
      AdLovinHelper.showRewarded();
      
      // Reset callback after timeout (if ad doesn't complete)
      Future.delayed(const Duration(seconds: 60), () {
        if (isWatchingAd.value) {
          AdLovinHelper.setRewardCallback(null);
          isWatchingAd.value = false;
        }
      });
    } catch (e) {
      Logger().e('Error watching ad: $e');
      toast('Error: $e');
      isWatchingAd.value = false;
      AdLovinHelper.setRewardCallback(null);
    }
  }

}