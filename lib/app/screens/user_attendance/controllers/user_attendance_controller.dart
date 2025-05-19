import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import '../../../utils/app_constants.dart';

class UserAttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var attendanceStatus = ''.obs;
  var errorMessage = ''.obs;
  var isAttendanceMarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeLocationAndAttendance(); // Call your combined initializer
  }

  Future<void> initializeLocationAndAttendance() async {
    isLoading.value = true;
    errorMessage.value = '';

    bool permissionGranted = await _checkLocationPermission();
    if (!permissionGranted) {
      errorMessage.value = AppConstants.LOCATION_PERMISSION_DENIED;
      isLoading.value = false;
      return;
    }

    Position? position = await _getCurrentLocation();
    if (position == null) {
      errorMessage.value = 'Could not get location data.';
      isLoading.value = false;
      return;
    }

    await fetchAttendance();
  }

  Future<bool> _checkLocationPermission() async {
    var status = await perm.Permission.location.status;
    if (status.isGranted) return true;
    var result = await perm.Permission.location.request();
    return result.isGranted;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'androidVersion': androidInfo.version.release,
          'device': androidInfo.device,
          'id': androidInfo.id,
        };
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'model': iosInfo.utsname.machine,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'systemName': iosInfo.systemName,
          'id': iosInfo.identifierForVendor,
        };
      } else {
        return {'platform': 'unknown'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> markAttendance() async {
    isLoading.value = true;
    errorMessage.value = '';

    bool permissionGranted = await _checkLocationPermission();
    if (!permissionGranted) {
      isLoading.value = false;
      errorMessage.value = AppConstants.LOCATION_PERMISSION_DENIED;
      return;
    }

    Position? position = await _getCurrentLocation();
    if (position == null) {
      isLoading.value = false;
      errorMessage.value = 'Could not get location data.';
      return;
    }

    Map<String, dynamic> deviceInfo = await _getDeviceInfo();
    String userId =
        deviceInfo['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    DateTime now = DateTime.now();

    try {
      await _firestore.collection('attendance').doc(userId).set({
        'timestamp': now.toIso8601String(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'device_info': deviceInfo,
        'status': 'present',
      });

      final formattedTime = DateFormat('hh:mm a').format(now);

      String deviceInfoText = '''
Model: ${deviceInfo['model'] ?? 'N/A'}
Manufacturer: ${deviceInfo['manufacturer'] ?? 'N/A'}
Device: ${deviceInfo['device'] ?? 'N/A'}
Android Version: ${deviceInfo['androidVersion'] ?? 'N/A'}
''';

      attendanceStatus.value =
      "Status: PRESENT at $formattedTime\n\nDevice Info:\n$deviceInfoText";
      isAttendanceMarked.value = true;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error saving attendance: $e';
      isLoading.value = false;
    }
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    errorMessage.value = '';
    isAttendanceMarked.value = false;

    Map<String, dynamic> deviceInfo = await _getDeviceInfo();
    String userId = deviceInfo['id'] ?? '';

    if (userId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'Could not get device ID for fetching attendance.';
      return;
    }

    try {
      DocumentSnapshot doc =
      await _firestore.collection('attendance').doc(userId).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        final timestamp = DateTime.tryParse(data['timestamp'] ?? '');
        final formattedTime = timestamp != null
            ? DateFormat('hh:mm a').format(timestamp)
            : 'Invalid time';

        final status = data['status'] ?? 'Unknown';
        final device = data['device_info'] ?? {};

        String deviceInfoText = '''
Model: ${device['model'] ?? 'N/A'}
Manufacturer: ${device['manufacturer'] ?? 'N/A'}
Device: ${device['device'] ?? 'N/A'}
Android Version: ${device['androidVersion'] ?? 'N/A'}
''';

        attendanceStatus.value =
        "Status: $status at $formattedTime\n\nDevice Info:\n$deviceInfoText";
        isAttendanceMarked.value = true;
      } else {
        attendanceStatus.value = 'No attendance record found.';
        isAttendanceMarked.value = false;
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching attendance: $e';
      isLoading.value = false;
    }
  }
}
