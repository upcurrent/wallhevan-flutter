
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhevan/api/api.dart';
import 'package:wallhevan/store/collections/collections.dart';
import 'package:wallhevan/store/searchResult/search_result.dart';
import '../main.dart' show WallImage;
import 'searchResult/picture_info.dart';

enum StoreActions {
  addAllPictureInfo,
  addAllWidget,
  addPictureInfo,
  addFavPictureList,
  addCookie,
  changeIndex,
  loading,
  init,
  loadMore,
  preview,
  selectBottomNav,
  accountChange,
  searchChange,
  initFav,
  favLoadMore,
}

MainState counterReducer(MainState state, dynamic action) {
  switch (action['type']) {
    case StoreActions.addAllPictureInfo:
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
    case StoreActions.addPictureInfo:
      state.imageDataList.add(action['data']);
      break;
    case StoreActions.addFavPictureList:
      state.favPictureList.addAll(action['data']);
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
      // getPictureList(action['context'], state);
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
    case StoreActions.initFav:
      break;
  }
  return state;
}

void fetchContactorMiddleware(
    Store<MainState> store, action, NextDispatcher next) {
  if (action['type'] == StoreActions.init) {
    store.state.pageNum = 1;
    getPictureList(store);
  }
  if (action['type'] == StoreActions.loadMore) {
    getPictureList(store);
  }
  if (action['type'] == StoreActions.initFav) {
    getFavorites(store);
  }
  next(action);
}

class MainState {
  final List<Widget> imageList;
  final List<PictureInfo> imageDataList;
  final List<PictureInfo> favPictureList;
  bool preview;
  bool loading;
  bool favLoading = false;
  int pageNum;
  int favPageNum = 1;
  int currentIndex;
  int bottomNavIndex = 2;
  UserAccount account = UserAccount();
  SearchParams search = SearchParams();
  String cookie = '';
  bool dioReady = false;
  final List list = [
    "Flutter",
    "React",
    "Ionic",
    "Xamarin",
  ];
  MainState(this.imageList, this.imageDataList, this.preview, this.loading,
      this.pageNum, this.currentIndex, this.bottomNavIndex, this.favPictureList);

  factory MainState.initState() => MainState([], [], false, false, 1, 0, 1,[]);

  void addPictureInfo(PictureInfo img) {
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
  String keyword = "";
  final  Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': '1',
    'apikey':'MJq2IZyeA8QI43iccfNDJSpWQ8qKw8w5',
  };
  final Map<String,String> categoriesMap = {
    'general':'1',
    'anime':'0',
    'people':'0',
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

}


class HandleActions {
  Store<MainState> store;

  HandleActions(this.store);

  bool loading = false;

  MainState getMainState(){
    return store.state;
  }

  SearchParams getSearch(){
    return store.state.search;
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
    getSearch().params[key] = value;
    store.dispatch({'type': StoreActions.searchChange});
  }

  void setCategories(String key){
    SearchParams search = getSearch();
    search.categoriesMap[key] = search.categoriesMap[key] == '0' ? '1' : '0';
    List<String> cateStrs = [];
    cateStrs.addAll(search.categoriesMap.values);
    setParams('categories',cateStrs.join(''));
  }

  void setPurity(String key){
    SearchParams search = getSearch();
    search.purityMap[key] = search.purityMap[key] == '0' ? '1' : '0';
    List<String> purityStrs = [];
    purityStrs.addAll(search.purityMap.values);
    setParams('purity',purityStrs.join(''));
  }

  void loadMore() {
    store.dispatch({'type':StoreActions.loadMore});
  }

  void initFav(){
    getFavorites(store);
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

  void login(Function callback) {
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
      if(response.statusCode == 200){
        callback();
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
//https://wallhaven.cc/favorites
Future<void> getFavorites(Store<MainState> store) async{
  if (store.state.favLoading) return;
  var params = {
    'page':store.state.favPageNum.toString(),
    'apikey':'MJq2IZyeA8QI43iccfNDJSpWQ8qKw8w5'
  };
  store.state.favLoading = true;
  store.state.favPageNum++;
  if(!store.state.dioReady){
    dio = await initDio();
    store.state.dioReady = true;
  }
  dio
      .get('/api/v1/collections/ikism/749153',
      queryParameters: params,)
      .then((response) {
    store.state.favLoading = false;
    Collections collections = Collections.fromJson(response.data);
    print(collections.data);
    store.dispatch({'type': StoreActions.addFavPictureList, 'data': collections.data});
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

Future<void> getPictureList(Store<MainState> store) async {
  if (store.state.loading) return;
  //https://wallhaven.cc/search?categories=010&purity=110&topRange=1M&sorting=toplist&order=desc
  //https://wallhaven.cc/search?categories=010&purity=001&sorting=hot&order=desc
  var params = store.state.search.params;
  params['page'] = store.state.pageNum.toString();
  store.state.loading = true;
  store.state.pageNum++;
  if(!store.state.dioReady){
    dio = await initDio();
    store.state.dioReady = true;
  }
  //https://wallhaven.cc/api/v1/search
  dio
      .get('/api/v1/search',
          queryParameters: params,
          // options: Options(headers: {'x-requested-with': 'XMLHttpRequest'})
  )
      .then((response) {
    store.state.loading = false;


    SearchResult collections = SearchResult.fromJson(response.data);
    store.dispatch({'type': StoreActions.addAllPictureInfo, 'data': collections.data});
  // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

List<WallImage> handleHtml(String responseBody){
  List<WallImage> dataList = [];
  var document = parse(responseBody.replaceAll("/small/", "/orig/"));
  var figureList = document.getElementsByTagName("figure");
  for (var element in figureList) {
    var img = element.querySelector('img');
    var href = element.querySelector('.preview');
    var size = element.querySelector('.wall-res');
    var png = element.querySelector('.png');
    // var obj = WallImage('');
    // img?.attributes.forEach((key, value) {
    //   if (key == "data-src") {
    //     obj.pSrc = value;
    //   }
    // });
    // href?.attributes.forEach((key, value) {
    //   if (key == "href") {
    //     obj.href = value;
    //   }
    // });
    // String nSize = (size?.innerHtml).toString();
    // List sizes = nSize.split(' x ');
    //
    // if (sizes.isNotEmpty) {
    //   double rWidth = double.parse(sizes[0]);
    //   double rHeight = double.parse(sizes[1]);
    //   obj.width = rWidth;
    //   obj.height = rHeight;
    //   List<String> fullSrc = obj.pSrc
    //       .replaceAll('/th.wallhaven.cc/orig/', '/w.wallhaven.cc/full/')
    //       .split('/');
    //   fullSrc[fullSrc.length - 1] =
    //   "wallhaven-${fullSrc[fullSrc.length - 1]}";
    //   if (png != null) {
    //     fullSrc[fullSrc.length - 1] =
    //         fullSrc[fullSrc.length - 1].replaceAll('.jpg', '.png');
    //   }
    //   obj.src = fullSrc.join('/');
    // }
    // // print(obj);
    // dataList.add(obj);
  }
  return dataList;
}

