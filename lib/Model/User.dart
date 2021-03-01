import 'package:VRecycle/Model/Order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String name;
  final String email;
  final String imageUrl;
  final String address;
  final GeoPoint geopoint;
  final List<dynamic> orders;
  // final String phonenumber;

  User({
    @required this.name,
    @required this.imageUrl,
    @required this.address,
    // @required this.phonenumber,
    @required this.email,
    @required this.geopoint,
    @required this.orders,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        email: doc['email'],
        name: doc['name'],
        imageUrl: doc['imageUrl'],
        address: doc['address'],
        geopoint: doc['geopoint'],
        // phonenumber: doc['phonenumber'],
        orders: doc['Orders']);
  }
}
