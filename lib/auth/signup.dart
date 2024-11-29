import 'dart:convert';
import 'package:dm_bazaar/Colors.dart';
import 'package:dm_bazaar/auth/signin.dart';
import 'package:dm_bazaar/auth/verify_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
   const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool isError = false;
  String errorMsg = 'Invalid Username';
  bool passwordVisible = false;
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
      nameController.dispose();
      phoneController.dispose();
      passController.dispose();
      confirmPassController.dispose();
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
                 const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500)),
                 const SizedBox(height: 20, width: 10),
                 isError ? Container(
                     width: MediaQuery.of(context).size.width-40,
                     padding: const EdgeInsets.all(5),
                     margin: const EdgeInsets.only(bottom: 10),
                     child: Text(errorMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
                 ): const Text(''),
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
                       controller: nameController,
                       maxLines: 1,
                       textAlignVertical: TextAlignVertical.center,
                       decoration: InputDecoration(
                           border: InputBorder.none,
                           hintText: "name..",
                           hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300)
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
                       style: const TextStyle(color: Colors.white),
                       keyboardType: TextInputType.number,
                       inputFormatters: <TextInputFormatter>[
                         FilteringTextInputFormatter.digitsOnly
                       ],
                       controller: phoneController,
                       maxLines: 1,
                       textAlignVertical: TextAlignVertical.center,
                       decoration: InputDecoration(
                           border: InputBorder.none,
                           hintText: "mobile no..",
                           hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300)
                       ),
                     )),
                 Container(
                     height: 45,
                     width: double.infinity,
                     padding: EdgeInsets.symmetric(horizontal: 8),
                     margin: EdgeInsets.symmetric(horizontal: 20),
                     decoration: BoxDecoration(
                         color: Colors.black54,
                         border: Border.all(color: Colors.grey[300]!, width: 1),
                         borderRadius: const BorderRadius.all(Radius.circular(8))
                     ),
                     child: TextField(
                       style: TextStyle(color: Colors.white),
                       obscureText: passwordVisible,
                       keyboardType: TextInputType.visiblePassword,
                       controller: passController,
                       maxLines: 1,
                       textAlignVertical: TextAlignVertical.center,
                       decoration: InputDecoration(
                           border: InputBorder.none,
                           hintText: "password..",
                           hintStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300),
                           suffixIcon: IconButton(
                             icon: passwordVisible ? Icon(Icons.visibility_off, color: Colors.white70) : Icon(Icons.visibility, color: Colors.white70),
                             onPressed: () {
                               setState(() {
                                 passwordVisible = !passwordVisible;
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
                         border: Border.all(color: Colors.grey[300]!, width: 1),
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
                     child: const Center(
                       child: Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
                     ),
                   ),
                 ): Container(
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
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: <Widget>[
                     const Text('Already have an Account?', style: TextStyle(color: Colors.white)),
                     TextButton(onPressed: (){
                       Navigator.pop(context);
                     }, child: const Text('Sign In', style: TextStyle(color: Colors.white)))
                   ],
                 )
               ],
             ),
           ),
         ),
       ),
     );
  }

  void validateFunc() {
    if(nameController.text.isEmpty) {
       showError('Enter Username !');
       return;
    }
    if(phoneController.text.isEmpty || phoneController.text.length != 10) {
      showError('Invalid Mobile no !');
      return;
    }
    if(passController.text.isEmpty) {
      showError('Password must be 8-16 characters !');
      return;
    }
    if(passController.text != confirmPassController.text) {
      showError('Password and Confirm Password not matched !');
      return;
    }
    setState(() {
      isError = false;
    });
    signUp();
  }

  Future signUp() async {
    setProgress(true);
     try {
       final response = await http.post(
         Uri.parse('${dotenv.env['BASE_URL']}api/sign-up'),
         headers: {
           'Content-type':'application/json'
         },
         body: jsonEncode({
           'mobile':phoneController.text
         })
       );
       if(response.statusCode == 200) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationCode(name: nameController.text, mobileNo: phoneController.text, password: passController.text, flag: false)));
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
    if(mounted) {
      setState(() {
        isProgress = flag;
      });
    }
  }
}