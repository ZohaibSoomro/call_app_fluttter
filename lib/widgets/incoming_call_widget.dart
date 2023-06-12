import 'package:call_app_flutter/pages/incoming_call.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../utilities/firestorer.dart';

class IncomingCallWidget extends StatefulWidget {
  const IncomingCallWidget({Key? key, required this.child}) : super(key: key);
// final Function(BuildContext,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>>) builder;
  final Widget child;

  @override
  State<IncomingCallWidget> createState() => _IncomingCallWidgetState();
}

class _IncomingCallWidgetState extends State<IncomingCallWidget> {
  final firestorer = Firestorer.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            firestorer.collection.doc(Localstorer.currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            final user =
                MyUser.fromJson(snapshot.data?.data() as Map<String, dynamic>);
            if (user.callInfo?.status == CallStatus.beingCalled) {
              Localstorer.setCurrentUser(user).then(
                (value) => Future.delayed(Duration.zero, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncomingCallPage(
                        caller: user.callInfo!.caller!,
                      ),
                    ),
                  );
                }),
              );
              return const Text('');
            }
          }
          return widget.child;
        });
  }
}
