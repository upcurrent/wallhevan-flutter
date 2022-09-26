import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cookie.dart';

Dio dio = Dio(BaseOptions(baseUrl: Api.url));

class Api {
  static String url = 'https://wallhaven.cc/';

  static String? _cookiePath;
  static Future<String> get cookiePath async {
    if (_cookiePath == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _cookiePath = appDocDir.path;
    }
    return _cookiePath!;
  }

  static CookieJar cookieJar = CookieJar();


  // /// The regex pattern for splitting the set-cookie header.
  // static final _regexSplitSetCookies = RegExp(
  //   r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
  //   caseSensitive: false,
  // );
  //
  // static void getSetCookie({required Response response}) {
  //   final headers = response.headers;
  //
  //   List<String>? setCookies = headers.map['set-cookie'];
  //   List<Cookie> cookies = [];
  //   for (final setCookie in setCookies!) {
  //     for (final cookie in setCookie.split(_regexSplitSetCookies)) {
  //       cookies.add(Cookie.fromSetCookieValue(cookie.split(';')[0]));
  //     }
  //   }
  //   print(cookies);
  //   cookieJar.saveFromResponse(Uri.parse(Api.url), cookies);
  //   dio.interceptors.add(CookieManager(Api.cookieJar));
  // }
}
Future<void> initDio() async {

  final prefs = await SharedPreferences.getInstance();
  List<String>? cookieStr = prefs.getStringList('cookie');

  if(cookieStr!=null){
    List<Cookie> cookieList = cookieStr.map((str) => Cookie.fromSetCookieValue(str)).toList();
    Api.cookieJar.saveFromResponse(Uri.parse(Api.url), cookieList);
  }

  dio.interceptors.add(HCookieManager(Api.cookieJar));

}

