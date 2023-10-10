import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class FirebaseApi {


  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage storage;

  FirebaseApi({required this.storage});

  Future<void> initNotification() async{
    // Get permission from the user
    await _firebaseMessaging.requestPermission();
    // Get FCM Token
    final fcToken = await _firebaseMessaging.getToken();
    await storage.write(key: 'fc_token', value: fcToken);
    print('Token: $fcToken');
  }
}