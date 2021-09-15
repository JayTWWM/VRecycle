import 'dart:io';
import 'dart:async';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/CheckBox.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Screens/CollectorHome.dart';
import 'package:VRecycle/Screens/Home.dart';
import 'package:VRecycle/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
// import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController emailController;
TextEditingController nameController;
TextEditingController locationController;
TextEditingController phoneController;
TextEditingController reraController;
bool isCollector = false;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final usersRef = Firestore.instance.collection('Users');
final collectorsRef = Firestore.instance.collection('Collectors');
String s = 'Register';

String mediaUrl = '';
File _image;

class Register extends StatefulWidget {
  final Function onTap;
  const Register({Key key, this.onTap}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String error;
  final _registerFormKey = GlobalKey<FormState>();
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
    emailController = TextEditingController();
    nameController = TextEditingController();
    locationController = TextEditingController();
    phoneController = TextEditingController();
    reraController = TextEditingController();
    isloading = false;
    s = 'Register';
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    nameController.dispose();
    locationController.dispose();
    phoneController.dispose();
    reraController.dispose();
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
            register(context, firebaseUser);
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
                  "\n\nIf you have Google Play Games installed You may have no need to enter the code ,Wait for a while ,still if it does not register's You Enter the code\n"),
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  print('Pressed');
                  _auth.currentUser().then((user) {
                    print(user == null);
                    Navigator.of(diffcontext).pop();
                    register(context, user);
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
    Future getImage() async {
      var image = await ImagePicker()
          .getImage(source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
      setState(() {
        _image = File(image.path);
        print('Image path $_image');
      });
      if (_image != null) {
        File croppedImage = await ImageCropper.cropImage(
            sourcePath: _image.path,
            maxWidth: 1080,
            maxHeight: 1080,
            aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
        if (croppedImage != null) {
          setState(() {
            _image = croppedImage;
          });
        }
      }
    }

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              children: <Widget>[
                Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _registerFormKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]))),
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a Name';
                                }
                                return null;
                              },
                              autovalidate: av,
                              controller: nameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Your Name",
                                  hintStyle: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]))),
                            child: TextFormField(
                              autovalidate: av,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter an Email Id';
                                }
                                if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailController.text)) {
                                  return 'Please enter a valid email id';
                                }
                                return null;
                              },
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email ID",
                                  hintStyle: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[200]))),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      autovalidate: av,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter an Address';
                                        }
                                        return null;
                                      },
                                      onChanged: (text) {
                                        setState(() {
                                          address = text;
                                        });
                                      },
                                      controller: locationController,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Address",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                  address == ""
                                      ? GestureDetector(
                                          onTap: () => getUserLocation(),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Utils.getColor(
                                                    primaryColor),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 5.0,
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 10),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.my_location,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    "Use\nCurrent\nLocation",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8),
                                                  ),
                                                ],
                                              )))
                                      : Text('')
                                ],
                              )),
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]))),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Utils.getColor(primaryColor)),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          _image == null
                                              ? Icon(
                                                  Icons.person_add,
                                                  color: Utils.getColor(
                                                      primaryColor),
                                                  size: 30,
                                                )
                                              : Image.file(
                                                  _image,
                                                  height: 50,
                                                  width: 50,
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Select Profile Pic',
                                              style: TextStyle(
                                                  color: Utils.getColor(
                                                      primaryColor),
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]))),
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
                        ],
                      ),
                    ),
                    CheckBox(
                        btnText: 'I am a collector',
                        val: isCollector,
                        change: (val) {
                          setState(() {
                            isCollector = val;
                          });
                        }),
                    SizedBox(height: 20),
                    AuthButton(
                        btnText: 'Register',
                        onTap: () {
                          setState(() {
                            av = true;
                          });
                          if (_image != null) {
                            if (_registerFormKey.currentState.validate()) {
                              setState(() {
                                this.phoneNo = "+91" + phoneController.text;
                                isloading = true;
                              });
                              verifyPhone();
                            }
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Select an image for your Profile'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Utils.getColor(primaryColor),
                            ));
                          }
                        }),
                    SizedBox(height: 10),
                    AuthButton(
                      btnText: "Already Have an Account ?",
                      onTap: () => widget.onTap(),
                      isOutlined: true,
                    ),
                    SizedBox(height: 80),
                  ],
                )),
              ],
            ),
            isloading ? Loader() : Container()
          ],
        ));
  }

  void register(context, FirebaseUser user) async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      s = 'Loading Content ...';
    });
    try {
      final bytes = _image.readAsBytesSync();
      String downloadUrl = base64Encode(bytes);
      setState(() {
        mediaUrl = downloadUrl;
        print("Profile Picture converted to base 64");
      });
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
      // print(user1.uid);SharedPreferences prefs = await SharedPreferences.getInstance();

      createUserInFireStore(user1);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (isCollector) {
        prefs.setString("userType", "collector");
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: CollectorHome()));
      } else {
        prefs.setString("userType", "user");

        Navigator.push(context,
            PageTransition(type: PageTransitionType.fade, child: Home()));
      }
    } catch (e) {
      if (e is PlatformException) {
        handleError(e);
        toast(e.message.replaceAll("email address", "Phone Number"));
        setState(() {
          isloading = false;
        });
      }
      print(e);
    }
  }

  Future<GeoPoint> getCords() async {
    try {
      Position position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      print("Unable to get Location.");
      return null;
    }
  }

  Future<void> createUserInFireStore(FirebaseUser user) async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var playerId = status.subscriptionStatus.userId;
    print("PlayerId: " + playerId.toString());
    if (isCollector == false) {
      await usersRef.document(phoneController.text).setData({
        "onesignalId": playerId.toString(),

        "email": emailController.text,
        // "password": passwordController.text, //only for testing purpose
        "name": nameController.text,
        "address": locationController.text,
        "imageUrl": mediaUrl,
        "geopoint": await getCords(),
        "Orders": []

        // "isCollector": isCollector
        // "phonenumber": phoneController.text,
      });
    } else {
      await collectorsRef.document(phoneController.text).setData({
        "onesignalId": playerId.toString(),
        "email": emailController.text,
        // "password": passwordController.text, //only for testing purpose
        "name": nameController.text,
        "address": locationController.text,
        "imageUrl": mediaUrl,
        "geopoint": await getCords(),
        "Orders": []
        // "isCollector": isCollector
        // "phonenumber": phoneController.text,
      });
    }
  }

  getUserLocation() async {
    setState(() {
      isloading = true;
    });
    try {
      Position position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String completeAddress =
          '${placemark.subThoroughfare} ,${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
      print(completeAddress);
      var list = completeAddress.split(", ");
      print(list);
      String formattedAddress = "";
      for (var i = 0; i < list.length; i++) {
        if (list.elementAt(i).trim() != "" || list.elementAt(i).isNotEmpty) {
          formattedAddress += list.elementAt(i) + ", ";
        }
      }
      formattedAddress = formattedAddress.trim()[0] == ','
          ? formattedAddress.trim().substring(1)
          : formattedAddress;
      // print(formattedAddress.substring(0, formattedAddress.length - 1));
      setState(() {
        address = locationController.text =
            formattedAddress.substring(0, formattedAddress.length - 1);
        isloading = false;
      });
    } catch (e) {
      setState(() {
        isloading = false;
        toast('Unable to get Location');
      });
    }
  }
}
