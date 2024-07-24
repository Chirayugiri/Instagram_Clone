import 'package:flutter/material.dart';
import 'package:instagram/main2.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 2600), () {
      // Navigate to the next page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main2()),);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: LottieBuilder.asset('assets/splash_anim.json'),
        ),
      ),
    );
  }
}
