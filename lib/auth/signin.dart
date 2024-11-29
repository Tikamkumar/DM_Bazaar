import 'dart:convert';
import 'dart:developer';
import 'package:dm_bazaar/Colors.dart';
import 'package:dm_bazaar/auth/forgot_pass.dart';
import 'package:dm_bazaar/auth/signup.dart';
import 'package:dm_bazaar/data/local/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  late UserPrefs userPres;
  bool isError = false;
  String errorMsg = 'Invalid Username';
  bool passwordVisible = false;
  bool isProgress = false;
  bool pageProgress = true;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userPres = UserPrefs();
    getToken();
  }

  void getToken() async {
    await dotenv.load(fileName: 'lib/.env');
    try {
      String? token = await UserPrefs().getToken();
      if(token!.length != 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch(exp) {
      log('Error : $exp');
    }
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    passController.dispose();
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
          child: /*!pageProgress ?*/ SingleChildScrollView(
            child: Column(
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
                const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20, width: 10),
                isError ? Container(
                    width: MediaQuery.of(context).size.width-40,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        // color: Colors.grey[100]!
                    ),
                    child: Text(errorMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
                ): const Text(''),
                Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width-40,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: phoneController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "mobile no..",
                          hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300)
                      ),
                    )
                ),
                const SizedBox(height: 10, width: 10),
                Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width-40,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      obscureText: passwordVisible,
                      controller: passController,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "password..",
                          hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300),
                          suffixIcon: IconButton(onPressed: (){
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          }, icon: passwordVisible ? Icon(Icons.visibility_off, color: Colors.white70) : Icon(Icons.visibility, color: Colors.white70))
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector( onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPass()));
                    }, child: const Text('Forget Password?', style: TextStyle(color: Colors.white))),
                  ),
                ),
                !isProgress ? GestureDetector(
                  onTap: signIn,
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: ColorSelect().buttonColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: const Center(
                      child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
                    ),
                  ),
                ) : Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Don\'t have an Account?', style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                    }, child: Text('Sign Up', style: TextStyle(color: Colors.white),))
                  ],
                )
              ],
            ),
          )/* : CircularProgressIndicator()*/,
        ),
      ),
    );
  }

  Future signIn() async {
    setState(() {
      isError = false;
    });
    if(phoneController.text.length != 10 || passController.text.length > 16 || passController.text.length < 8) {
      showError('Invalid Username or Password !');
      return;
    }
    setProgress(true);
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/api/log-in'),
        headers: {
          'Content-type':'application/json'
        },
        body: jsonEncode({
          'mobile':phoneController.text,
          'password':passController.text
        })
      );
      if(response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        userPres.saveToken(jsonDecode(response.body)['data']['token']);
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

  Future<String> showToken(Future<dynamic> data) async {
    String d = await data;
    return d;
  }

  void setProgress(bool flag) {
    setState(() {
      isProgress = flag;
    });
  }
}