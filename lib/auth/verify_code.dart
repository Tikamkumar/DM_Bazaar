import 'package:dm_bazaar/auth/change_pass.dart';
import 'package:dm_bazaar/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCode extends StatefulWidget {
  const VerificationCode({super.key, this.name, this.mobileNo, this.password, required this.flag});
  final name;
  final mobileNo;
  final password;
  final bool flag;

   @override
   State<StatefulWidget> createState() => _verifyCodeState();
}

class _verifyCodeState extends State<VerificationCode> {
  bool isError = true;
  String errorMsg = 'Invalid Username';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/screen_bg.jpg'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: !isProgress ? Column(
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
                const Text("Verification Code", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500)),
                const SizedBox(height: 30, width: 10),
                OtpTextField(
                  textStyle: TextStyle(color: Colors.white),
                  numberOfFields: 6,
                  borderColor: Colors.white,
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode){
                    if(widget.flag) {
                      verifyforgetPassOtp(verificationCode);
                    } else {
                      verifyOtp(verificationCode);
                    }
                    },
                ),
                const SizedBox(height: 50, width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Don\'t Get Otp?', style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: (){
                      resendOtp();
                    }, child: const Text('Resend Otp', style: TextStyle(color: Colors.white),))
                  ],
                )
              ],
            ) : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Future verifyOtp(String code) async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}api/verify-otp'),
        headers: {
          'Content-type':'application/json'
        },
        body: jsonEncode({
          'mobile':widget.mobileNo,
          'otp':code,
          'name':widget.name,
          'password':widget.password
        })
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
      if(response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign Up Successfully..")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something wrong..")));
    }
  }

  Future resendOtp() async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}api/sign-up'),
          headers: {
            'Content-type':'application/json'
          },
          body: jsonEncode({
            'mobile':widget.mobileNo
          })
      );
      if(response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
        setProgress(false);
      } else {
        setProgress(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something wrong..')));
      setProgress(false);
    }
  }

  Future verifyforgetPassOtp(String code) async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}api/api/verify-mobile-otp'),
          headers: {
            'Content-type':'application/json'
          },
          body: jsonEncode({
            'mobile':widget.mobileNo.toString(),
            'otp':code,
          })
      );
      if(response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePassword(flag: true, mobile: widget.mobileNo)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(exp.toString())));
    }
  }

  Future resendforgetPassOtp() async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}api/verify-number'),
          headers: {
            'Content-type':'application/json'
          },
          body: jsonEncode({
            'mobile':widget.mobileNo
          })
      );
      if(response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
        setProgress(false);
      } else {
        setProgress(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch(exp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something wrong..')));
      setProgress(false);
    }
  }

  void setProgress(bool flag) {
    setState(() {
      isProgress = flag;
    });
  }

  void showError(String msg) {
    setState(() {
      errorMsg = msg;
      isError = true;
    });
  }
}