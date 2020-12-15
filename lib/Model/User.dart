import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String name;
  final String email;
  final String imageUrl;
  final String address;
  final String phonenumber;

  User({
    @required this.name,
    @required this.imageUrl,
    @required this.address,
    @required this.phonenumber,
    @required this.email,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      email: doc['email'],
      name: doc['name'],
      imageUrl: doc['imageUrl'],
      address: doc['address'],
      phonenumber: doc['phonenumber'],
    );
  }
}
