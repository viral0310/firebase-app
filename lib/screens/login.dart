import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app/helper/fcm%20hepler.dart';
import 'package:firebase_app/helper/firebase_auth_helper.dart';
import 'package:firebase_app/helper/local_notifications_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../global.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> with WidgetsBindingObserver {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> signInformKey = GlobalKey<FormState>();
  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPasswordController = TextEditingController();
  fetchToken() async {
    String? token = await FCMHelper.fcmHelper.fetchFCMToken();
    print("--------------------------------------");
    print(token);
    print("--------------------------------------");
  }

  @override
  void initState() {
    super.initState();

    //api
    ApiHelper.apiHelper.getApi();
    //FCM token
    fetchToken();
    //FCM notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');

      if (message.data != null) {
        print('Message data: ${message.data}');
      }
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    //local notification
    WidgetsBinding.instance.addObserver(this);
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("mipmap/ic_launcher");

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    tz.initializeTimeZones();

    LocalNotificationHelper.flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
            onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("***************************************");
      print(response.payload);
      print("***************************************");
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("----------------------------------");
    print("Current State: $state");
    print("----------------------------------");

    if (state == AppLifecycleState.paused) {
      print("*************************");
      print("FETCH API");
      print("*************************");
    } else if (state == AppLifecycleState.resumed) {
      print("*************************");
      print("Welcome Back");
      print("*************************");
    } else if (state == AppLifecycleState.detached) {
      print("*************************");
      print("Store Data into db");
      print("*************************");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login page"),
        centerTitle: true,
      ),
      body: Column(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await LocalNotificationHelper.localNotificationHelper
                  .sendSimpleNotification();
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent),
            child: const Text("simple notification"),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalNotificationHelper.localNotificationHelper
                  .sendScheduledNotification();
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent),
            child: const Text("scheduled notification"),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalNotificationHelper.localNotificationHelper
                  .sendBigPictureNotification();
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent),
            child: const Text("Big picture notification"),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalNotificationHelper.localNotificationHelper
                  .sendMediaStyleNotification();
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent),
            child: const Text("Media Style notification"),
          ),
          ElevatedButton(
            onPressed: () async {
              var connectivityResult =
                  await (Connectivity().checkConnectivity());
              if (connectivityResult == ConnectivityResult.wifi) {
                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signInAnonymously();
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Login Successfully\n${user.uid}"),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context)
                      .pushReplacementNamed('home_page', arguments: user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Log In failed"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                // I am connected to a mobile network.
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("please on MobileData or wifi"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("anonymous"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: detailsOfSignUp, child: const Text("Sign Up")),
              ElevatedButton(
                  onPressed: detailsOfSignIn, child: const Text("Sign In")),
            ],
          ),
          ElevatedButton(
              onPressed: () async {
                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signInWithGoogle();
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Login Successfully\n${user.uid}"),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context)
                      .pushReplacementNamed('home_page', arguments: user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Log In failed"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Sign Up With Google"))
        ],
      ),
    );
  }

  detailsOfSignUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign up"),
        content: SizedBox(
          height: 300,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter email first" : null,
                  onSaved: (val) {
                    Global.email = val!;
                  },
                  controller: emailController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "password"),
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter password first" : null,
                  onSaved: (val) {
                    Global.password = val;
                  },
                  controller: passwordController,
                  obscureText: true,
                )
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signUpUser(
                        email: Global.email!, password: Global.password!);
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign up Successfully\n${user.uid}"),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context)
                      .pushReplacementNamed('home_page', arguments: user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sign Up failed"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                print("-----------------------");
                print(Global.email);
                print(Global.password);
                print("------------------------");
                setState(
                  () {
                    emailController.clear();
                    passwordController.clear();
                    Global.email = "";
                    Global.password = "";
                    Navigator.of(context).pop();
                  },
                );
              }
            },
            child: const Text("Sign Up"),
          ),
          ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    emailController.clear();
                    passwordController.clear();
                    Global.email = "";
                    Global.password = "";
                    Navigator.of(context).pop();
                  },
                );
              },
              child: const Text("Cansel"))
        ],
      ),
    );
  }

  detailsOfSignIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign In"),
        content: SizedBox(
          height: 300,
          child: Form(
            key: signInformKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter email first" : null,
                  onSaved: (val) {
                    Global.email = val!;
                  },
                  controller: signInEmailController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "password"),
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter password first" : null,
                  onSaved: (val) {
                    Global.password = val;
                  },
                  controller: signInPasswordController,
                  obscureText: true,
                )
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (signInformKey.currentState!.validate()) {
                signInformKey.currentState!.save();

                User? user = await FirebaseAuthHelper.firebaseAuthHelper
                    .signInUser(
                        email: Global.email!, password: Global.password!);
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sign in Successfully\n${user.uid}"),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context)
                      .pushReplacementNamed('home_page', arguments: user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sign In failed"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                //with the places
                print("-----------------------");
                print(Global.email);
                print(Global.password);
                print("------------------------");

                setState(
                  () {
                    signInEmailController.clear();
                    signInPasswordController.clear();
                    Global.email = "";
                    Global.password = "";
                    // Navigator.of(context).pop();
                  },
                );
              }
            },
            child: const Text("Sign In"),
          ),
          ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    signInEmailController.clear();
                    signInPasswordController.clear();
                    Global.email = "";
                    Global.password = "";
                    Navigator.of(context).pop();
                  },
                );
              },
              child: const Text("Cancel"))
        ],
      ),
    );
  }
}
