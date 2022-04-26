import 'dart:io';

import 'package:brotherquickstart/home.dart';
import 'package:flutter/material.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '4Site hacks',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home(
          title: "4Site Hacks",
        )
        // home: const Home(title: 'Home')
        );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // this is for OLD OLD OLD phones/simulators that don't have Certificate Authority updates
    // DON'T DO THIS IN PRODUCTION
    // security issue for 'man in the middle'
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint("MyApp:X509Certificate.issuer        ${cert.issuer}");
        debugPrint("MyApp:X509Certificate.startValidity ${cert.startValidity}");
        debugPrint("MyApp:X509Certificate.endValidity   ${cert.endValidity}");
        // debugPrint("MyApp:X509Certificate ${cert.pem}");
        debugPrint("MyApp:X509Certificate.subject       ${cert.subject}");
        debugPrint("MyApp:String.host                   $host");
        debugPrint("MyApp:int.port                      $port");
        return true;
      };
  }
}
