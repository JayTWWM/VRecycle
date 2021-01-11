import 'package:VRecycle/Model/Item.dart';
import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  Item item;

  ItemWidget({@required this.item});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('${widget.item.itemName}'),
          Text('${widget.item.desc}'),
          Text('${widget.item.quantity}'),
        ],
      ),
    );
  }
}
