
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class HCookieManager extends CookieManager{
  HCookieManager(super.cookieJar);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    cookieJar.loadForRequest(Uri.parse(Api.url)).then((cookies) {
      var cookie = getCookies(cookies);
      if (cookie.isNotEmpty) {
        List<String> cs = [];
        cs.addAll(cookies.map((e) => e.name));
        options.headers[HttpHeaders.cookieHeader] = cookie;
      }
      handler.next(options);
    }).catchError((e, stackTrace) {
      var err = DioError(requestOptions: options, error: e);
      err.stackTrace = stackTrace;
      handler.reject(err, true);
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveCookies(response)
        .then((_) => handler.next(response))
        .catchError((e, stackTrace) {
      var err = DioError(requestOptions: response.requestOptions, error: e);
      err.stackTrace = stackTrace;
      handler.reject(err, true);
    });
  }
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _saveCookies(err.response!)
          .then((_) => handler.next(err))
          .catchError((e, stackTrace) {
        if(err.response?.statusCode == 302){
          handler.resolve(err.response!);
          return;
        }
        var nErr = DioError(
          requestOptions: err.response!.requestOptions,
          error: e,
        );
        nErr.stackTrace = stackTrace;
        handler.next(nErr);
      });
    } else {
      handler.next(err);
    }
  }

  Future<void> _saveCookies(Response response) async {
    var cookies = response.headers[HttpHeaders.setCookieHeader];
    if (cookies != null) {
      // cookies.map((str) => Cookie.fromSetCookieValue(str)).toList()
      List<Cookie> list = cookies.map((str) => Cookie.fromSetCookieValue(str.split(';')[0])).toList();
      final prefs = await SharedPreferences.getInstance();
      List<String> cs = [];
      List<String> cookieStr = [];
      cs.addAll(cookies.map((e) => e.split('=')[0]));
      // print('response ${response.requestOptions.uri} ${cs.toString()}');
      cookieStr.addAll(list.map((e) => e.toString()));
      for(Cookie cookie in list){
        String name = cookie.name;
        if(name.contains('remember_web')){
          response.statusCode = 200;
          name = 'remember_web';
        }
        prefs.setString(name,cookie.toString());
      }
      await cookieJar.saveFromResponse(
        Uri.parse(Api.url),
        list,
      );
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}