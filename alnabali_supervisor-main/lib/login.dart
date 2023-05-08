import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:driver_app/commons.dart';
import 'package:driver_app/sub_main.dart';
import 'package:driver_app/widgets/button_field.dart';
import 'package:driver_app/widgets/input_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class MyLogin extends StatelessWidget {
  MyLogin({super.key});

  final nameController = TextEditingController();
  final passController = TextEditingController();

  static setToken() async {
    developer.log("init");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
    };

    final response = await http.get(
        Uri.parse('http://167.86.102.230/alnabali/public/android/driver/token'),
        // Send authorization headers to the backend.
        headers: requestHeaders);

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    String token = responseJson["token"];
    Commons.token = token;
  }

  login(BuildContext context, TextEditingController nameCon,
      TextEditingController passCon) async {
    if (nameCon.text == "" && passCon.text == "") {
      Commons.showErrorMessage("Input Name and Password!");
      return;
    }
    Map data = {
      'email': nameCon.text,
      'password': passCon.text,
    };
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
      // 'Authorization': Commons.token,
      'X-CSRF-TOKEN': Commons.token
    };

    // requestHeaders['cookie'] = Commons.cookie;

    String url = "${Commons.baseUrl}supervisor/login";
    var response =
        await http.post(Uri.parse(url), body: data, headers: requestHeaders);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('login_id', 'null');
    preferences.setString('name', 'null');
    preferences.setBool('isLogin', false);
    if (response.statusCode == 200) {
      developer.log("msg7" + "success http request");
      if (responseJson['result'] == "Invalid SuperVisor") {
        Commons.showErrorMessage('Invalid User');
      } else if (responseJson['result'] == "Invalid Password") {
        Commons.showErrorMessage('Invalid Password');
      } else {
        Commons.login_id = responseJson['id'].toString();
        Commons.name = responseJson['name'].toString();
        Commons.isLogin = true;

        preferences.setString('login_id', responseJson['id'].toString());
        preferences.setString('name', responseJson['name'].toString());
        preferences.setBool('isLogin', true);

        Navigator.pushNamed(context, "/main");
        // setState( () {
        sharedPreferences.setString("token", Commons.token);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => SubMain()),
            (route) => false);
        // })
      }
    } else {
      Fluttertoast.showToast(
          msg: "Login Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }

  OutlineInputBorder myinputborder() {
    //return type is OutlineInputBorder
    return OutlineInputBorder(
        //Outline border type for TextFeild
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(
          color: Colors.white,
          width: 3,
        ));
  }

  OutlineInputBorder myfocusborder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(
          color: Colors.white,
          width: 3,
        ));
  }

  @override
  Widget build(BuildContext context) {
    setToken();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/bg.png"), fit: BoxFit.cover)),
              height: MediaQuery.of(context).size.height,
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 14),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/bus_to.png",
                      width: MediaQuery.of(context).size.width / 2.1,
                      height: MediaQuery.of(context).size.width / 2.1,
                      alignment: Alignment.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 20),
                    Text(
                      "login".tr(),
                      style: TextStyle(
                        fontSize:
                            2.9 * MediaQuery.of(context).size.height * 0.01,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 12),
                    // InputField(
                    //     inputType: "username", controller: nameController),
                    // SizedBox(height: MediaQuery.of(context).size.height / 20),
                    // InputField(
                    //     inputType: "password",
                    //     controller: passController,
                    //     editComplete: () =>
                    //         login(context, nameController, passController)),
                    // SizedBox(height: MediaQuery.of(context).size.height / 13),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          fillColor: Colors.white,
                          iconColor: Colors.white,
                          prefixIcon: Icon(Icons.people),
                          border: myinputborder(),
                          enabledBorder: myinputborder(),
                          focusedBorder: myfocusborder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: TextField(
                        onSubmitted: (value) {
                          login(context, nameController, passController);
                        },
                        obscureText: true,
                        controller: passController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          fillColor: Colors.white,
                          iconColor: Colors.white,
                          prefixIcon: Icon(Icons.key),
                          border: myinputborder(),
                          enabledBorder: myinputborder(),
                          focusedBorder: myfocusborder(),
                        ),
                        textInputAction:
                            TextInputAction.done, // Moves focus to next.
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ButtonField(
                        buttonType: "login",
                        onPressedCallback: () {
                          login(context, nameController, passController);
                        }),
                    SizedBox(height: MediaQuery.of(context).size.height / 9),
                    // GestureDetector(
                    //     onTap: () {
                    //       // setToken();
                    //       Navigator.pushNamed(context, "/forget_password");
                    //     },
                    //     child: Text(
                    //       "forget_password".tr(),
                    //       style: TextStyle(
                    //           shadows: const [
                    //             Shadow(
                    //                 color: Colors.white, offset: Offset(0, -5))
                    //           ],
                    //           decoration: TextDecoration.underline,
                    //           color: Colors.transparent,
                    //           fontSize: 2.4 *
                    //               MediaQuery.of(context).size.height *
                    //               0.008,
                    //           letterSpacing: 1.2,
                    //           decorationThickness: 2,
                    //           fontFamily: 'Montserrat',
                    //           fontWeight: FontWeight.w500,
                    //           decorationColor: Colors.white),
                    //     )),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
