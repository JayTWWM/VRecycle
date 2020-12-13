import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final String imageUrl;
  final String address;
  final String phonenumber;
  final bool isCollector;

  User(
      {this.name,
      this.imageUrl,
      this.address,
      this.phonenumber,
      this.email,
      this.isCollector});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      email: doc['email'],
      isCollector: doc['isCollector'],
      name: doc['name'],
      imageUrl: doc['imageUrl'],
      address: doc['address'],
      phonenumber: doc['phonenumber'],
    );
  }
}
