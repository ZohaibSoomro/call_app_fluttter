import 'package:call_app_flutter/pages/login.dart';
import 'package:call_app_flutter/pages/register.dart';
import 'package:call_app_flutter/utilities/apputils.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Localstorer.setPrefs();
  bool isLoggedIn = await Localstorer.getLoggedInStatus();
  await Firebase.initializeApp();
  final navigatorKey = GlobalKey<NavigatorState>();

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ZegoUIKit().initLog().then((value) {
    ///  Call the `useSystemCallingUI` method
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(CallApp(isLoggedIn, navigatorKey));
  });
  if (isLoggedIn) {
    Localstorer.loadCurrentUser();
  }
}

class CallApp extends StatefulWidget {
  const CallApp(
    this.isLoggedIn,
    this.navigatorKey, {
    super.key,
  });
  final bool isLoggedIn;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<CallApp> createState() => _CallAppState();
}

class _CallAppState extends State<CallApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ZegoUIKitPrebuiltCallInvitationService().init(
        appID: AppUtils.kZegoAppId /*input your AppID*/,
        appSign: AppUtils.kZegoAppSignIn /*input your AppSign*/,
        userID: Localstorer.currentUser.id!,
        userName: Localstorer.currentUser.name,
        plugins: [ZegoUIKitSignalingPlugin()],
        appName: 'CallMe app');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      routes: {
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        HomePage.id: (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      home: widget.isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
