import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menupage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/api.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  FocusNode myFocusNode = new FocusNode();
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String? username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  var _autovalidadate = false;

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      login();
    } else {
      setState(() {
        _autovalidadate = true;
      });
    }
  }

  login() async {
    final response = await http.post(Uri.parse(BaseUrl.urlLogin),
        body: {"username": username, "pass": password});
    final data = jsonDecode(response.body);
    int value = data['success'];
    String pesan = data['message'];
    if (value == 1) {
      String idAPI = data['id'];
      String namaAPI = data['nama'];
      String userLevel = data['level'];
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, idAPI, namaAPI, userLevel);
      });
      print(pesan);
    } else {
      print(pesan);
      dialogGagal(pesan);
    }
  }

  savePref(int val, String idAPI, String namaAPI, userLevel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", val);
      preferences.setString("id", idAPI);
      preferences.setString("nama", namaAPI);
      preferences.setString("level", userLevel);
      preferences.commit();
    });
  }

  var value;
  var level;
  var nama;
  var id;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      level = preferences.getString("level");
      nama = preferences.getString("nama");
      id = preferences.getString("id");
      if (value == 1) {
        _loginStatus = LoginStatus.signIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.setString("id", null.toString());
      preferences.setString("nama", null.toString());
      preferences.setString("level", null.toString());
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  dialogGagal(String pesan) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      title: 'ERROR',
      desc: pesan,
      btnOkOnPress: () {},
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red,
    ).show();
  }

  void disopse() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return new Scaffold(
          body: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: EdgeInsets.only(top: 90.0, left: 20.0, right: 20.0),
              children: <Widget>[
                Icon(
                  CupertinoIcons.device_desktop,
                  size: 50.0,
                ),
                Text(
                  "APLIKASI INVENTORY",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                ),
                SizedBox(
                  height: 25.0,
                ),
                TextFormField(
                  validator: (e) {
                    if (e!.isEmpty) {
                      return "silahkan isi username";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (e) => username = e,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(
                        color: myFocusNode.hasFocus
                            ? Colors.blue
                            : Color.fromARGB(255, 32, 54, 70)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 32, 54, 70)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: _secureText,
                  validator: (e) {
                    if (e!.isEmpty) {
                      return "silahkan isi password";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                        color: myFocusNode.hasFocus
                            ? Colors.blue
                            : Color.fromARGB(255, 32, 54, 70)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 32, 54, 70)),
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _secureText ? Icons.visibility_off : Icons.visibility,
                          color: myFocusNode.hasFocus
                              ? Colors.blue
                              : Color.fromARGB(255, 32, 54, 70),
                        ),
                        onPressed: showHide),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                MaterialButton(
                  padding: EdgeInsets.all(20.0),
                  color: Color.fromARGB(255, 41, 69, 91),
                  onPressed: () {
                    check();
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MenuPage(signOut);
        break;
    }
  }
}
