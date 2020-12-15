import 'package:VRecycle/Constants/Colors.dart';
import 'package:flutter/material.dart';

class CheckBox extends StatelessWidget {
  final String btnText;
  final bool val;
  final Function change;

  const CheckBox(
      {Key key,
      @required this.btnText,
      @required this.val,
      @required this.change})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Utils.getColor(primaryColor),
        ),
        alignment: Alignment.center,
        child: CheckboxListTile(
          checkColor: Utils.getColor(primaryColor),
          title: Text(
            '$btnText',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          value: val,
          activeColor: Colors.white,
          onChanged: change,
          controlAffinity: ListTileControlAffinity.trailing,
        ));
  }
}
