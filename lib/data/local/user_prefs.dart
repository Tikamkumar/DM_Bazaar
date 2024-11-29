import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {

  void saveToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('token', token);
  }

  Future getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('token');
  }

}