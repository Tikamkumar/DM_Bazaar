import 'dart:io';
import 'dart:convert';
import 'package:dm_bazaar/data/remote/network/base.api.service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class NetworkApiService extends BaseApiService {

  @override
  Future signUp(String url, Map<String, String> jsonbody) async {
    dynamic retResponse;
    try {
      final response = await http.post(Uri.parse(url), body: jsonbody);
      retResponse = returnResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection.");
    }
    return retResponse;
  }

  @override
  Future signIn(String url, Map<String, String> jsonbody) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future verifyCode(String url, Map<String, String> jsonbody) {
    // TODO: implement verifyCode
    throw UnimplementedError();
  }

  dynamic returnResponse(http.Response response) {
    switch(response.statusCode) {
      case 200: return jsonDecode(response.body);
      case 201: return jsonDecode(response.body);
      default: return jsonDecode(response.body)['errorMsg'];
    }
  }
  
}