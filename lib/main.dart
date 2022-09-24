import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:redux/redux.dart';
import 'package:wallhevan/pictureComp.dart';
import 'package:wallhevan/pictureViews.dart';
import 'package:wallhevan/store/index.dart';
import './picture.dart';

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

enum Actions {
  addAllWallImage,
  addAllWidget,
  addWallImage,
  addWidget,
  changeIndex,
  loading,
  init,
  preview,
  selectBottomNav
}

MainState counterReducer(MainState state, dynamic action) {
  switch (action['type']) {
    case Actions.addAllWallImage:
      state.imageDataList.addAll(action['data']);
      break;
    case Actions.addAllWidget:
      state.imageList.addAll(action['data']);
      break;
    case Actions.addWallImage:
      state.imageDataList.add(action['data']);
      break;
    case Actions.addWidget:
      state.imageList.add(action['data']);
      break;
    case Actions.changeIndex:
      state.currentIndex = action['data'];
      break;
    case Actions.loading:
      state.loading = !state.loading;
      break;
    case Actions.init:
      // getImage(action['context'], state);
      break;
    case Actions.selectBottomNav:
      state.bottomNavIndex = action['data'];
      break;
    case Actions.preview:
      state.currentIndex = action['currentIndex'];
      state.preview = !state.preview;
      break;
  }
  return state;
}

void fetchContactorMiddleware(
    Store<MainState> store, action, NextDispatcher next) {
  if (action['type'] == Actions.init) {
    getImage(store, action['context']);
  }
  next(action);
}

void getImage(Store<MainState> store, BuildContext context) {
  if (store.state.loading) return;
  //https://wallhaven.cc/search?categories=010&purity=110&topRange=1M&sorting=toplist&order=desc
  var params = {
    'categories': '010',
    'purity': '110',
    'topRange': '1M',
    'sorting': 'toplist',
    'order': 'desc',
    'page': store.state.pageNum.toString(),
  };
  var url = Uri.https('wallhaven.cc', 'search', params);
  store.state.pageNum++;
  store.state.loading = true;
  http.get(url, headers: {'x-requested-with': 'XMLHttpRequest'}).then(
      (response) {
    store.state.loading = false;
    var document = parse(response.body.replaceAll("/small/", "/orig/"));
    var figureList = document.getElementsByTagName("figure");
    List<Widget> list = [];
    List<WallImage> dataList = [];
    double halfWidth = MediaQuery.of(context).size.width / 2;
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
        double pHeight = rHeight / (rWidth / halfWidth);
        obj.size = {
          'pWidth': halfWidth,
          'pHeight': pHeight,
          'width': rWidth,
          'height': rHeight
        };
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
        debugPrint(obj.toString());
        list.add(PictureComp(
            pHeight: pHeight,
            halfWidth: halfWidth,
            image: obj,
            type: WallImage.previewPicture));
      } else {
        list.add(Image.network(obj.pSrc, fit: BoxFit.scaleDown));
      }
      // print(obj);
      dataList.add(obj);
    }
    // print(state.im)
    store.dispatch({'type': Actions.addAllWidget, 'data': list});
    store.dispatch({'type': Actions.addAllWallImage, 'data': dataList});
  }).catchError((error) => {print(error.toString())});
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
            },
            home: StoreBuilder<MainState>(
              builder: (BuildContext context, Store<MainState> store) =>
                  MyHomePage(store: store),
            )));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.store});

  final Store<MainState> store;
  void _onItemTapped(int index){
    store.dispatch({'type':Actions.selectBottomNav,'data':index});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onTap: _onItemTapped,
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: StoreConnector<MainState, MainState>(
              // onWillChange: _onReduxChange,
              // onInitialBuild: _afterBuild,
              distinct: true,
              converter: (store) => store.state,
              onInit: (store) =>
                  store.dispatch({'type': Actions.init, 'context': context}),
              builder: (context, mainState) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 400) {
                      store
                          .dispatch({'type': Actions.init, 'context': context});
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
                                  'type': Actions.preview,
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
