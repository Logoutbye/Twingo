import 'dart:io';

import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/Screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  //donot know much but got it from inappwebview offical documentation will check later
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(":::$request");
          return null;
        },
      ));
    }
  }
  await checkInternetConnectionForDashboard();
  runApp(MyApp());
}

var isInternetConnected = false;
checkInternetConnectionForDashboard() async {
  // to check the internet connection
  await CheckInternetConnection.checkInternetFunction();

  if (!CheckInternetConnection.checkInternet) {
    isInternetConnected = false;
  } else {
    isInternetConnected = true;
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Twigo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:
            // MyWebViewApp()
            Home(
          isInternetConnected: isInternetConnected,
        ));
  }
}
