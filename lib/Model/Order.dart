import 'package:VRecycle/Model/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  String phoneNumberUser;
  String phoneNumberCollector;
  List<dynamic> items;
  double approxWeight;
  Timestamp timestamp;
  GeoPoint location;
  String address;
  String proof;
  String status;
  List<String> phoneNumberdeclinedCollector;
  Order({
    @required this.phoneNumberUser,
    @required this.phoneNumberCollector,
    @required this.items,
    @required this.approxWeight,
    @required this.timestamp,
    @required this.location,
    @required this.address,
    @required this.proof,
    @required this.status,
    @required this.phoneNumberdeclinedCollector,
  });

  Map<String, dynamic> toJson() {
    List<String> itemList = [];
    for (Item a in this.items) {
      itemList.add(a.toJson());
    }
    return {
      'phoneNumberUser': this.phoneNumberUser,
      'phoneNumberCollector': this.phoneNumberCollector,
      'items': itemList,
      'approxWeight': this.approxWeight,
      'timestamp': this.timestamp,
      'location': this.location,
      'address': this.address,
      'proof': this.proof,
      'status': this.status,
      'phoneNumberdeclinedCollector': this.phoneNumberdeclinedCollector
    };
  }

  factory Order.fromDocument(DocumentSnapshot doc) {
    return Order(
        phoneNumberUser: doc['phoneNumberUser'],
        phoneNumberCollector: doc['phoneNumberCollector'],
        items: doc['items'],
        approxWeight: doc['approxWeight'],
        timestamp: doc['timestamp'],
        location: doc['location'],
        address: doc['address'],
        proof: doc['proof'],
        status: doc['status'],
        phoneNumberdeclinedCollector: (doc['phoneNumberdeclinedCollector'] != null) ? doc['phoneNumberdeclinedCollector'].cast<String>() : null);
  }
}
