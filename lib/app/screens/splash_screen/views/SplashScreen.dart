import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_attendance_task/app/images/images.dart';
import 'package:user_attendance_task/app/screens/splash_screen/controllers/SplashController.dart';

class SplashScreen extends GetView<SplashController> {
  final splashController = Get.find<SplashController>();

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Image.asset(
              Images.logo,
            )
        ),);
  }
}
