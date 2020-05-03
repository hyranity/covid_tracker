import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationManager{
  NotificationManager._();

  factory NotificationManager() => _instance;
  static final NotificationManager _instance = NotificationManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async{
    if(!_initialized){
      //iOS config
      // _firebaseMessaging.requestNotificationPermissions();
      // _firebaseMessaging.configure();

      _initialized = true;
      print("Token" + await _firebaseMessaging.getToken());
    }
  }
}