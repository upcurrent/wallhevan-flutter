import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:redux/redux.dart';
import 'package:wallhevan/pictureViews.dart';
import 'package:wallhevan/store/index.dart';
import './picture.dart';
import 'Account/account.dart';
import 'Account/login.dart';
import 'api.dart';


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
            initialRoute: '/login',
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
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/login');
        break;
      case 2:
        Navigator.pushNamed(context, '/account');
        break;
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
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            currentIndex: store.state.bottomNavIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (index) => _onItemTapped(context, index),
          ),
          body: StoreConnector<MainState, MainState>(
              // onWillChange: _onReduxChange,
              // onInitialBuild: _afterBuild,
              distinct: true,
              converter: (store) => store.state,
              onInit: (store) => store
                  .dispatch({'type': StoreActions.init, 'context': context}),
              builder: (context, mainState) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 400) {
                      store.dispatch(
                          {'type': StoreActions.init, 'context': context});
                      return true;
                    }
                    return false;
                  },
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    itemCount: mainState.imageList.length,
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
                          child: mainState.imageList[index]);
                    },
                  ),
                );
              })),
    );
    // });
  }
}

class WallImage {
  static const int previewPicture = 1;
  static const int fullSizePicture = 2;
  String src = '';
  String pSrc = '';
  Map size = {
    'width': 0,
    'height': 0,
    'pWidth': 0,
    'pHeight': 0,
  };
  WallImage(this.src);
  String href = '';
  @override
  String toString() {
    return "src:$src pSrc:$pSrc size:$size href:$href";
  }
}
