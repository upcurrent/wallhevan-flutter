import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhevan/api/api.dart';
import 'package:wallhevan/store/collections/collection_list_data.dart';
import 'package:wallhevan/store/collections/collections.dart';
import 'package:wallhevan/store/search_result/search_result.dart';
import 'collections/collection_list.dart';
import 'search_result/picture_info.dart';

enum StoreActions {
  addAllPictureInfo,
  addAllWidget,
  addPictureInfo,
  addFavPictureList,
  setFavList,
  viewFav,
  viewList,
  loading,
  preview,
  changeIndex,
  selectBottomNav,
  accountChange,
  searchChange,
  init,
  initFav,
  loadMore,
  favLoadMore,
  updatePic,
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
      if (state.favPageNum == 2) {
        state.favPictureList.clear();
      }
      state.favPictureList.addAll(action['data']);
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
    case StoreActions.preview:
      state.currentIndex = action['currentIndex'];
      state.viewType = action['viewType'];
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
    case StoreActions.setFavList:
      break;
    case StoreActions.updatePic:
      state.cachePic.add(action['url']);
      break;
  }
  return state;
}

void fetchContactorMiddleware(
    Store<MainState> store, action, NextDispatcher next) {
  print(action['type']);
  MainState state = store.state;
  if (action['type'] == StoreActions.init) {
    if (action['viewType'] == StoreActions.viewFav) {
      state.favPageNum = 1;
      if (action['id'] != null) {
        state.favId = action['id'];
        state.favPictureList.clear();
        state.favTotal = 0;
        getFavorites(store);
      }
    } else {
      state.pageNum = 1;
      state.listTotal = 0;
      getPictureList(store);
    }
  }
  if (action['type'] == StoreActions.loadMore) {
    if (action['viewType'] == StoreActions.viewFav) {
      getFavorites(store);
    } else {
      getPictureList(store);
    }
  }
  if (action['type'] == StoreActions.initFav) {
    getFavList(store);
  }
  if (action['type'] == StoreActions.setFavList) {
    state.favList.clear();
    state.favList.addAll(action['data']);
    if (state.favList.isNotEmpty) {
      state.favId = state.favList[0].id;
      state.favPageNum = 1;
      state.favTotal = 0;
      getFavorites(store);
    }
  }
  next(action);
}

class MainState {
  final List<Widget> imageList;
  final List<PictureInfo> imageDataList;
  final List<PictureInfo> favPictureList;
  final List<CollectionListData> favList;
  final Set<String> cachePic = {};
  int favId = 0;
  bool preview;
  bool loading;
  bool favLoading = false;
  int pageNum;
  int favPageNum = 1;
  int currentIndex;
  UserAccount account = UserAccount();
  SearchParams search = SearchParams();
  bool dioReady = false;
  StoreActions viewType = StoreActions.viewList;
  int favTotal = 0;
  int listTotal = 0;
  MainState(
      this.imageList,
      this.imageDataList,
      this.preview,
      this.loading,
      this.pageNum,
      this.currentIndex,
      this.favPictureList,
      this.favList);

  factory MainState.initState() =>
      MainState([], [], false, false, 1, 0, [], []);

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
  final Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': '1',
    'q':'',
    'seed':'',
  };
  final Map<String, String> categoriesMap = {
    'general': '1',
    'anime': '0',
    'people': '0',
  };
  final Map<String, String> sortingMap = {
    'TopList': 'toplist',
    'Hot': 'hot',
    'Random': 'random',
    'Latest': 'date_added',
    'Views': 'views',
    'Favorites': 'favorites',
    'Relevance': 'relevance',
  };
  final Map<String, String> purityMap = {
    'SFW': '1',
    'Sketchy': '0',
    'NSFW': '0',
  };
  final List<String> topRangeMap = ['1d', '3d', ' 1w', '1M', '3M', '6M', '1y'];
}

class HandleActions {
  Store<MainState> store;

  HandleActions(this.store);

  bool loading = false;

  MainState getMainState() {
    return store.state;
  }

  SearchParams getSearch() {
    return store.state.search;
  }

  bool hasCache(String url) {
    return store.state.cachePic.contains(url);
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

  void setParams(Map<String,String> args,{bool search = false}) {
    getSearch().params.addAll(args);
    store.dispatch({'type': StoreActions.searchChange});
    if(search){
      store.dispatch({'type': StoreActions.init});
    }
  }

  void setCategories(String key) {
    SearchParams search = getSearch();
    search.categoriesMap[key] = search.categoriesMap[key] == '0' ? '1' : '0';
    List<String> cateStrs = [];
    cateStrs.addAll(search.categoriesMap.values);
    setParams({'categories': cateStrs.join('')});
  }

  void setPurity(String key) {
    SearchParams search = getSearch();
    search.purityMap[key] = search.purityMap[key] == '0' ? '1' : '0';
    List<String> purityStrs = [];
    purityStrs.addAll(search.purityMap.values);
    setParams({'purity': purityStrs.join('')});
  }

  void loadMore(StoreActions viewType) {
    store.dispatch({'type': StoreActions.loadMore, 'viewType': viewType});
  }

  void initFav() {
    getFavList(store);
  }

  Future<String> getToken(String url) async {
    loading = true;
    Map<String, String> header = {};
    Response response = await dio.get(url, options: Options(headers: header));
    loading = false;
    var body = parse(response.data);
    var input = body.querySelector('[name="_token"]');
    var token = input?.attributes['value'];
    if (token != null) {
      tokenChanged(token);
      return token;
    }
    return '';
  }

  void initAccount() async {
    final prefs = await SharedPreferences.getInstance();
    String? diskUserName = prefs.getString('username');
    if (diskUserName != null) {
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
      if (response.statusCode == 200) {
        callback();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', account.username);
        prefs.setString('password', account.password);
      }
    });
  }

