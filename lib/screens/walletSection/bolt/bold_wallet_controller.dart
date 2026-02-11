
import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/app_lovin_ads/add_helper.dart';
import 'package:streamit_laravel/components/admob_rewarded_ad_helper.dart';
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
  
  // Filter for transaction types - Simplified to 2 types
  RxString selectedFilter = 'earnings'.obs; // 'earnings', 'donations'



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _init();
  }



  void _init(){
    getDashBoardData();
    getTransectiom(refresh:  true);
    // Pre-load AdMob rewarded ad so it's ready when user taps
    AdMobRewardedAdHelper.loadRewardedAd();
  }



  @override
  Future<void> refresh() async
  {
    getDashBoardData();
    getTransectiom(refresh: true);
    selectedFilter.value = 'earnings'; // Reset filter on refresh
  }

  Future<void> getDashBoardData() async
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


  Future<void> getTransectiom({bool refresh =false}) async
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
        },);

  }

  Future<void> loadMore()async
  {
    if(hasMore.value)
      {
        historyPage.value++;
        getTransectiom();
      }
  }



  void _handelResponce(http.Response resp)
  {
    try
    {

    }
    catch(e)
    {
      Logger().e("Error $e");
    }
  }

  void _handelError(String e)
  {
    Logger().e('Errpr $e');
    toast(e);
  }

  // Filter transactions by type - Simplified to 2 types
  void applyFilter() {
    transactionList.value = allTransactions.where((transaction) {
      final type = (transaction.actionType ?? '').toLowerCase();
      if (selectedFilter.value == 'earnings') {
        // Show all earnings: ads, rewards, social activities
        return type.contains('ad') || 
               type.contains('reward') ||
               type.contains('like') || 
               type.contains('comment') || 
               type.contains('view') || 
               type.contains('upload') || 
               type.contains('reel') ||
               type.contains('post') ||
               (transaction.boltAmount ?? 0) > 0; // Positive amounts are earnings
      } else if (selectedFilter.value == 'donations') {
        // Show only donations
        return type.contains('donation') || type.contains('donate');
      }
      return true;
    }).toList();
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
                      (t.actionType ?? '').toLowerCase().contains('reward'),)
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
                      (t.actionType ?? '').toLowerCase().contains('donate'),)
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

  // Watch AdMob Ad and get reward
  Future<void> watchAdMobForReward() async {
    if (isWatchingAd.value) {
      toast('Please wait, ad is loading...');
      return;
    }
    
    try {
      isWatchingAd.value = true;
      if (!AdMobRewardedAdHelper.isRewardedAdReady) {
        toast('Loading ad, please wait...');
      }
      
      // Show AdMob rewarded ad (will load and wait if not ready)
      final shown = await AdMobRewardedAdHelper.showRewardedAd(
        onRewardReceived: () async {
          Logger().i('AdMob Reward received, calling API...');
          await BoltApi().watchAdRewardBolt(
            onError: (e) {
              Logger().e('Error rewarding bolt: $e');
              toast('Failed to reward bolt: $e');
              isWatchingAd.value = false;
            },
            onFailure: (response) {
              Logger().e('Reward API failed: ${response.statusCode} - ${response.body}');
              try {
                final error = jsonDecode(response.body);
                final msg = error['message'] ?? 'Failed to reward bolt';
                toast(msg);
              } catch (_) {
                toast('Failed to reward bolt (${response.statusCode})');
              }
              isWatchingAd.value = false;
            },
            onSuccess: (data) {
              Logger().i('Bolt rewarded successfully: $data');
              toast('🎉 You earned 0.01 Bolt!');
              getDashBoardData();
              getTransectiom(refresh: true);
              isWatchingAd.value = false;
            },
          );
        },
      );
      if (!shown) {
        toast('Ad not ready. Please try again or use App Lovin.');
        isWatchingAd.value = false;
      }
    } catch (e) {
      Logger().e('Error watching AdMob ad: $e');
      toast('Error: $e');
      isWatchingAd.value = false;
    }
  }

}