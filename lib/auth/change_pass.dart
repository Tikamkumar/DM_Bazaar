import 'dart:convert';
import 'package:dm_bazaar/auth/signin.dart';
import 'package:dm_bazaar/data/local/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../Colors.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key, this.token, required this.flag, this.mobile});
  final String? token;
  final bool flag;
  final mobile;

  @override
  State<StatefulWidget> createState() => _changePassState();
}

class _changePassState extends State<ChangePassword> {
  final TextEditingController currPassController = TextEditingController();
  final TextEditingController newpassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool isError = false;
  String errorMsg = 'Invalid Username';
  bool currPassVisible = false;
  bool newPassVisible = false;
  bool confPassVisible = false;
  bool isProgress = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEnvFile();
  }

  void getEnvFile() async {
    await dotenv.load(fileName: 'lib/.env');
  }

  @override
  void dispose() {
    super.dispose();
    currPassController.dispose();
    newpassController.dispose();
    confirmPassController.dispose();
    setProgress(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/screen_bg.jpg'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(75)
                    ),
                    child: Image.asset('assets/app_icon.png', width: 150, height: 150)),
                const SizedBox(height: 20, width: 10),
                Text(widget.flag ? "Reset Password" : "Update Password", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20, width: 10),
                isError ? Container(
                    width: MediaQuery.of(context).size.width-40,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(errorMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
                ): const Text(''),
                !widget.flag ? Container(
                    height: 45,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      obscureText: currPassVisible,
                      keyboardType: TextInputType.visiblePassword,
                      controller: currPassController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Current password..",
                          hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300),
                          suffixIcon: !widget.flag ? IconButton(
                            icon: currPassVisible ? Icon(Icons.visibility_off, color: Colors.white70) : Icon(Icons.visibility, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                currPassVisible = !currPassVisible;
                              });
                            },
                          ) : null
                      ),
                    )) : Text(''),
                SizedBox(height: 10),
                Container(
                    height: 45,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      obscureText: newPassVisible,
                      keyboardType: TextInputType.visiblePassword,
                      controller: newpassController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "new password..",
                          hintStyle: TextStyle(color: Colors.grey[400]!, fontWeight: FontWeight.w300),
                          suffixIcon: IconButton(
                            icon: newPassVisible ? Icon(Icons.visibility_off, color: Colors.white70) : Icon(Icons.visibility, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                newPassVisible = !newPassVisible;
                              });
                            },
                          )
                      ),
                    )),
                Container(
                    height: 45,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      obscureText: confPassVisible,
                      keyboardType: TextInputType.visiblePassword,
                      controller: confirmPassController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "confirm password..",
                          hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300),
                          suffixIcon: IconButton(
                            icon: confPassVisible ? Icon(Icons.visibility_off, color: Colors.white70) : Icon(Icons.visibility, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                confPassVisible = !confPassVisible;
                              });
                            },
                          )
                      ),
                    )),
                !isProgress ? GestureDetector(
                  onTap: validateFunc,
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: ColorSelect().buttonColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Center(
                      child: Text(widget.flag ? 'Reset Password' : 'Update Password', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
                    ),
                  ),
                ): Container(
                  height: 40,
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                      color: ColorSelect().buttonColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: const Center(
                      child: SizedBox(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,), width: 20, height: 20,)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validateFunc() {
    if(!widget.flag) {
      if(currPassController.text.isEmpty) {
        showError('Enter Current Password !');
        return;
      }
    }

    if(newpassController.text.isEmpty) {
      showError('Password must be 8-16 characters !');
      return;
    }
    if(confirmPassController.text != newpassController.text) {
      showError('Password and Confirm Password not matched !');
      return;
    }
    setState(() {
      isError = false;
    });
    !widget.flag ? updatePass() : resetPass();
  }

  Future updatePass() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dotenv.env['BASE_URL']!)));
    setProgress(true);
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}'),
          headers: {
            'Content-type':'application/json',
            'Authorization':'Bearer ${widget.token}'
          },
          body: jsonEncode({
            'oldPassword':currPassController.text,
            'newPassword':newpassController.text,
          })
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
      if(response.statusCode == 200) {
        UserPrefs().saveToken('');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignIn()), ModalRoute.withName('/signin'));
        setProgress(false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
        setProgress(false);
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exp.toString())));
      setProgress(false);
    }
  }

  Future resetPass() async {
    setProgress(true);
    try {
      final response = await http.post(
          Uri.parse(dotenv.env['BASE_URL']! + 'api/create-password'),
          headers: {
            'Content-type':'application/json'
          },
          body: jsonEncode({
            'mobile':widget.mobile,
            'password':newpassController.text,
          })
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
      if(response.statusCode == 200) {
        UserPrefs().saveToken('');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignIn()), ModalRoute.withName('/signin'));
        setProgress(false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
        setProgress(false);
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exp.toString())));
      setProgress(false);
    }
  }

  void showError(String msg) {
    setState(() {
      errorMsg = msg;
      isError = true;
    });
  }

  void setProgress(bool flag) {
    setState(() {
      isProgress = flag;
    });
  }
}