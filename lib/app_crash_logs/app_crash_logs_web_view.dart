import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_consent_prompt.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_service.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_splash.dart';

class AppCrashLogsWebViewWidget extends StatefulWidget {
  const AppCrashLogsWebViewWidget({super.key});

  @override
  State<AppCrashLogsWebViewWidget> createState() =>
      _AppCrashLogsWebViewWidgetState();
}

class _AppCrashLogsWebViewWidgetState extends State<AppCrashLogsWebViewWidget>
    with WidgetsBindingObserver {
  late InAppWebViewController appCrashLogsWebViewController;

  bool appCrashLogsShowLoading = true;
  bool appCrashLogsShowConsentPrompt = false;

  bool appCrashLogsWasOpenNotification =
      appCrashLogsSharedPreferences.getBool("wasOpenNotification") ?? false;

  final bool savePermission =
      appCrashLogsSharedPreferences.getBool("savePermission") ?? false;

  bool waitingForSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (waitingForSettingsReturn) {
        waitingForSettingsReturn = false;
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            appCrashLogsAfterSetting();
          }
        });
      }
    }
  }

  Future<void> appCrashLogsAfterSetting() async {
    final deviceState = OneSignal.User.pushSubscription;

    bool havePermission = deviceState.optedIn ?? false;
    final bool systemNotificationsEnabled = await AppCrashLogsService()
        .isSystemPermissionGranted();

    if (havePermission || systemNotificationsEnabled) {
      appCrashLogsSharedPreferences.setBool("wasOpenNotification", true);
      appCrashLogsWasOpenNotification = true;
      AppCrashLogsService().appCrashLogsSendRequiestToBack();
    }

    appCrashLogsShowConsentPrompt = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: appCrashLogsShowLoading ? 0 : 1,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      onCreateWindow:
                          (
                            controller,
                            CreateWindowAction createWindowRequest,
                          ) async {
                            await showDialog(
                              context: context,
                              builder: (dialogContext) {
                                final dialogSize = MediaQuery.of(
                                  dialogContext,
                                ).size;

                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      SizedBox(
                                        width: dialogSize.width,
                                        height: dialogSize.height * 0.8,
                                        child: InAppWebView(
                                          windowId:
                                              createWindowRequest.windowId,
                                          initialSettings: InAppWebViewSettings(
                                            javaScriptEnabled: true,
                                          ),
                                          onCloseWindow: (controller) {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: Material(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            return true;
                          },
                      initialUrlRequest: URLRequest(
                        url: WebUri(appCrashLogsLink!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: false,
                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                        mediaPlaybackRequiresUserGesture: false,
                        supportMultipleWindows: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                      ),
                      onWebViewCreated: (controller) {
                        appCrashLogsWebViewController = controller;
                      },
                      onLoadStop: (controller, url) async {
                        appCrashLogsShowLoading = false;
                        setState(() {});
                        if (appCrashLogsWasOpenNotification) return;

                        final bool systemNotificationsEnabled =
                            await AppCrashLogsService()
                                .isSystemPermissionGranted();

                        await Future.delayed(Duration(milliseconds: 3000));

                        if (systemNotificationsEnabled) {
                          appCrashLogsSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                          appCrashLogsWasOpenNotification = true;
                        }

                        if (!systemNotificationsEnabled) {
                          appCrashLogsShowConsentPrompt = true;
                          appCrashLogsWasOpenNotification = true;
                        }

                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return appCrashLogsBuildWebBottomBar(orientation);
              },
            ),
          ),
        ),
        if (appCrashLogsShowLoading) const AppCrashLogsSplash(),
        if (!appCrashLogsShowLoading)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            reverseDuration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: appCrashLogsShowConsentPrompt
                ? AppCrashLogsConsentPromptPage(
                    key: const ValueKey('consent_prompt'),
                    onYes: () async {
                      if (savePermission == true) {
                        waitingForSettingsReturn = true;
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        );
                      } else {
                        await AppCrashLogsService()
                            .appCrashLogsRequestPermissionOneSignal();

                        final bool systemNotificationsEnabled =
                            await AppCrashLogsService()
                                .isSystemPermissionGranted();

                        if (systemNotificationsEnabled) {
                          appCrashLogsSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                        } else {
                          appCrashLogsSharedPreferences.setBool(
                            "savePermission",
                            true,
                          );
                        }
                        appCrashLogsWasOpenNotification = true;
                        appCrashLogsShowConsentPrompt = false;
                        setState(() {});
                      }
                    },
                    onNo: () {
                      setState(() {
                        appCrashLogsWasOpenNotification = true;
                        appCrashLogsShowConsentPrompt = false;
                      });
                    },
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
      ],
    );
  }

  Widget appCrashLogsBuildWebBottomBar(Orientation orientation) {
    return Container(
      color: Colors.black,
      height: orientation == Orientation.portrait ? 25 : 30,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await appCrashLogsWebViewController.canGoBack()) {
                appCrashLogsWebViewController.goBack();
              }
            },
          ),
          const SizedBox.shrink(),
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await appCrashLogsWebViewController.canGoForward()) {
                appCrashLogsWebViewController.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}

