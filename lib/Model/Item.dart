import 'package:flutter/material.dart';

class Item {
  int serialNo;
  String itemName;
  String desc;
  int quantity;

  Item({
    @required this.serialNo,
    @required this.itemName,
    @required this.desc,
    @required this.quantity,
  });

  String toJson() {
    return '{"serialNo": ${this.serialNo},"itemName": "${this.itemName}","desc": "${this.desc}","quantity": ${this.quantity}}';
  }
}
