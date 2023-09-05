import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userProfileImageUrl = '';
  var _username = '';
  var _userPhone = '';
  var _userID = '';

  String get userProfileImageUrl => _userProfileImageUrl;

  String get username => _username;

  String get userphone => _userPhone;

  String get userid => _userID;

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _userID = sharedPref.getString(StorageKeys.userid) ?? '';
    _username = sharedPref.getString(StorageKeys.username) ?? '';
    _userPhone = sharedPref.getString(StorageKeys.userphone) ?? '';
    _userProfileImageUrl = sharedPref.getString(StorageKeys.userProfileImageUrl) ?? '';

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userProfileImageUrl,
    String? username,
    String? userphone,
    String? userid,
  }) async {
    final sharedPref = await SharedPreferences.getInstance();
    var shouldNotify = false;

    if (userProfileImageUrl != null && userProfileImageUrl != _userProfileImageUrl) {
      _userProfileImageUrl = userProfileImageUrl;

      await sharedPref.setString(StorageKeys.userProfileImageUrl, _userProfileImageUrl);

      shouldNotify = true;
    }

    if (username != null && username != _username) {
      _username = username;

      await sharedPref.setString(StorageKeys.username, _username);

      shouldNotify = true;
    }

    if (userphone != null && userphone != _userPhone) {
      _userPhone = userphone;

      await sharedPref.setString(StorageKeys.userphone, _userPhone);

      shouldNotify = true;
    }

    if (userid != null && userid != _userID) {
      _userID = userid;

      await sharedPref.setString(StorageKeys.userid, _userID);

      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> clearUserDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    await sharedPref.remove(StorageKeys.username);
    await sharedPref.remove(StorageKeys.userProfileImageUrl);
    await sharedPref.remove(StorageKeys.userphone);
    await sharedPref.remove(StorageKeys.userid);

    _userID = '';
    _username = '';
    _userPhone = '';
    _userProfileImageUrl = '';

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _username.isNotEmpty;
  }
}
