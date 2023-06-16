// ignore_for_file: use_build_context_synchronously

import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/pages/chat_home_page.dart';
import 'package:call_app_flutter/utilities/apputils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import '../model/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final firestorer = Firestorer.instance;

  final formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Perform validation here
    if (email.isEmpty || password.isEmpty) {
      print('Please enter email and password');
      return;
    }

    // Create the user
    MyUser? user = MyUser(
      email: email.toLowerCase(),
      password: password,
      name: "",
    );

    // Print user details
    setState(() {
      isLoading = true;
    });
    user = await firestorer.loginUser(user);
    if (user != null) {
      Fluttertoast.showToast(msg: "Login successful");
      Localstorer.setLoggedInStatus(true);
      Localstorer.setCurrentUser(user);
      await ZIMKit().connectUser(id: user.id!, name: user.name).then((val) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatHomePage(),
          ),
        );
      });
      //initializing zego call invitation service
      initZegoKitService(user);
      // Navigator.pushReplacementNamed(
      //   context,
      //   HomePage.id,
      // );
    } else {
      Fluttertoast.showToast(
          msg: "Invalid credentials, login failed",
          backgroundColor: Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: kSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value!)) {
                        return "invalid email";
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 4) {
                        return "password length can't be less than 4";
                      }
                      return null;
                    },
                    autofillHints: const [AutofillHints.password],
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void initZegoKitService(MyUser user) {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppUtils.kZegoAppId /*input your AppID*/,
      appSign: AppUtils.kZegoAppSignIn /*input your AppSign*/,
      userID: user.id!,
      userName: user.name,
      plugins: [ZegoUIKitSignalingPlugin()],
      appName: 'CallMe app',
      requireConfig: kCallWithInvitationConfig,
      ringtoneConfig: kRingtoneCallInvitationConfig,
      events: kCallInvitationEvents,
    );
  }
}
