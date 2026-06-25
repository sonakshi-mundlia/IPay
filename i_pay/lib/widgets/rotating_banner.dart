import 'dart:async';
import 'package:flutter/material.dart';

class RotatingBanner extends StatefulWidget {
  const RotatingBanner({super.key});

  @override
  State<RotatingBanner> createState() => _RotatingBannerState();
}

class _RotatingBannerState extends State<RotatingBanner> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> images = [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(hours: 3),
          (timer) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % images.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        images[_currentIndex],
        fit: BoxFit.cover,
      ),
    );
  }
}
