import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMHelper {
  FCMHelper._();
  static final FCMHelper fcmHelper = FCMHelper._();
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //todo: fetchFCMToken
  Future<String?> fetchFCMToken() async {
    String? token = await firebaseMessaging.getToken();
    return token;
  }
}

class ApiHelper {
  ApiHelper._();
  static final ApiHelper apiHelper = ApiHelper._();

  String api = "https://fcm.googleapis.com/fcm/send";
  String SERVER_KEY =
      "AAAAUrrNYys:APA91bH52kdwtkdCWKgySWWc8o68Lalgd25yX9qR-H9sT8pyC9j1uJahJiKCdE24X3mnu6x4vVutClVdf0b09KY8BNKtOi7rSdRf-2bZlqWvn20XA4tRwzd89q6ZrKRW-sVDnT4OsYax";

  getApi() async {
    http.Response res = await http.post(
      Uri.parse(api),
      body: jsonEncode(
        {
          "to":
              "drBW_EfcTJ-1uOe9ekZd9S:APA91bF6MdBVacnNMJ4F-zVynKv9dB6fjmxYZ_ge7A6-ip4Z6AEtTE0oY2s9RFqRrECM2bIYr4cmq7Ip04c2YDpc-ifRxxa0H_dG5qrYYA3iMYlEmMzq93BMi4JVWS__BPLFJ1FD1r1Q",
          "notification": {
            "content_available": true,
            "priority": "high",
            "title": "hello",
            "body": "My Body"
          },
          "data": {
            "priority": "high",
            "content_available": true,
            "school": "RWN",
            "age": "22"
          }
        },
      ),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'key=$SERVER_KEY'
      },
    );

    if (res.statusCode == 200) {
      Function data = jsonDecode(res.body);
      print("***************************");
      print(data);
    }
  }
}
