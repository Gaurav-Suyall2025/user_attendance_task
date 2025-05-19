import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../utils/app_constants.dart';
import '../controllers/user_attendance_controller.dart';

class AttendanceScreen extends GetView<UserAttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.errorMessage.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    if (controller.errorMessage.value ==
                        AppConstants.LOCATION_PERMISSION_DENIED) {
                      await Geolocator.openAppSettings();
                      controller.initializeLocationAndAttendance();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (controller.attendanceStatus.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.attendanceStatus.value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              if (!controller.isAttendanceMarked.value)
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Mark Attendance Present'),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.markAttendance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: const Text('Attendance Already Marked'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Attendance Status'),
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchAttendance,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
