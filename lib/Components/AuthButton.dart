import 'package:VRecycle/Constants/Colors.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String btnText;
  final Function onTap;
  final bool isOutlined;

  const AuthButton({Key key, this.btnText, this.onTap, this.isOutlined = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
            border: isOutlined
                ? Border.all(color: Utils.getColor(primaryColor), width: 2)
                : null,
            color: isOutlined ? Colors.white : Utils.getColor(primaryColor),
            borderRadius: BorderRadius.circular(50)),
        padding: EdgeInsets.all(isOutlined ? 13 : 15),
        child: Center(
          child: Text(btnText,
              style: TextStyle(
                  color:
                      !isOutlined ? Colors.white : Utils.getColor(primaryColor),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
