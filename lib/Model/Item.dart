import 'package:flutter/material.dart';

class Item {
  String itemName;
  String desc;
  int quantity;

  Item({
    @required this.itemName,
    @required this.desc,
    @required this.quantity,
  });

  String toJson() {
    return '{"itemName": "${this.itemName}","desc": "${this.desc}","quantity": ${this.quantity}}';
  }
}
