import 'package:VRecycle/Model/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  String phoneNumber;
  List<Item> items;
  double approxWeight;
  Timestamp timestamp;
  GeoPoint location;
  String address;
  String proof;
  String status;
  String category;

  Order({
    @required this.phoneNumber,
    @required this.items,
    @required this.approxWeight,
    @required this.timestamp,
    @required this.location,
    @required this.address,
    @required this.proof,
    @required this.status,
    @required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': this.phoneNumber,
      'items': this.items,
      'approxWeight': this.approxWeight,
      'timestamp': this.timestamp,
      'location': this.location,
      'address': this.address,
      'proof': this.proof,
      'status': this.status,
      'category': this.category,
    };
  }
}
