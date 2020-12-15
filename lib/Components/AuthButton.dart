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
            border:
                isOutlined ? Border.all(color: Colors.cyan, width: 2) : null,
            color: isOutlined ? Colors.white : Colors.cyan,
            borderRadius: BorderRadius.circular(50)),
        padding: EdgeInsets.all(isOutlined ? 13 : 15),
        child: Center(
          child: Text(btnText,
              style: TextStyle(
                  color: !isOutlined ? Colors.white : Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
