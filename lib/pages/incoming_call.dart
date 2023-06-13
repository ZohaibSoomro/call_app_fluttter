import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/pages/call_page.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';

class IncomingCallPage extends StatelessWidget {
  final MyUser caller;
  const IncomingCallPage({super.key, required this.caller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Incoming Call',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(kDummyImage),
            ),
            const SizedBox(height: 16),
            Text(
              caller.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Localstorer.currentUser.callInfo!.status =
                        CallStatus.declined;
                    Localstorer.setCurrentUser(Localstorer.currentUser);
                    Firestorer.instance.updateUser(Localstorer.currentUser);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.call_end),
                  color: Colors.red,
                ),
                const SizedBox(width: 32),
                IconButton(
                  onPressed: () {
                    // caller.callInfo = CallInfo(
                    //     status: CallStatus.inACall,
                    //     timestamp: DateTime.now().toIso8601String());
                    // Firestorer.instance.updateUser(Localstorer.currentUser);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallPage(
                          user: caller,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
