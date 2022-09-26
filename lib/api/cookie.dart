
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HCookieManager extends CookieManager{
  HCookieManager(super.cookieJar);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    cookieJar.loadForRequest(options.uri).then((cookies) {
      var cookie = getCookies(cookies);
      if (cookie.isNotEmpty) {
        print(options.uri);
        print(cookie);
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
        var _err = DioError(
          requestOptions: err.response!.requestOptions,
          error: e,
        );
        _err.stackTrace = stackTrace;
        handler.next(_err);
      });
    } else {
      handler.next(err);
    }
  }

  Future<void> _saveCookies(Response response) async {
    var cookies = response.headers[HttpHeaders.setCookieHeader];
    if (cookies != null) {
      print(cookies);
      List<Cookie> list = cookies.map((str) => Cookie.fromSetCookieValue(str.split(';')[0])).toList();
      List<String> cookieStr = [];
      final prefs = await SharedPreferences.getInstance();
      cookieStr.addAll(list.map((e) => e.toString()));
      prefs.setStringList('cookie', cookieStr);
      await cookieJar.saveFromResponse(
        response.requestOptions.uri,
        list,
      );
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}