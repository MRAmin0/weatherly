import 'package:connectivity_plus/connectivity_plus.dart';
// تغییر ۱: ایمپورت پکیج جدید (Plus)
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  static Future<bool> hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();

    // این بخش مربوط به Connectivity Plus است و کاملا درست است
    if (connectivity.isEmpty ||
        connectivity.contains(ConnectivityResult.none)) {
      return false;
    }

    // تغییر ۲ و ۳: استفاده از کلاس و متد جدید
    // این متد در وب هم کار می‌کند و دیگر کرش نمی‌کند
    return await InternetConnection().hasInternetAccess;
  }
}
