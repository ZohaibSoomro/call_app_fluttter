import 'package:call_app_flutter/pages/call_page.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/user_model.dart';

class UserTile extends StatelessWidget {
  const UserTile({Key? key, required this.user}) : super(key: key);
  final MyUser user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        closeOnScroll: true,
        key: ValueKey(user.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Firestorer.instance.deleteUser(user);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
            SlidableAction(
              onPressed: (context) {
                user.callInfo = CallInfo(
                  status: CallStatus.beingCalled,
                  caller: Localstorer.currentUser,
                  timestamp: DateTime.now().toIso8601String(),
                );
                Firestorer.instance.updateUser(user);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(
                        user: user, callId: Localstorer.currentUser.email),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              icon: Icons.call,
              label: 'Call',
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              tileColor: Colors.blue.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textColor: Colors.white,
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'swipe left',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Icon(Icons.arrow_back, color: Colors.white70)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
