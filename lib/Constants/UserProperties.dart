import 'package:VRecycle/Model/User.dart';
import 'package:VRecycle/Screens/HandleAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Firestore _db = Firestore.instance;

class UserProperties {
  static Future<User> getUser() async {
    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    var userDoc = await _db
        .collection('users')
        .document(firebaseUser.phoneNumber.substring(3))
        .get();
    if (userDoc.exists) {
      var fireIns = _db
          .collection('users')
          .document(firebaseUser.phoneNumber.substring(3));
      DocumentSnapshot doc = await fireIns.get();
      User user = User.fromDocument(doc);
      return user;
    }
    return null;
  }
}
