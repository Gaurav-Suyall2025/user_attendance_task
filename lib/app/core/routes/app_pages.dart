import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:user_attendance_task/app/screens/splash_screen/bindings/SplashBinding.dart';
import 'package:user_attendance_task/app/screens/splash_screen/views/SplashScreen.dart';
import 'package:user_attendance_task/app/screens/user_attendance/bindings/user_attendance_binding.dart';

import '../../screens/user_attendance/views/user_attendance.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.USER_ATTENDANCE,
      page: () => AttendanceScreen(),
      binding: UserAttendanceBinding(),
    )
  ];
}
