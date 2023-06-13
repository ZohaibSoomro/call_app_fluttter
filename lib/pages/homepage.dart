import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:call_app_flutter/widgets/incoming_call_widget.dart';
import 'package:call_app_flutter/widgets/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../utilities/firestorer.dart';
import 'login.dart';
import 'register.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const id = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestorer = Firestorer.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
              onPressed: () async {
                Localstorer.setLoggedInStatus(false);
                //un-initializing zego call invitation service
                await ZegoUIKitPrebuiltCallInvitationService().uninit();
                Future.delayed(const Duration(seconds: 1)).then(
                  (value) =>
                      Navigator.pushReplacementNamed(context, LoginPage.id),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: IncomingCallWidget(
        child: StreamBuilder(
            stream: Firestorer.instance.collection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return kSpinner;
              }
              return ListView(
                children: parseUserDocumentsToWidgets(snapshot.data!.docs),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> parseUserDocumentsToWidgets(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    //convert document into users(MyUser type)
    List<MyUser> users = docs.map((e) => MyUser.fromJson(e.data())).toList();
    //don't include current user
    users = users
        .where((user) => user.email != Localstorer.currentUser.email)
        .toList();
    return users.map((user) {
      return UserTile(user: user);
    }).toList();
  }
}
