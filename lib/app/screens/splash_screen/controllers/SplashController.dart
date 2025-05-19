

import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/routes/app_pages.dart';

class SplashController extends GetxController {

  @override
  Future<void> onInit() async {
    super.onInit();

    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
          () {
        Get.offAllNamed(Routes.USER_ATTENDANCE);
      },
    );
  }

}