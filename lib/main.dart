import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Platform channel
const platform = MethodChannel('com.smkwinner.app_updator_example/store');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: AppUpdator(),
    );
  }
}

class AppUpdator extends StatefulWidget {
  const AppUpdator({super.key});

  @override
  State<AppUpdator> createState() => _AppUpdatorState();
}

class _AppUpdatorState extends State<AppUpdator> {
  Future<void> _openAppStore({required String appId}) async {
    try {
      await platform.invokeMethod('openStore', {'appID': appId});
    } on PlatformException catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to open App Store: ${e.message}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('App Updator'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: _checkForUpdates,
          child: const Text('Update App'),
        ),
      ),
    );
  }

  void _checkForUpdates() async {
    if (Platform.isIOS) {
      //String appId
      String appId =
          "1137397744"; //app id of your app in app store for bitwarden application, please change it with your app id

      //get local version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String localVersion = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      //get from remote config or server api
      String updateLocalVersion = "1.0.0";
      String updateBuildNumber = "2";
      //remove dot from version or you can have your own logic

      localVersion = localVersion.replaceAll('.', '');
      updateLocalVersion = updateLocalVersion.replaceAll('.', '');

      //parse into int
      int localVersionInt = int.parse(localVersion);
      int updateVersionInt = int.parse(updateLocalVersion);
      int localBuildNumberInt = int.parse(buildNumber);
      int updateBuildNumberInt = int.parse(updateBuildNumber);

      //check if local version is less than update version
      if (localVersionInt < updateVersionInt) {
        _openAppStore(
          appId: appId,
        );
      }
      //if local version is equal to update version but local build number is less than update build number
      else if (localVersionInt == updateVersionInt &&
          localBuildNumberInt < updateBuildNumberInt) {
        _openAppStore(
          appId: appId,
        );
      }
    }
  }
}
