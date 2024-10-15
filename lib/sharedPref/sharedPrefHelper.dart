import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;
  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<String> putUserIdValue(value) async {
    return sharedPreferences!.setString('userId', value).toString();
  }

  static String? getUserIdValue() {
    return sharedPreferences!.getString('userId');
  }
}
