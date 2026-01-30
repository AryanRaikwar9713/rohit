import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_wallet_screen.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_screen.dart';



class WalletTabManage extends StatelessWidget {
  const WalletTabManage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(

      appBar: AppBar(
        title: const Text("💵 Your Wallet"),

        titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),

        bottom:  TabBar(

          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(colors: [
              Color(0xff232526),
              Color(0xff414345),
            ])
          ),
          indicatorPadding: EdgeInsetsGeometry.symmetric(horizontal: 16,vertical: 5),
          labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w900,fontSize: 16),
          unselectedLabelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w900,fontSize: 16),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "Point Wallet"),
            Tab(text: "Bolt"),
          ],
        ),
      ),

      body:const TabBarView(children: [
        WalletScreen(),
        BoltWalletScreen(),
      ]),

    ));
  }
}



