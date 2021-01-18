import 'package:VRecycle/Constants/Colors.dart';
import 'package:flutter/material.dart';

class QuantityWidget extends StatefulWidget {
  int counter;

  QuantityWidget({@required this.counter});

  @override
  _QuantityWidgetState createState() => _QuantityWidgetState();
}

class _QuantityWidgetState extends State<QuantityWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Utils.getColor(primaryColor)),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(8),
          child: InkWell(
              onTap: () {
                setState(() {
                  if (widget.counter > 0) {
                    widget.counter--;
                  }
                });
              },
              child: Icon(
                Icons.remove,
                color: Utils.getColor(primaryColor),
                size: 18,
              )),
        ),
        Padding(padding: EdgeInsets.all(10)),
        Text(
          '${widget.counter}',
          style: TextStyle(color: Colors.black),
        ),
        Padding(padding: EdgeInsets.all(8)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Utils.getColor(primaryColor)),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(10),
          child: InkWell(
              onTap: () {
                setState(() {
                  widget.counter++;
                });
              },
              child: Icon(
                Icons.add,
                color: Utils.getColor(primaryColor),
                size: 18,
              )),
        ),
      ],
    );
  }
}
