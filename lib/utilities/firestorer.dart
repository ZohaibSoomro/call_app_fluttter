import 'package:call_app_flutter/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestorer {
  final collection = FirebaseFirestore.instance.collection("callAppUsers");
  Future<void> createUser(MyUser user) async {
    await collection.add(user.toJson()).then((value) {
      print("Doc added");
      user.id = value.id;
      value.update(user.toJson()).then((value) => print("doc updated"));
    });
  }
}
