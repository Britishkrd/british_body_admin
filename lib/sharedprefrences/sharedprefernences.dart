import 'package:shared_preferences/shared_preferences.dart';

class Sharedpreference {
  static Future<void> setuser(String name, String phonenumber,String  location,String email,String salary,String age,
      double lat, double long, bool logedin, String token,bool checkin) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setString('name', name);
    preference.setString('phonenumber', phonenumber);
    preference.setString('location', location);
    preference.setString('email', email);
    preference.setString('salary', salary);
    preference.setString('age', age);
    preference.setDouble('lat', lat);
    preference.setDouble('long', long);
    preference.setBool('logedin', logedin);
    preference.setBool('checkin', checkin);
    preference.setString('token', token);
  }


  static Future<void> checkin(String time,double lat,double long,bool checkin) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setString('time', time);
    preference.setDouble('lat', lat);
    preference.setDouble('long', long);
    preference.setBool('checkin', checkin);
  }
}
