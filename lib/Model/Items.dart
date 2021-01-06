import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Items {
  final String option;
  final String name;
  final int number;

  final int weight;

  Items({
    @required this.option,
    @required this.name,
    @required this.number,
    @required this.weight,
    // @required this.phonenumber,
  });

  factory Items.fromDocument(DocumentSnapshot doc) {
    return Items(
      option: doc['category'],
      name: doc['user'],
      number: doc['number of samples'],
      weight: doc['weight'],
      // phonenumber: doc['phonenumber'],
    );
  }
}
