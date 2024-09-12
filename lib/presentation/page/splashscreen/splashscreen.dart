import 'package:flutter/material.dart';
import 'package:tes/presentation/page/splashscreen/carousel_slider.dart';
import 'package:tes/presentation/page/splashscreen/theme.dart';
import 'dart:async';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 10), () {
      if (mounted) {
        // Navigasi ke halaman berikutnya setelah 6 detik
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FullscreenSliderDemo()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bluecolor, // Warna biru
        child: Center(
          child: Image.asset(
            "asset/logosplash1.png",
            width: 331,
            height: 374,
          ),
        ),
      ),
    );
  }
}
