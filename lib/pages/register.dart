import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../model/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = "/register";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;
  final firestorer = Firestorer.instance;

  final formKey = GlobalKey<FormState>();

  void _register() {
    String email = emailController.text;
    String password = passwordController.text;

    // Perform validation here
    if (email.isEmpty || password.isEmpty) {
      print('Please enter email and password');
      return;
    }

    // Create the user
    MyUser user = MyUser(
      email: email.trim().toLowerCase(),
      password: password,
      name: nameController.text.trim(),
    );

    // Print user details
    setState(() {
      isLoading = true;
    });
    firestorer.createUser(user).then(
          (val) => {
            setState(() {
              isLoading = false;
            }),
            Navigator.pop(context)
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: kSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextFormField(
                  controller: emailController,
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
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextFormField(
                  autofillHints: const [AutofillHints.newPassword],
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
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
