import 'package:flutter/material.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_wallet_screen.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_screen.dart';



class WalletTabManage extends StatelessWidget {
  const WalletTabManage({super.key});

  @override
  Widget build(BuildContext context) {
    // If Point Wallet is disabled, show only Bolt screen
    if (!ENABLE_POINT_WALLET_SYSTEM) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("💵 Your Wallet"),
          titleTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const BoltWalletScreen(),
      );
    }
    
    // If Point Wallet is enabled, show tabs
    return DefaultTabController(length: 2, child: Scaffold(

      appBar: AppBar(
        title: const Text("💵 Your Wallet"),

        titleTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),

        bottom:  TabBar(

          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(colors: [
              Color(0xff232526),
              Color(0xff414345),
            ],),
          ),
          indicatorPadding: const EdgeInsetsGeometry.symmetric(horizontal: 16,vertical: 5),
          labelStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w900,fontSize: 16),
          unselectedLabelStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w900,fontSize: 16),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "Bolt"),
            Tab(text: "Point Wallet"),
          ],
        ),
      ),

      body:const TabBarView(children: [
        BoltWalletScreen(),
        WalletScreen(),
      ],),

    ),);
  }
}



