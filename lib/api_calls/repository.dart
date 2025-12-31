
import 'connect_helper.dart';

class Repository {
  Repository(this._connectHelper);
  final ConnectHelper _connectHelper;

  /// To Save the data in the Device.
  /// [key] key of the data.
  /// [value] data that is to be stored in device.
  void saveValueSecurely(String key, String value) {
    _connectHelper.saveValueSecurely(key: key, value: value);
  }

  /// To get Saved data from the Device.
  /// [key] key of the Data.
  Future<String> getSavedValue(String key) async {
    return await _connectHelper.getSavedValue(key: key);
  }

  /// To delete particular key data in device.
  /// [key] key of the Data.
  void deleteSavedValue(String key) {
    _connectHelper.deleteSavedValue(key: key);
  }

  /// to delete all  value
  void deleteAllSavedValues() {
    _connectHelper.deleteAllSavedValues();
  }
}
