import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odisha_air_map/api_calls/api_helper.dart';

class ConnectHelper {
  final _flutterSecureStorage = const FlutterSecureStorage();
  final apiHelper = ApiHelper();
  // final _commonService = CommonService();

  /// To Save the data in the Device.
  /// [key] key of the data.
  /// [value] data that is to be stored in device.
  void saveValueSecurely({required String key, required String value}) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  /// To get Saved data from the Device.
  /// [key] key of the Data.
  Future<String> getSavedValue({required String key}) async {
    var value = await _flutterSecureStorage.read(key: key);
    if (value != null) {
      return value.toString();
    } else {
      return 'en';
    }
  }

  /// To delete particular key data in device.
  /// [key] key of the Data.
  void deleteSavedValue({required String key}) async {
    await _flutterSecureStorage.delete(key: key);
  }

  /// To delete all app related data from device.
  void deleteAllSavedValues() async {
    await _flutterSecureStorage.deleteAll();
  }
}
