import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  static Future<bool> hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isEmpty ||
        connectivity.contains(ConnectivityResult.none)) {
      return false;
    }

    return await InternetConnectionChecker().hasConnection;
  }
}
