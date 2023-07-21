import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/Screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
        title: 'Twingo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: 
        // MyWebViewApp()
        Home(
          isInternetConnected: isInternetConnected,
        )
        );
  }
}
// class MyWebViewApp extends StatefulWidget {
//   @override
//   _MyWebViewAppState createState() => _MyWebViewAppState();
// }

// class _MyWebViewAppState extends State<MyWebViewApp> {
//   late InAppWebViewController _webViewController;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My WebView App'),
//       ),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse('https://twigo.date/')), // Replace with your website URL
//         onWebViewCreated: (controller) {
//           _webViewController = controller;
//         },
//         androidOnPermissionRequest: (controller, origin, resources) async {
//           return PermissionRequestResponse(
//             resources: resources,
//             action: PermissionRequestResponseAction.GRANT, // Grant camera permission
//           );
//         },
//       ),
//     );
//   }

// }
