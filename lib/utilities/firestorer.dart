import 'package:call_app_flutter/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestorer {
  static final instance = Firestorer._();

  Firestorer._();
  final collection = FirebaseFirestore.instance.collection("callAppUsers");
  Future<void> createUser(MyUser user) async {
    await collection.add(user.toJson()).then((value) {
      print("Doc added");
      user.id = value.id;
      value.update(user.toJson()).then((value) => print("doc updated"));
    });
  }

  ///used to login a user
  Future<MyUser?> loginUser(MyUser user) async {
    final doc = await collection
        .where("email", isEqualTo: user.email)
        .where("password", isEqualTo: user.password)
        .get();
    if (doc.docs.isEmpty) {
      return null;
    }
    return MyUser.fromJson(doc.docs.first.data());
  }

  Future<void> deleteUser(MyUser user) async {
    return await collection
        .doc(user.id)
        .delete()
        .then((value) => print("Doc deleted"));
  }

  Future<List<MyUser>> getAllUsers() async {
    return (await collection.get())
        .docs
        .map((e) => MyUser.fromJson(e.data()))
        .toList();
  }

  Future<void> updateUser(MyUser user) async {
    await collection.doc(user.id).update(user.toJson());
    print("user ${user.callInfo?.toJson()} updated");
  }
}
