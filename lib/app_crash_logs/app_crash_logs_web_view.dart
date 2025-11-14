import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_check.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_consent_prompt.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_service.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_splash.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({super.key});

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget>
    with WidgetsBindingObserver {
  late InAppWebViewController appCrashLogsWebViewController;

  bool appCrashLogsShowLoading = true;
  bool appCrashLogsShowConsentPrompt = false;

  bool appCrashLogsWasOpenNotification =
      aSharedPreferences.getBool("wasOpenNotification") ?? false;

  final bool savePermission =
      aSharedPreferences.getBool("savePermission") ?? false;

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
      aSharedPreferences.setBool("wasOpenNotification", true);
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
                      initialUrlRequest: URLRequest(
                        url: WebUri(analyticsLink!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: false,
                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                      ),
                      onWebViewCreated: (controller) {
                        appCrashLogsWebViewController = controller;
                      },
                      onLoadStop: (controller, url) async {
                        appCrashLogsShowLoading = false;
                        setState(() {});
                        if (appCrashLogsWasOpenNotification) return;

                        final bool systemNotificationsEnabled =
                            await AppCrashLogsService().isSystemPermissionGranted();

                        await Future.delayed(Duration(milliseconds: 3000));

                        if (systemNotificationsEnabled) {
                          aSharedPreferences.setBool(
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
                            await AppCrashLogsService().isSystemPermissionGranted();

                        if (systemNotificationsEnabled) {
                          aSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                        } else {
                          aSharedPreferences.setBool("savePermission", true);
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

