import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../model/user_model.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final firestorer = Firestorer();

  void _login() {
    String email = emailController.text;
    String password = passwordController.text;

    // Perform validation here
    if (email.isEmpty || password.isEmpty) {
      print('Please enter email and password');
      return;
    }

    // Create the user
    MyUser user = MyUser(
      id: '1', // Generate a unique ID here
      email: email,
      password: password,
      name: 'John Doe', // Set the name here
    );

    // Print user details
    setState(() {
      isLoading = true;
    });
    firestorer.createUser(user).then((val) => {
          setState(() {
            isLoading = false;
          }),
          Navigator.pop(context)
        });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
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
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
