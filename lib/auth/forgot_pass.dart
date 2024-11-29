import 'dart:convert';
import 'dart:developer';
import 'package:dm_bazaar/auth/verify_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../Colors.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<ForgotPass> {
  final TextEditingController phoneController = TextEditingController();
  bool isError = false;
  String errorMsg = 'Invalid Username';
  bool isProgress = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEnvFile();
  }

  getEnvFile() async {
    await dotenv.load(fileName: 'lib/.env');
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
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
              children: <Widget>[
                Image.asset('assets/img_signin.png', width: 150, height: 150),
                const SizedBox(height: 20, width: 10),
                const Text("Enter Mobile No", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20, width: 10),
                isError ? Container(
                    width: MediaQuery.of(context).size.width-40,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(bottom: 10),
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
                !isProgress ? GestureDetector(
                  onTap: generateOtp,
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: ColorSelect().buttonColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: const Center(
                      child: Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
                    ),
                  ),
                ) : Container(
                  height: 40,
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                      color: ColorSelect().buttonColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10))
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

  Future generateOtp() async {
    setState(() {
      isError = false;
    });
    if(phoneController.text.length != 10) {
      showError('Invalid Mobile No !');
      return;
    }
    setProgress(true);
    try {
      final response = await http.post(
          Uri.parse("${dotenv.env['BASE_URL']}api/verify-number"),
          headers: {
            'Content-type':'application/json'
          },
          body: jsonEncode({
            'mobile':phoneController.text
          })
      );
      log('Response : ${response.body}');
      if(response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerificationCode(mobileNo: phoneController.text, flag: true)));
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