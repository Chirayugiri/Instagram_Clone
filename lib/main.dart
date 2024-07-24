import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram/login.dart';
import 'package:instagram/screens/addPostScreen.dart';
import 'package:instagram/screens/homeScreen.dart';
import 'package:instagram/screens/navBar.dart';
import 'package:instagram/screens/notificationScreen.dart';
import 'package:instagram/screens/reelsScreen.dart';
import 'package:instagram/screens/splashScreen.dart';
import 'package:instagram/screens/webScreen.dart';
import 'package:instagram/signup.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {                                 //to initialize firebase for web
    await Firebase.initializeApp(
      options: const  FirebaseOptions(
        apiKey: "AIzaSyB7PhRHAa9N5UTARXeYuK7_5feSoKqzmjQ",
        appId: "1:318624843815:web:8c260891dfaffe66476602",
        messagingSenderId: "318624843815",
        projectId: "instagram-clone-3f367",
        storageBucket: "instagram-clone-3f367.appspot.com",
      ),
    );
  } else {                                //not for web
    await Firebase.initializeApp();
  }
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(), // Wrap your app
    // ),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      // darkTheme: ThemeData.dark(),

      routes: {
        '/loginScreen': (context) => LoginScreen(),
        '/signupScreen': (context) => SignUpScreen(),
        '/mobileScreen': (context) => NavBarScreen(),
        '/webScreen': (context) => WebScreenLayout(),
        '/homeScreen': (context) => HomeScreen(),
        '/navBarScreen': (context) => NavBarScreen(),
        '/addPostScreen': (context) => AddPostScreen(),
        '/notificationScreen': (context) => NotificationScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),

    );
  }
}
