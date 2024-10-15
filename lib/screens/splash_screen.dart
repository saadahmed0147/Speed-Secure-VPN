import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../helpers/ad_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      //exit full-screen
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();

      //navigate to home
      Get.off(() => HomeScreen());
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xff13162b),
      body: Stack(
        children: [

          Center(
            child: Icon(
            Icons.rocket_launch_outlined,
            color: Colors.white,
            size: mq.height * .08,
                    ),
          ),
        ],
      ),
    );
  }
}
