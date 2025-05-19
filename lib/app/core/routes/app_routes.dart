part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const USER_ATTENDANCE = _Paths.USER_ATTENDANCE;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/SPLASH';
  static const USER_ATTENDANCE = '/USER_ATTENDANCE';
}