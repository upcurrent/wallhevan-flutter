import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhevan/api/api.dart';
import 'package:wallhevan/store/collections/fav_data.dart';
import 'package:wallhevan/store/collections/collections.dart';
import 'package:wallhevan/store/picture_res/picture_data.dart';
import 'package:wallhevan/store/picture_res/picture_res.dart';
import 'package:wallhevan/store/search_response/search_result.dart';
import 'collections/fav_response.dart';
import 'search_response/picture_info.dart';

enum StoreActions {
  addAllPictureInfo,
  addAllSearchList,
  addAllWidget,
  addPictureInfo,
  addFavPictureList,
  setFavList,
  loading,
  preview,
  changeIndex,
  selectBottomNav,
  accountChange,
  searchChange,
  homeScrollTop,
  init,
  initFav,
  loadMore,
  favLoadMore,
  updatePic,
}

enum ListType {
  viewFav,
  viewList,
  viewSearch,
}

MainState counterReducer(MainState state, dynamic action) {
  print(action['type']);
  switch (action['type']) {
    case StoreActions.addFavPictureList:
      if (state.favQuery.pageNum == 2) {
        state.favQuery.list.clear();
      }
      state.favQuery.list.addAll(action['data']);
      break;
    case StoreActions.changeIndex:
      state.currentIndex = action['data'];
      break;
    case StoreActions.loadMore:
    case StoreActions.init:
      // getPictureList(action['context'], state);
      break;
    case StoreActions.preview:
      state.cachePic.add(action['url']);
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
    case StoreActions.homeScrollTop:
      state.homeScrollTop();
  }
  return state;
}

void fetchContactorMiddleware(
    Store<MainState> store, action, NextDispatcher next) {
  MainState state = store.state;
  PictureQuery query;
  switch (action['viewType']) {
    case ListType.viewFav:
      query = state.favQuery;
      break;
    default:
      query = state.favQuery;
  }
  if (action['type'] == StoreActions.init) {
    query.pageNum = 1;
    if (action['id'] != null) {
      state.favId = action['id'];
      query.list.clear();
      query.total = 0;
      getFavorites(store);
    }
  }
  if (action['type'] == StoreActions.loadMore) {
    getFavorites(store);
  }
  if (action['type'] == StoreActions.initFav) {
    getFavList(store);
  }
  if (action['type'] == StoreActions.setFavList) {
    state.favList.clear();
    state.favList.addAll(action['data']);
    if (state.favList.isNotEmpty) {
      if (state.favId == 0) {
        state.favId = state.favList[0].id;
      }
      query.pageNum = 1;
      query.total = 0;
      query.loading = false;
      getFavorites(store);
    }
  }
  next(action);
}

class MainState {
  final List<FavData> favList = [];
  final Set<String> cachePic = {};
  final ScrollController homeScrollCtrl =
      ScrollController(keepScrollOffset: false);
  bool loading = false;
  int favId = 0;
  int currentIndex = 0;
  final PictureQuery favQuery = PictureQuery();
  UserAccount account = UserAccount();
  SearchParams search = SearchParams();
  bool dioReady = false;
  ListType viewType = ListType.viewList;
  int total = 0;
  int listTotal = 0;
  int searchTotal = 0;
  void homeScrollTop() {
    homeScrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }
}

class PictureQuery {
  bool loading = false;
  int pageNum = 1;
  int total = 0;
  String q = '';
  final List<PictureInfo> list = [];
  static PictureQuery getQuery(MainState state) {
    return state.favQuery;
  }
}

class SearchParams {
  final Map<String, String> params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': '1',
    'q': '',
    'seed': '',
  };
  final Map<String, String> categoriesMap = {
    'general': '1',
    'anime': '0',
    'people': '0',
  };

  final Map<String, String> purityMap = {
    'SFW': '1',
    'Sketchy': '0',
    'NSFW': '0',
  };
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

  void setParams(Map<String, String> args, {bool search = false}) {
    getSearch().params.addAll(args);
    store.dispatch({'type': StoreActions.searchChange});
    if (search) {
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
  String username = '';
  String password = '';
  String token = '';
  @override
  String toString() {
    return 'UserAccount{userName: $username, password: $password, token: $token}';
  }
}

enum SearchType { topList, hot, random, latest }

Future<void> getFavorites(Store<MainState> store) async {
  MainState state = store.state;
  PictureQuery query = state.favQuery;
  if (query.loading) return;
  if (query.pageNum != 1 && query.list.length >= query.total) {
    return;
  }
  int id = store.state.favId;
  if (id == 0) return;
  var params = {
    'page': query.pageNum.toString(),
    'purity': '111',
    'apikey': await StorageManger.getApiKey(),
  };
  query.loading = true;
  query.pageNum++;
  if (!state.dioReady) {
    dio = await initDio();
    state.dioReady = true;
  }
  dio
      .get(
    '/api/v1/collections/ikism/$id',
    queryParameters: params,
  )
      .then((response) {
    query.loading = false;
    Collections collections = Collections.fromJson(response.data);
    final meta = collections.meta;
    if (meta != null) {
      query.total = meta.total;
    }
    store.dispatch(
        {'type': StoreActions.addFavPictureList, 'data': collections.data});
    // ignore: invalid_return_type_for_catch_error, avoid_print
  }).catchError((error) => {print(error.toString())});
}

Future<PictureData> getPictureInfo(String id) async {
  String apiKey = await StorageManger.getApiKey();
  Response res =
      await dio.get('/api/v1/w/$id', queryParameters: {'apikey': apiKey});
  return PictureRes.fromJson(res.data).data!;
}

Future<void> getFavList(Store<MainState> store) async {
  MainState state = store.state;
  if (state.loading) return;
  Map<String, dynamic> params = {
    'apikey': await StorageManger.getApiKey(),
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
    state.favQuery.loading = false;
    FavoritesRes favList = FavoritesRes.fromJson(response.data);
    store.dispatch({'type': StoreActions.setFavList, 'data': favList.favData});
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
