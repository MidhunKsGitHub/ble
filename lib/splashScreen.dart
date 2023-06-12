

import 'dart:async';


import 'package:ble/home_screen.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>  const HomeScreen())));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,

        ///appbar

        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
        ),

        ///body

        body: const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.bluetooth,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
