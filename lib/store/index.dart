import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
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
  searchChange
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
    case StoreActions.searchChange:
      // state.params = action['data'];
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
  int bottomNavIndex = 2;
  UserAccount account = UserAccount();
  SearchParams search = SearchParams();
  String cookie = '';
  bool dioReady = false;
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

class SearchParams {
  String categories = '010';
  String purity = '110';
  String topRange = '1M';
  String sorting = 'toplist';
  String order = 'desc';
  final  Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': '1',
  };
  final Map<String,String> categoriesMap = {
    'General':'1',
    'Anime':'0',
    'People':'0',
  };
  final Map<String,String> sortingMap = {
    'TopList':'toplist',
    'Hot':'hot',
    'Random':'random',
    'Latest':'date_added',
    'Views':'views',
    'Favorites':'favorites',
    'Relevance':'relevance',
  };
  final Map<String,String> purityMap = {
    'SFW':'1',
    'Sketchy':'0',
    'NSFW':'0',
  };
  final List<String> topRangeMap = ['1d', '3d',' 1w','1M', '3M', '6M','1y'];
  Map<String, String> getParams(int pageNum){
    return {
      'categories': categories,
      'purity': purity,
      'topRange': topRange,
      'sorting': sorting,
      'order': order,
      'page': pageNum.toString(),
    };
  }
}


class HandleActions {
  Store<MainState> store;

  HandleActions(this.store);

  bool loading = false;

  MainState getMainState(){
    return store.state;
  }

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

  void setParams(String key,String value) {
    store.state.search.params[key] = value;
    store.dispatch({'type': StoreActions.searchChange});
  }

  void loadMore() {
    store.dispatch({'type':StoreActions.loadMore});
  }

  Future<String> getToken(String url) async {
    loading = true;
    Map<String, String> header = {};
    Response response = await dio.get(url, options: Options(headers: header));
    loading = false;
    var body = parse(response.data);
    var input = body.querySelector('[name="_token"]');
    var token = input?.attributes['value'];
    if(token != null){
      tokenChanged(token);
      return token;
    }
    return '';
  }
  void initAccount() async{
    final prefs = await SharedPreferences.getInstance();
    String? diskUserName = prefs.getString('username');
    if(diskUserName != null){
      getToken('/user/$diskUserName');
      userNameChanged(diskUserName);
    }
  }

  void login() {
    if (loading) return;
    UserAccount account = store.state.account;
    loading = true;
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
        .then((response) async {
      loading = false;
      // login Success
      if(response.statusCode == 302){
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', account.username);
        prefs.setString('password', account.password);
      }
    });
  }

  void logOut() async{
    if (loading) return;
    loading = true;
    UserAccount account = store.state.account;
    getToken('/user/${account.username}').then((token) async{
      if(token.isNotEmpty){
        await dio.post('/auth/logout',data:{'_token':account.token},options: Options(followRedirects: false,validateStatus: (status) {
          return status! < 500;
        }));
        loading = false;
      }else {
        loading = false;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    account.password = '';
    account.token = '';
    account.username = '';
    store.dispatch(
        {'type': StoreActions.accountChange, 'data': account});
    await prefs.clear();
    await Api.cookieJar.delete(Uri.parse(Api.url));
    dio.interceptors.clear();
    dio = initDio1(prefs);
    store.dispatch({'type':StoreActions.selectBottomNav,'data':0});
    store.dispatch({'type':StoreActions.init});
  }

  void test(){
    Api.cookieJar.loadForRequest(Uri.parse(Api.url)).then((cookies) {
      print('loginAfter');
      print(cookies);
    });
  }
}

class UserAccount {
  String username = 'ikism';
  String password = 'qpwoeiruty-1234';
  String token = '';
  @override
  String toString() {
    return 'UserAccount{userName: $username, password: $password, token: $token}';
  }

}

enum SearchType{
  topList,
  hot,
  random,
  latest
}


Future<void> getImage(Store<MainState> store) async {
  if (store.state.loading) return;
  //https://wallhaven.cc/search?categories=010&purity=110&topRange=1M&sorting=toplist&order=desc
  //https://wallhaven.cc/search?categories=010&purity=001&sorting=hot&order=desc
  var params = store.state.search.params;
  params['pageNum'] = store.state.pageNum.toString();
  store.state.loading = true;
  store.state.pageNum++;
  if(!store.state.dioReady){
    dio = await initDio();
    store.state.dioReady = true;
  }
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
