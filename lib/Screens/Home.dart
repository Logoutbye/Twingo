import 'dart:async';
import 'dart:io';

import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/constants.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
    required this.isInternetConnected,
  }) {}

  bool isInternetConnected;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late InAppWebViewController _webViewController;
  late PullToRefreshController pullToRefreshController;
  final InAppBrowser browser = InAppBrowser();

  bool? _isRefreshing;

  double? progress;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          browser.webViewController.reload();
          print("refreshing");
        } else if (Platform.isIOS) {
          browser.webViewController.loadUrl(
              urlRequest:
                  URLRequest(url: await browser.webViewController.getUrl()));
        }
      },
    );
    browser.pullToRefreshController = pullToRefreshController;
    checkInternetConnectionForDashboard();

    requestPermissions();
    FacebookAudienceNetwork.init(
        //testingId: "a77955ee-3304-4635-be65-81029b0f5201", //optional
        iOSAdvertiserTrackingEnabled: true //default false
        );
    super.initState();

    if (IsInternetConnected == true) {
      setState(() {
        _loadBannerAdd();
      });

      setState(() {
        _loadInterstitialAd();
      });
    }
  }

  String url = 'https://twigo.date/';

  var IsInternetConnected = true;
  bool loader = false;
  // final _webViewController = Completer<WebViewController>();
  double _progress = 0.0; // Variable to hold the progress percentage
  bool _isLoading = true;
  int _progressText = 0; // Variable to track loading state

  FacebookBannerAd? facebookBannerAd;
  bool _isInterstitialAdLoaded = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // _showInterstitalAd();
        if (_webViewController != null) {
          bool canGoBack = await _webViewController.canGoBack();
          if (canGoBack) {
            _webViewController.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: MyColors.kprimaryColor,
            elevation: 0,
          ),
        ),
        body: IsInternetConnected == false
            ? RefreshIndicator(
                color: MyColors.ksecondaryColor,
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Home(
                        isInternetConnected: IsInternetConnected,
                      ),
                    ));
                  });
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.signal_wifi_connected_no_internet_4,
                            size: 60,
                            color: MyColors.ksecondaryColor,
                          ),
                          Container(
                            child: Text(
                              'No Internet Connection',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.kprimaryColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Home(
                                  isInternetConnected: IsInternetConnected,
                                ),
                              ));
                            },
                            child: Text(
                              'Reload Page',
                              style: TextStyle(color: MyColors.ksecondaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
               
               
               
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse('$url')),
                    pullToRefreshController: PullToRefreshController(
                        options: PullToRefreshOptions(
                            color: MyColors.ksecondaryColor),
                        onRefresh: () {
                          // return Future.delayed(Duration(seconds: 1), () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Home(
                              isInternetConnected: IsInternetConnected,
                            ),
                          ));
                          // });
                        }),
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptEnabled: true,
                          useOnDownloadStart: true,
                          useShouldOverrideUrlLoading: true,
                        ),
                        ios: IOSInAppWebViewOptions(),
                        android: AndroidInAppWebViewOptions(
                            useHybridComposition: true)),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction
                            .GRANT, // Grant camera permission
                      );
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url?.toString() ?? '';
                      });
                    },
                    onLoadStop: (controller, url) async {
                      setState(() {
                        this.url = url?.toString() ?? '';
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        this.progress = progress / 100;
                        if (progress == 100) {
                          _isRefreshing = false;
                        }
                      });
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url;
                      if (uri!.toString().startsWith('https://twigo')) {
                        return NavigationActionPolicy.ALLOW;
                      } else if (uri
                          .toString()
                          .startsWith('https://www.youtube.com/')) {
                        print('Blocking navigation to $uri');
                        return NavigationActionPolicy.CANCEL;
                      } else {
                        print('Opening external link: $uri');
                        // You can handle other links here and decide how to navigate to them
                        return NavigationActionPolicy.ALLOW;
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      // Handle web page load errors here
                    },
                  )

                  // WebView(
                  //   initialUrl: 'https://twigo.date/',
                  //   javascriptMode: JavascriptMode.unrestricted,
                  //   onWebViewCreated: (WebViewController webViewController) {
                  //     _webViewController.complete(webViewController);
                  //   },
                  //   javascriptChannels: <JavascriptChannel>{
                  //     // _toasterJavascriptChannel(context),
                  //     JavascriptChannel(
                  //         name: 'Toaster',
                  //         onMessageReceived: (JavascriptMessage message) {
                  //           var snackBar = SnackBar(
                  //             content: Text(message.message),
                  //           );
                  //           ScaffoldMessenger.of(context)
                  //               .showSnackBar(snackBar);
                  //         })
                  //   },
                  //   // navigationDelegate: (NavigationRequest request) {
                  //   //   if (request.url.contains('https://twigo.date/')) {
                  //   //     return NavigationDecision.navigate;
                  //   //   } else if (request.url
                  //   //       .startsWith('https://www.youtube.com/')) {
                  //   //     print('blocking navigation to $request}');
                  //   //     return NavigationDecision.prevent;
                  //   //   } else {
                  //   //     print('opening external link');
                  //   //     // _launchExternalUrl(request.url);
                  //   //     // launchUrl(Uri.parse(request.url));
                  //   //     return NavigationDecision.navigate;
                  //   //   }
                  //   //   print('allowing navigation to $request');
                  //   //   // return NavigationDecision.navigate;
                  //   // },
                  //   onProgress: (int progress) {
                  //     print("WebView is loading (progress : $progress%)");
                  //     setState(() {
                  //       _progress = progress / 100;
                  //       _progressText = progress;
                  //       // Update progress based on the value received (0-100)
                  //       print("::::$_progress");
                  //       if (_progress > 0.7) {
                  //         setState(() {
                  //           _isLoading = false;
                  //         });
                  //       }
                  //     });
                  //   },
                  //   onPageStarted: (String url) {
                  //     print('Page started loading: $url');
                  //     setState(() {
                  //       _isLoading =
                  //           true; // Set loading state to true when a new page starts loading
                  //     });
                  //   },
                  //   onPageFinished: (String url) {
                  //     print('Page finished loading: $url');
                  //     // setState(() {
                  //     //   _isLoading =
                  //     //       false; // Set loading state to false when the page finishes loading
                  //     // });
                  //   },
                  //   gestureNavigationEnabled: true,
                  //   geolocationEnabled: false,
                  //   zoomEnabled: true,
                  // ),

                  // Visibility(
                  //   visible:
                  //       _isLoading, // Show the progress indicator only when loading
                  //   child: Center(
                  //     child: CircularPercentIndicator(
                  //       radius: 80.0,
                  //       lineWidth: 15.0,
                  //       percent: _progress,
                  //       center: new Text(
                  //         "$_progressText%",
                  //         style: TextStyle(
                  //             color: MyColors.kprimaryColor, fontSize: 40),
                  //       ),
                  //       progressColor: MyColors.kprimaryColor,
                  //       backgroundColor: Color.fromARGB(255, 104, 204, 247),
                  //       circularStrokeCap: CircularStrokeCap.round,
                  //     ),
                  //   ),
                  //   //  CircularProgressIndicator(value: _progress),
                  // ),
                ],
              ),
        // bottomNavigationBar: _bannerAd != null
        //     ? Container(
        //         decoration: BoxDecoration(color: Colors.transparent),
        //         height: _bannerAd.size.height.toDouble(),
        //         width: _bannerAd.size.width.toDouble(),
        //         child: AdWidget(ad: _bannerAd),
        //       )
        //     : SizedBox(),

        bottomNavigationBar: Container(
          child: facebookBannerAd,
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  checkInternetConnectionForDashboard() async {
    // to check the internet connection
    await CheckInternetConnection.checkInternetFunction();

    if (!CheckInternetConnection.checkInternet) {
      setState(() {
        IsInternetConnected = false;
        loader = true;
      });
    } else {
      setState(() {
        loader = true;
        IsInternetConnected = true;
      });
    }
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.microphone,
      Permission.phone,
    ].request();
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.storage]!.isGranted &&
        statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.phone]!.isGranted) {
      // All permissions granted, proceed with the functionality.
      print('All permissions granted!');
    } else {
      // Permissions not granted, handle accordingly.
      print('Some or all permissions not granted!');
    }
  }

  // void _showInterstitalAd() {
  //   if (_interstialAd != null) {
  //     _interstialAd!.fullScreenContentCallback =
  //         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //       ad.dispose();
  //       _createInterstitialAd();
  //     }, onAdFailedToShowFullScreenContent: (ad, error) {
  //       ad.dispose();
  //       _createInterstitialAd();
  //     });
  //     _interstialAd!.show();
  //     _interstialAd = null;
  //   }
  // }

  // facebook add
  // void _loadBannerAdd() {
  //   facebookBannerAd = FacebookBannerAd(
  //     placementId: Platform.isAndroid
  //         ? "323745273316409_323745829983020"
  //         : "1450991599021523_1450992009021482",
  //     bannerSize: BannerSize.STANDARD,
  //     listener: (result, vale) {
  //       print("lister:");
  //     },
  //   );
  // }
  void _loadBannerAdd() {
    facebookBannerAd = FacebookBannerAd(
      placementId: Platform.isAndroid
          ? "IMG_16_9_APP_INSTALL#323745273316409_323745829983020"
          : "IMG_16_9_APP_INSTALL#1450991599021523_1450992009021482",
      bannerSize: BannerSize.STANDARD,
      listener: (result, vale) {
        print("lister:");
      },
    );
  }

  void _loadInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      // placementId: "YOUR_PLACEMENT_ID",
      placementId: Platform.isAndroid
          ? "IMG_16_9_APP_INSTALL#323745273316409_323745926649677"
          : "IMG_16_9_APP_INSTALL#1450991599021523_1451005752353441",
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED) {
          _isInterstitialAdLoaded = true;
          print('Add started ////');
        }

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }

  // void _loadInterstitialAd() {
  //   FacebookInterstitialAd.loadInterstitialAd(
  //     // placementId: "YOUR_PLACEMENT_ID",
  //     placementId: Platform.isAndroid
  //         ? "323745273316409_323745926649677"
  //         : "1450991599021523_1451005752353441",
  //     listener: (result, value) {
  //       print(">> FAN > Interstitial Ad: $result --> $value");
  //       if (result == InterstitialAdResult.LOADED)
  //         _isInterstitialAdLoaded = true;

  //       /// Once an Interstitial Ad has been dismissed and becomes invalidated,
  //       /// load a fresh Ad by calling this function.
  //       if (result == InterstitialAdResult.DISMISSED &&
  //           value["invalidated"] == true) {
  //         _isInterstitialAdLoaded = false;
  //         _loadInterstitialAd();
  //       }
  //     },
  //   );
  // }
}
