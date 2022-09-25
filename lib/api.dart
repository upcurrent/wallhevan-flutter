import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

Dio dio = Dio(BaseOptions(baseUrl: Api.url));

class Api {
  static String url = 'https://wallhaven.cc/';


  static late PersistCookieJar _cookieJar = PersistCookieJar();

  static Future<PersistCookieJar> get cookieJar async {
    // print(_cookieJar);
    if (null == _cookieJar) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath  = appDocDir.path;
      print('获取的文件系统目录 appDocPath： ' + appDocPath);
      _cookieJar = PersistCookieJar(ignoreExpires: true,
          storage: FileStorage(appDocPath));
    }
    return _cookieJar;
  }


  /// The regex pattern for splitting the set-cookie header.
  static final _regexSplitSetCookies = RegExp(
    r"""(?<!expires=\w{3}|"|')\s*,\s*(?!"|')""",
    caseSensitive: false,
  );

  static void getSetCookie({required Response response}) async {
    final headers = response.headers;

    List<String>? setCookies = headers.map['set-cookie'];
    List<Cookie> cookies = [];
    for (final setCookie in setCookies!) {
      for (final cookie in setCookie.split(_regexSplitSetCookies)) {
        cookies.add(Cookie.fromSetCookieValue(cookie.split(';')[0]));
      }
    }
    // print(_cookies);
    (await Api.cookieJar).saveFromResponse(Uri.parse(Api.url), cookies);
    dio.interceptors.add(CookieManager(await Api.cookieJar));
  }
}
void initDio(){
  Api.cookieJar.then((cookieJar){
    dio.interceptors.add(CookieManager(cookieJar));
  });
}

