import 'package:flutter/material.dart';


class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Board"),
      ),
      
      body:  const Center(
        child: Text("Comming Soon",style: TextStyle(color: Colors.white),),
        
      ),
    );
  }
}
