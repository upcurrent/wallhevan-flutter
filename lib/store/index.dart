import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:html/parser.dart' show parse;
import 'package:wallhevan/api/api.dart';
import '../main.dart' show WallImage;

enum StoreActions {
  addAllWallImage,
  addAllWidget,
  addWallImage,
  addCookie,
  changeIndex,
  loading,
  init,
  loadMore,
  preview,
  selectBottomNav,
  accountChange,
}

MainState counterReducer(MainState state, dynamic action) {
  switch (action['type']) {
    case StoreActions.addAllWallImage:
      if (state.pageNum == 2) {
        state.imageDataList.clear();
      }
      state.imageDataList.addAll(action['data']);
      break;
    case StoreActions.addAllWidget:
      if (state.pageNum == 2) {
        state.imageList.clear();
      }
      state.imageList.addAll(action['data']);
      break;
    case StoreActions.addWallImage:
      state.imageDataList.add(action['data']);
      break;
    case StoreActions.addCookie:
      state.cookie = (action['data']);
      break;
    case StoreActions.changeIndex:
      state.currentIndex = action['data'];
      break;
    case StoreActions.loading:
      state.loading = !state.loading;
      break;
    case StoreActions.loadMore:
    case StoreActions.init:
      // getImage(action['context'], state);
      break;
    case StoreActions.selectBottomNav:
      state.bottomNavIndex = action['data'];
      break;
    case StoreActions.preview:
      state.currentIndex = action['currentIndex'];
      state.preview = !state.preview;
      break;
    case StoreActions.accountChange:
      state.account = action['data'];
      break;
  }
  return state;
}

void fetchContactorMiddleware(
    Store<MainState> store, action, NextDispatcher next) {
  if (action['type'] == StoreActions.init) {
    store.state.pageNum = 1;
    getImage(store);
  }
  if (action['type'] == StoreActions.loadMore) {
    store.state.pageNum++;
    getImage(store);
  }
  next(action);
}

class MainState {
  final List<Widget> imageList;
  final List<WallImage> imageDataList;
  bool preview;
  bool loading;
  int pageNum;
  int currentIndex;
  int bottomNavIndex;
  UserAccount account = UserAccount();
  String cookie = '';
  MainState(this.imageList, this.imageDataList, this.preview, this.loading,
      this.pageNum, this.currentIndex, this.bottomNavIndex);

  factory MainState.initState() => MainState([], [], false, false, 1, 0, 0);

  void addWallImage(WallImage img) {
    imageDataList.add(img);
  }

  void addPictureWidget(Widget widget) {
    imageList.add(widget);
  }
}

class HandleActions {
  Store<MainState> store;

  HandleActions(this.store);

  bool loading = false;

  void userNameChanged(String userName) {
    store.state.account.username = userName;
    store.dispatch(
        {'type': StoreActions.accountChange, 'data': store.state.account});
  }

  void passwordChanged(String pwd) {
    store.state.account.password = pwd;
    store.dispatch(
        {'type': StoreActions.accountChange, 'data': store.state.account});
  }

  void tokenChanged(String token) {
    store.state.account.token = token;
    store.dispatch(
        {'type': StoreActions.accountChange, 'data': store.state.account});
  }

  void setCookie(String cookie) {
    // cookie.split(';')
    // var dc = Cookie();
    // dio.interceptors.add(cookie);
  }

  void getToken() {
    if (loading) return;
    loading = true;
    Map<String, String> header = {};
    // if(store.state.cookie.isNotEmpty){
    //   header =  {
    //     'cookie':store.state.cookie
    //   };
    // }
    dio.get('/login', options: Options(headers: header)).then((response) {
      loading = false;
      // Api.cookieJar.loadForRequest(uri)
      // CookieManager.
      // Api.getSetCookie(response: response);
      // print('login cookie');
      // print( response.headers.map['set-cookie']);
      var body = parse(response.data);
      var input = body.querySelector('[name="_token"]');
      var token = input?.attributes['value'];
      tokenChanged(token!);
    });
  }

  void login() {
    UserAccount account = store.state.account;
    dio
        .post('/auth/login',
            data: {
              '_token': account.token,
              'username': account.username,
              'password': account.password,
            },
            options: Options(
                followRedirects: false,
                validateStatus: (status) {
                  return status! < 500;
                }))
        .then((response) {
      // Api.getSetCookie(response: response);
      // print(response.headers['set-cookie']);
    }, onError: (error) {
      print(error);
    });
  }
}

class UserAccount {
  String username = 'ikism';
  String password = 'qpwoeiruty-1234';
  String token = '';
  String cookieStr = '';
  @override
  String toString() {
    return 'UserAccount{userName: $username, password: $password, token: $token}';
  }

// UserAccount(this.userName, this.password, this.token);

}

void getImage(Store<MainState> store) {
  if (store.state.loading) return;
  //https://wallhaven.cc/search?categories=010&purity=110&topRange=1M&sorting=toplist&order=desc
  //https://wallhaven.cc/search?categories=010&purity=001&sorting=hot&order=desc
  var params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': store.state.pageNum.toString(),
  };
  store.state.loading = true;
  dio
      .get('/search',
          queryParameters: params,
          options: Options(headers: {'x-requested-with': 'XMLHttpRequest'}))
      .then((response) {
    store.state.loading = false;

    // Api.getSetCookie(response: response);

    var document = parse(response.data.replaceAll("/small/", "/orig/"));
    var figureList = document.getElementsByTagName("figure");
    List<Widget> list = [];
    List<WallImage> dataList = [];
    // double halfWidth = MediaQuery.of(context).size.width / 2;
    for (var element in figureList) {
      var img = element.querySelector('img');
      var href = element.querySelector('.preview');
      var size = element.querySelector('.wall-res');
      var png = element.querySelector('.png');
      var obj = WallImage('');
      img?.attributes.forEach((key, value) {
        if (key == "data-src") {
          obj.pSrc = value;
        }
      });
      href?.attributes.forEach((key, value) {
        if (key == "href") {
          obj.href = value;
        }
      });
      String nSize = (size?.innerHtml).toString();
      List sizes = nSize.split(' x ');

      if (sizes.isNotEmpty) {
        double rWidth = double.parse(sizes[0]);
        double rHeight = double.parse(sizes[1]);
        // double pHeight = rHeight / (rWidth / halfWidth);
        obj.width = rWidth;
        obj.height = rHeight;
        List<String> fullSrc = obj.pSrc
            .replaceAll('/th.wallhaven.cc/orig/', '/w.wallhaven.cc/full/')
            .split('/');
        fullSrc[fullSrc.length - 1] =
            "wallhaven-${fullSrc[fullSrc.length - 1]}";
        if (png != null) {
          fullSrc[fullSrc.length - 1] =
              fullSrc[fullSrc.length - 1].replaceAll('.jpg', '.png');
        }
        obj.src = fullSrc.join('/');
        // obj.pSrc = obj.src; // TODO be remove
        // debugPrint(obj.toString());
        // list.add(PictureComp(
        //     // pHeight: pHeight,
        //     // halfWidth: halfWidth,
        //     image: obj,
        //     type: WallImage.previewPicture));
        // } else {
        //   list.add(Image.network(obj.pSrc, fit: BoxFit.scaleDown));
      }
      // print(obj);
      dataList.add(obj);
    }
    // print(state.im)
    store.dispatch({'type': StoreActions.addAllWidget, 'data': list});
    store.dispatch({'type': StoreActions.addAllWallImage, 'data': dataList});
  }).catchError((error) => {print(error.toString())});
}
