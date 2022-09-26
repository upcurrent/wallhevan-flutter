import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/pages/favorites.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/picture_views.dart';
import 'package:wallhevan/store/index.dart';
import 'component/picture.dart';
import 'Account/account.dart';
import 'Account/login.dart';
import 'api/api.dart';


void main() {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  Store<MainState> store = Store<MainState>(
    counterReducer,
    initialState: MainState.initState(),
    middleware: [
      fetchContactorMiddleware,
    ],
  );
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<MainState> store;

  const MyApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<MainState>(
        store: store,
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            routes: {
              '/picture': (context) => const Picture(),
              '/pictureViews': (context) => const PictureViews(),
              '/account': (context) => const Account(),
              '/login': (context) => const Login(),
            },
            home: StoreBuilder<MainState>(
              onInit: (store) {
                initDio();
              },
              builder: (BuildContext context, Store<MainState> store) =>
                  MyHomePage(store: store),
            )));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.store});

  final Store<MainState> store;
  void _onItemTapped(BuildContext context, int index) async {
    // switch (index) {
    //   case 0:
    //     Navigator.pushNamed(context, '/');
    //     break;
    //   case 1:
    //     Navigator.pushNamed(context, '/login');
    //     break;
    //   case 2:
    //     Navigator.pushNamed(context, '/account');
    //     break;
    // }
    // if(store.state.account.token)
    if(index == 2 || index == 3){
      final prefs = await SharedPreferences.getInstance();
      List<String>? cookieStr = prefs.getStringList('cookie');
      if(cookieStr == null || cookieStr.every((str) => !str.contains('remember_web'))){
        Navigator.pushNamed(context, '/login');
        return;
      }
    }
    store.dispatch({'type': StoreActions.selectBottomNav, 'data': index});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '首页',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '搜索',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: '收藏',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: '我的',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: store.state.bottomNavIndex,
            selectedItemColor: Colors.pinkAccent[100],
            onTap: (index) => _onItemTapped(context, index),
          ),
          body: [StoreConnector<MainState, MainState>(
              // onWillChange: _onReduxChange,
              // onInitialBuild: _afterBuild,
              distinct: true,
              converter: (store) => store.state,
              onInit: (store) => store
                  .dispatch({'type': StoreActions.init}),
              builder: (context, mainState) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 400) {
                      store.dispatch(
                          {'type': StoreActions.loadMore});
                      return true;
                    }
                    return false;
                  },
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    itemCount: mainState.imageDataList.length,
                    itemBuilder: (context, index) {
                      // return mainState.imageList[index];
                      return GestureDetector(
                          onTap: () => {
                                store.dispatch({
                                  'type': StoreActions.preview,
                                  'currentIndex': index
                                }),
                                Navigator.pushNamed(context, '/pictureViews'),
                              },
                          child:PictureComp.create(context, mainState.imageDataList[index]));
                    },
                  ),
                );
              }),const SearchPage(),const FavoritesPage(),const Account()][store.state.bottomNavIndex]),
    );
    // });
  }
}



class WallImage {
  static const int previewPicture = 1;
  static const int fullSizePicture = 2;
  String src = '';
  String pSrc = '';
  double width = 0;
  double height = 0;
  WallImage(this.src);
  String href = '';
  @override
  String toString() {
    return "src:$src pSrc:$pSrc width:$width height:$height href:$href";
  }
}
