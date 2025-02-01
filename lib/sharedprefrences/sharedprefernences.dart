import 'package:shared_preferences/shared_preferences.dart';

class Sharedpreference {
  static Future<void> setuser(
      String name,
      String phonenumber,
      String location,
      String email,
      String salary,
      String age,
      double lat,
      double long,
      double worklat,
      double worklong,
      bool logedin,
      String token,
      bool checkin,
      List permissions) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    List<String> permissionsString =
        permissions.map((e) => e.toString()).toList();
    preference.setString('name', name);
    preference.setString('phonenumber', phonenumber);
    preference.setString('location', location);
    preference.setString('email', email);
    preference.setString('salary', salary);
    preference.setString('age', age);
    preference.setDouble('lat', lat);
    preference.setDouble('long', long);
    preference.setDouble('worklat', worklat);
    preference.setDouble('worklong', worklong);
    preference.setBool('logedin', logedin);
    preference.setBool('checkin', checkin);
    preference.setString('token', token);
    preference.setStringList('permissions', permissionsString);
  }

  static Future<void> checkin(
      String time, double lat, double long, bool checkin) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setString('time', time);
    preference.setDouble('lat', lat);
    preference.setDouble('long', long);
    preference.setBool('checkin', checkin);
  }
}
