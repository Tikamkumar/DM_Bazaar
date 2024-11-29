
abstract class BaseApiService {
  final String BASE_URL = "http://192.168.1.11:5002";

  Future<dynamic> signUp(String url, Map<String, String> jsonbody);
  Future<dynamic> verifyCode(String url, Map<String, String> jsonbody);
  Future<dynamic> signIn(String url, Map<String, String> jsonbody);
}