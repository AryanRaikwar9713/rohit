import 'package:flutter/material.dart';


class WamimsNotificationScreen extends StatelessWidget {
  const WamimsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
        title: const Text("Notifications"),
      ),
      
      body: const Center(
        child: Text("No Notifications",style: TextStyle(color: Colors.white,fontSize: 20),),
      ),
    );
  }
}
