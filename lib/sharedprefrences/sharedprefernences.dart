import 'package:shared_preferences/shared_preferences.dart';

class Sharedpreference {
  static Future<void> setuser(
    String name,
    String phonenumber,
    String location,
    String email,
    int salary,
    String age,
    double lat,
    double long,
    double worklat,
    double worklong,
    int starthour,
    int endhour,
    int startmin,
    int endmin,
    bool logedin,
    String token,
    bool checkin,
    List permissions,
    List workdays,
  ) async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    List<String> permissionsString =
        permissions.map((e) => e.toString()).toList();
    preference.setString('name', name);
    preference.setString('phonenumber', phonenumber);
    preference.setString('location', location);
    preference.setString('email', email);
    preference.setInt('salary', salary);
    preference.setString('age', age);
    preference.setDouble('lat', lat);
    preference.setDouble('long', long);
    preference.setDouble('worklat', worklat);
    preference.setDouble('worklong', worklong);
    preference.setInt('starthour', starthour);
    preference.setInt('endhour', endhour);
    preference.setInt('startmin', startmin);
    preference.setInt('endmin', endmin);
    preference.setBool('logedin', logedin);
    preference.setBool('checkin', checkin);
    preference.setString('token', token);
    // preference.setStringList('weekdays', List<String>.from(workdays));//atwane aw string y lista labay agar error bw
    preference.setStringList(
        'weekdays', workdays.map((e) => e.toString()).toList());
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