  void logOut() async {
    if (loading) return;
    loading = true;
    UserAccount account = store.state.account;
    getToken('/user/${account.username}').then((token) async {
      if (token.isNotEmpty) {
        await dio.post('/auth/logout',
            data: {'_token': account.token},
            options: Options(
                followRedirects: false,
                validateStatus: (status) {
                  return status! < 500;
                }));
        loading = false;
      } else {
        loading = false;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    account.password = '';
    account.token = '';
    account.username = '';
    store.dispatch({'type': StoreActions.accountChange, 'data': account});
    await prefs.clear();
    await Api.cookieJar.delete(Uri.parse(Api.url));
    dio.interceptors.clear();
    dio = initDio1(prefs);
    store.dispatch({'type': StoreActions.selectBottomNav, 'data': 0});
    store.dispatch({'type': StoreActions.init});
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

enum SearchType { topList, hot, random, latest }

//https://wallhaven.cc/favorites
Future<void> getFavorites(Store<MainState> store) async {
  MainState state = store.state;
  if (state.favLoading) return;
  if (state.favPageNum != 1 && state.favPictureList.length >= state.favTotal) {
    return;
  }
  int id = store.state.favId;
  if (id == 0) return;
  final prefs = await StorageManger.prefs;
  var params = {
    'page': store.state.favPageNum.toString(),
    'purity': '111',
    'apikey': prefs.getString('apiKey') ?? ''
  };
  store.state.favLoading = true;
  store.state.favPageNum++;
  if (!store.state.dioReady) {
    dio = await initDio();
    store.state.dioReady = true;
  }
  dio
      .get(
    '/api/v1/collections/ikism/$id',
    queryParameters: params,
  )
      .then((response) {
    store.state.favLoading = false;
    Collections collections = Collections.fromJson(response.data);
    final meta = collections.meta;
    if (meta != null) {
      store.state.favTotal = meta.total;
    }
    store.dispatch(
        {'type': StoreActions.addFavPictureList, 'data': collections.data});
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

String getRandomSeed(){
  List<String> base = 'qwertyuiopasdfghjklzxcvbnm1234567890'.split('');
  var rng =  Random();
  return List.generate(6, (_) => base[rng.nextInt(base.length)]).join('');
}

Future<void> getPictureList(Store<MainState> store) async {
  MainState state = store.state;
  if (state.loading) return;
  if (state.pageNum != 1 && state.favPictureList.length >= state.listTotal) {
    return;
  }
  var params = state.search.params;
  final prefs = await StorageManger.prefs;
  params['page'] = store.state.pageNum.toString();
  params['apikey'] = prefs.getString('apiKey') ?? "MJq2IZyeA8QI43iccfNDJSpWQ8qKw8w5";
  if(params['sorting'] == 'random'){
    if(params['seed'] == ''){
      params['seed'] = getRandomSeed();
    }
  }else{
    params['seed'] = '';
  }
  state.loading = true;
  state.pageNum++;
  if (!state.dioReady) {
    dio = await initDio();
    state.dioReady = true;
  }
  //https://wallhaven.cc/api/v1/search
  dio
      .get(
    '/api/v1/search',
    queryParameters: params,
    // options: Options(headers: {'x-requested-with': 'XMLHttpRequest'})
  )
      .then((response) {
    state.loading = false;
    SearchResult searchResult = SearchResult.fromJson(response.data);
    final meta = searchResult.meta;
    if (meta != null) {
      store.state.listTotal = meta.total;
    }
    store.dispatch(
        {'type': StoreActions.addAllPictureInfo, 'data': searchResult.data});
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

Future<void> getFavList(Store<MainState> store) async {
  MainState state = store.state;
  if (state.loading) return;
  SharedPreferences prefs = await StorageManger.prefs;
  Map<String, dynamic> params = {
    'apikey': prefs.getString('apiKey') ?? 'MJq2IZyeA8QI43iccfNDJSpWQ8qKw8w5',
  };
  if (!state.dioReady) {
    dio = await initDio();
    state.dioReady = true;
  }
  dio
      .get(
    '/api/v1/collections',
    queryParameters: params,
  )
      .then((response) {
    state.loading = false;
    CollectionList favList = CollectionList.fromJson(response.data);
    store.dispatch(
        {'type': StoreActions.setFavList, 'data': favList.collectionListData});
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

// List<WallImage> handleHtml(String responseBody) {
//   List<WallImage> dataList = [];
//   var document = parse(responseBody.replaceAll("/small/", "/orig/"));
//   var figureList = document.getElementsByTagName("figure");
//   for (var element in figureList) {
//     var img = element.querySelector('img');
//     var href = element.querySelector('.preview');
//     var size = element.querySelector('.wall-res');
//     var png = element.querySelector('.png');
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
//   }
//   return dataList;
// }
