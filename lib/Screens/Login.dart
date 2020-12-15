import 'dart:async';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

TextEditingController phoneController;
TextEditingController passwordController;

final usersRef = Firestore.instance.collection('users');
String s = 'L o g i n';

class Login extends StatefulWidget {
  final Function onTap;
  const Login({Key key, this.onTap}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String error;
  final _loginFormKey = GlobalKey<FormState>();
  bool av = false, isloading = false;

  String address = "";
  bool passvis = true;

  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  // List<Placemark> placemarks;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    isloading = false;
    s = 'Login';
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          timeout: const Duration(seconds: 20),
          verificationCompleted: (credential) async {
            var res = await _auth.signInWithCredential(credential);
            FirebaseUser firebaseUser = res.user;
            print(firebaseUser);
            login(context, firebaseUser);
            Navigator.pop(context);
          },
          verificationFailed: (AuthException e) {
            toast('${e.message}');
            setState(() {
              isloading = false;
            });
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext diffcontext) {
          return new AlertDialog(
            elevation: 10,
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container()),
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              Text(
                  "\n\nIf you have Google Play Games installed You may have no need to enter the code ,Wait for a while \n"),
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  print('Pressed');
                  _auth.currentUser().then((user) {
                    print(user == null);
                    Navigator.of(diffcontext).pop();
                    login(context, user);
                  });
                },
              )
            ],
          );
        });
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  toast(s) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Text(s.toString()),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]))),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            autovalidate: av,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your phone Number';
                              }
                              if (!RegExp(r"^(?=.*\d)[\d]{10}$")
                                  .hasMatch(phoneController.text)) {
                                return "Only 10 digits allowed\nDon't Include Country Code";
                              }
                              return null;
                            },
                            maxLength: 10,
                            controller: phoneController,
                            decoration: InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        AuthButton(
                          btnText: 'Login',
                          onTap: () {
                            setState(() {
                              av = true;
                            });
                            if (_loginFormKey.currentState.validate()) {
                              setState(() {
                                this.phoneNo = "+91" + phoneController.text;
                                isloading = true;
                              });
                              verifyPhone();
                            }
                          },
                          isOutlined: false,
                        ),
                        SizedBox(height: 10),
                        AuthButton(
                          btnText: "Don't Have an Account ?",
                          onTap: () => widget.onTap(),
                          isOutlined: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isloading ? Loader() : Container()
          ],
        ));
  }

  void login(context, FirebaseUser user) async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      s = 'Loading Content ...';
    });
    try {
      FirebaseUser user1;
      if (user == null) {
        final AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: verificationId,
          smsCode: smsOTP,
        );
        print(credential);
        var res = await _auth.signInWithCredential(credential);
        user1 = res.user;
      } else {
        user1 = user;
      }
      print(user1.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
      setState(() {
        s = 'login';
        isloading = false;
      });
      phoneController.clear();
    } catch (e) {
      if (e is PlatformException) {
        handleError(e);
        toast(e);
        setState(() {
          isloading = false;
        });
      }
      print(e);
    }
  }
}
