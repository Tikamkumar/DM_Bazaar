import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dm_bazaar/auth/change_pass.dart';
import 'package:dm_bazaar/auth/signin.dart';
import 'package:dm_bazaar/data/local/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../Colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool currPassVisible = false;
  bool newPassVisible = false;
  bool confPassVisible = false;
  bool isProgress = false;
  String currentUrl = '';
  List<Map<String, dynamic>> games = [];
  Map<String, dynamic> latestResult = {};
  List<Map<String, dynamic>> applications = [];
  List<String> sliders = [];
  String? token;
  String? name;
  String? phoneNo;
  BuildContext? con;
  late ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    token = await UserPrefs().getToken();
    await dotenv.load(fileName: 'lib/.env');
    getGames();
    getProfileData();
    getAllApplication();
    getLatest();
    getSliderImage();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: true);
    pr.style(
     message: 'Downloading APKfile...',
      widgetAboveTheDialog: const Text('meow'),
     borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    con = context;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorSelect().buttonColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Welcome, $name Ji', style: const TextStyle(color: Colors.white, fontSize: 18)),
              Text('$phoneNo', style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton(
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
              return {'Change Password', 'Logout'}.map((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Text(value)
                );
              }).toList();
            })
          ],
          actionsIconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/screen_bg.jpg'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                games.length == 0 ? CarouselSlider(items: sliders.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        height: 180,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 2,
                              spreadRadius: 5,
                              offset: Offset(2, 5)
                            )
                          ],
                          image: DecorationImage(
                            image: NetworkImage("${dotenv.env['BASE_URL']}uploads/${item}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),/*[
                  ListView.builder(
                      itemCount: sliders.length,
                      itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 180,
                       decoration: BoxDecoration(
                        // borderRadius: BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                          image: NetworkImage("${dotenv.env['BASE_URL']}uploads/${sliders[index]}"),
                          fit: BoxFit.cover,
                         ),
                    ),
                  );
                  })
            ]*/
              options: CarouselOptions(
                height: 180.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
              )
          ) :
                CarouselSlider(items: applications.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        /*height: 120,*/
                        decoration: BoxDecoration(
                            color: const Color(0xE3B0F8FF),
                            border: Border.all(color: Color(0xE302C4FC), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[300]!,
                                  blurRadius: 1,
                                  spreadRadius: 3,
                                  offset: const Offset(1, 3)
                              )
                            ]
                        ),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network('${dotenv.env['BASE_URL']}uploads/${item['image']}', height: 120, width: MediaQuery.of(context).size.width*0.3),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  margin: EdgeInsets.only(bottom: 5, left: 5),
                                  child: Text(item['name'].toString(), style: TextStyle(color: Colors.purple, fontSize: 25)),
                                ),
                                GestureDetector(
                                  onTap:() async {
                                    await pr.show();
                                    try {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${dotenv.env['BASE_URL']}uploads/${item['path']}')));
                                      final url = '${dotenv.env['BASE_URL']}uploads/${item['path']}'.trim();
                                      String fileName = url.toString().split('/').last;
                                      String path = await getFilePath(fileName);
                                      await Dio().download(url, path, deleteOnError: true ).then((_) async {
                                        await pr.hide();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apk Download Successfully...')));
                                      });
                                    } catch(exp) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exp.toString())));
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    margin: EdgeInsets.only(bottom: 5, right: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.purpleAccent,
                                        borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Center(child: Text('Download Now', style: TextStyle(color: Colors.white))),
                                  ),
                                ),
                              ],
                            )
                            // Image.network('${dotenv.env['BASE_URL']}uploads/${applications[pagePosition]['image']}', height: 120, width: MediaQuery.of(context).size.width*0.3),

                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
                    options: CarouselOptions(
                      height: 130.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    )
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 2,
                            spreadRadius: 5,
                            offset: Offset(0, 5)
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width/2,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                              ),
                              child: Center(child: Text('Top Latest Result', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18)))),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(latestResult['result'].toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 100)),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width/2,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                            ),
                              child: Center(child: Text(latestResult['name'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 20)))),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 150,
                 width: double.infinity,
                 child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                      itemCount: games.length, itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      height: 150,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 2,
                            spreadRadius: 1,
                            offset: Offset(0, 5)
                          )
                        ]
                      ),
                      child: Column(

                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('(${games[index]['yesterday']})', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 30)),
                                    Text('Yesterday', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('(${games[index]['today']})', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 30)),
                                    Text('Today', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                  ],
                                )
                                ],
                            ),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                            ),
                            width: double.infinity,
                            child: Center(child: Text(games[index]['name'], style: TextStyle(color: Colors.white, fontSize: 20)))
                          )
                        ],
                      ),
                    );
                  }),
               ),
                SizedBox(height: 50)
              ],
            ),
          ),
        )
    );
  }

  Future<void> getLatest() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}get-latest-result'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
        );
      if(response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)["data"];
        log(data[0]['latestResult'][0]['data']);
        latestResult = {'name': data[0]['name'], 'result':data[0]['latestResult'][0]['data']};
        setState(() {
          latestResult;
        });
     } else {
       ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text('error' + jsonDecode(response.body)['errorMsg'])));
     }
    } catch(exp) {
      ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }
  Future<void> getGames() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}get-games-result'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
        );
      if(response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)["data"];
        for(int i = 0; i < data.length; i++) {
          Map<String, dynamic> item = data[i];
          String name = item['name'];
          String yesterday = "--";
          String today = "--";
          List<dynamic> result = item['results'];
          for(int i = 0; i < result.length; i++) {

            if(timestampToDate(result[i]['date']) == currentDate()) {
              today = result[i]['data'];
            }
            if(timestampToDate(result[i]['date']) == yesterdayDate()) {
              yesterday = result[i]['data'];
            }
          }
          games.add({'name': name, 'yesterday': yesterday, 'today': today});
        }
        setState(() {
          games;
        });
     } else {
       ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
     }
    } catch(exp) {
      ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }

  Future<void> getAllApplication() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}all-applications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
        );
      if(response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)["data"];
        for(int i = 0; i < data.length; i++) {
          Map<String, dynamic> item = data[i];
          if(item['isShown']) {
            applications.add({'path': item['path'], 'name': item['name'], 'image': item['image']});
          }
        }
        setState(() {
          applications;
        });
     } else {
       ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
     }
    } catch(exp) {
      ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }

  Future<void> getSliderImage() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}get-slider-images'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
        );
      if(response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)["data"];
        for(int i = 0; i < data.length; i++) {
          sliders.add(data[i]['image']);
        }
        setState(() {
          sliders;
        });
     } else {
       ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['errorMsg'])));
     }
    } catch(exp) {
      ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }

  Future<void> getProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/get-user'),
        headers: {
          'Content-type':'application/json',
          'Authorization':'Bearer $token'
        }
      );
      if(response.statusCode == 200) {
         setUserUI(jsonDecode(response.body)['data']['name'], jsonDecode(response.body)['data']['phone'].toString());
      }
    } catch(exp) {
       ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }

  void setUserUI(String name, String phoneNo) {
     setState(() {
       this.name = name;
       this.phoneNo = phoneNo;
     });
  }

  String currentDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  String yesterdayDate() {
    final yes = DateTime.now().subtract(Duration(days: 1));
    return "${yes.year}-${yes.month}-${yes.day}";
  }

  String timestampToDate(String timestamp) {
    DateTime datetime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd').format(datetime);
  }

  void handleClick(String value) {
    switch(value) {
      case 'Change Password': {
        Navigator.of(con!).push(MaterialPageRoute(builder: (context) => ChangePassword(token: token!, flag: false)));
      }
      break;
      case 'Logout': {
        logoutDialog(con!);
      }
      break;
    }
  }

  Future logoutDialog(BuildContext context) {
     return showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Confirm Logout ? '),
           actions: <Widget>[
             TextButton(onPressed: () {
               Navigator.pop(context);
             }, child: Text('Cancle')),
             TextButton(onPressed: () {
               Navigator.pop(context);
                logout();
             }, child: Text('Yes')),

           ],
         );
       }
     );
  }

  Future logout() async {
    try {
       final response = await http.delete(
         Uri.parse('${dotenv.env['BASE_URL']}log-out'),
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
             'Authorization': 'Bearer $token',
           }
       );
      if(response.statusCode == 200) {
         UserPrefs().saveToken('');
         Navigator.pushAndRemoveUntil(con!, MaterialPageRoute(builder: (context) => const SignIn()), ModalRoute.withName('/signin'));
       }
    } catch(exp) {
      ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(exp.toString())));
    }
  }

  Future<String> getFilePath(String filename) async {
    return join(await getExternalDocumentPath(), filename);
  }

  Future<void> requestPermissions() async {
    final permission = Permission.camera;
    if(await permission.isDenied) {
      await permission.request();
    }
  }

  Future<String> getExternalDocumentPath() async {
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download");
    }
    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    ScaffoldMessenger.of(con!).showSnackBar(SnackBar(content: Text(_directory.toString())));
    return exPath;
  }

}