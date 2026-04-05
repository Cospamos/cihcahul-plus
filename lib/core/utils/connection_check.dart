import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> hasInternet() async {
  final checker = InternetConnectionChecker.createInstance();
  return await checker.hasConnection;
}
