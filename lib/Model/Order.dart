import 'package:VRecycle/Model/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  String phoneNumberUser;
  String phoneNumberCollector;
  List<Item> items;
  double approxWeight;
  Timestamp timestamp;
  GeoPoint location;
  String address;
  String proof;
  String status;

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
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumberUser': this.phoneNumberUser,
      'phoneNumberCollector': this.phoneNumberCollector,
      'items': this.items,
      'approxWeight': this.approxWeight,
      'timestamp': this.timestamp,
      'location': this.location,
      'address': this.address,
      'proof': this.proof,
      'status': this.status
    };
  }
}
