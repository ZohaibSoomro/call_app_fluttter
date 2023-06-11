import 'package:flutter/material.dart';

import 'call_page.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final callId = "hello";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder(
          stream: null,
          builder: (context, snapshot) {
            return FutureBuilder(
                future: null,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          tileColor: Colors.pinkAccent.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textColor: Colors.white,
                          title: const Text('zohaib'),
                          subtitle: const Text('email@gmail.com'),
                          trailing: FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.purple),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CallPage(callId: callId)));
                            },
                            child: const Icon(Icons.call, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
