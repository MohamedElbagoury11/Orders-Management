import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceHelper {
  static const String _deviceIdKey = 'device_id';
  static const Uuid _uuid = Uuid();

  /// Get a unique device identifier
  /// Generates a UUID on first run and stores it in SharedPreferences
  /// Returns the same UUID on subsequent calls
  static Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if device ID already exists
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        // Generate new UUID for this device
        deviceId = _uuid.v4();

        // Store it for future use
        await prefs.setString(_deviceIdKey, deviceId);

        print('Generated new device ID: $deviceId');
      } else {
        print('Retrieved existing device ID: $deviceId');
      }

      return deviceId;
    } catch (e) {
      print('Error getting device ID: $e');
      // Return a fallback UUID if there's an error
      return _uuid.v4();
    }
  }

  /// Clear the stored device ID (useful for testing)
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      print('Device ID cleared');
    } catch (e) {
      print('Error clearing device ID: $e');
    }
  }
}
