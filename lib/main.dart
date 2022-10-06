import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhevan/pages/favorites.dart';
import 'package:wallhevan/pages/picture_list.dart';
import 'package:wallhevan/pages/search.dart';
// import 'package:wallhevan/pages/taberPage.dart';
import 'package:wallhevan/picture_views.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/testTab.dart';
import 'component/picture.dart';
import 'Account/account.dart';
import 'Account/login.dart';
import 'generated/l10n.dart';

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
  runApp(WallHaven(
    store: store,
  ));
}

class WallHaven extends StatelessWidget {
  const WallHaven({super.key, required this.store});

  final Store<MainState> store;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return StoreProvider<MainState>(
        store: store,
        child: MaterialApp(
            title: 'Flutter Demo',
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: const Locale('en'),
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
              // '/search': (context) => const TabarDemo(),
            },
            home: StoreBuilder<MainState>(
              // onInit: (store) {
              //   print(S.current.general);
              // },
              builder: (BuildContext context, Store<MainState> store) =>
                  MyHomePage(store: store),
            )));
  }

  // @override
  // bool get wantKeepAlive => true;
}

class MyHomePage extends StatefulWidget {
  final Store<MainState> store;

  const MyHomePage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  PageController _controller = PageController();

  @override
  void initState() {
    _controller = PageController(initialPage: currentIndex, keepPage: true);
    super.initState();
  }

  void _onItemTapped(int index, Function callback) async {
    if (index == 2 || index == 3) {
      final prefs = await SharedPreferences.getInstance();
      String? rememberCookie = prefs.getString('remember_web');
      callback(rememberCookie == null);
      return;
    }
    callback(false);
    // store.dispatch({'type': StoreActions.selectBottomNav, 'data': index});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
          // appBar: AppBar(
          //   title: const Text('AppBar Demo'),
          //   actions: <Widget>[
          //     IconButton(
          //       icon: const Icon(Icons.add_alert),
          //       tooltip: 'Show Snackbar',
          //       onPressed: () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //             const SnackBar(content: Text('This is a snackbar')));
          //       },
          //     ),
          //     IconButton(
          //       icon: const Icon(Icons.navigate_next),
          //       tooltip: 'Go to the next page',
          //       onPressed: () {
          //         Navigator.push(context, MaterialPageRoute<void>(
          //           builder: (BuildContext context) {
          //             return Scaffold(
          //               appBar: AppBar(
          //                 title: const Text('Next page'),
          //               ),
          //               body: const Center(
          //                 child: Text(
          //                   'This is the next page',
          //                   style: TextStyle(fontSize: 24),
          //                 ),
          //               ),
          //             );
          //           },
          //         ));
          //       },
          //     ),
          //   ],
          // ),
          bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: S.current.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  label: S.current.search,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.star),
                  label: S.current.favoritesTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle),
                  label: S.current.my,
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              selectedItemColor: Colors.pinkAccent[100],
              onTap: (index) => _onItemTapped(
                  index,
                  (flag) => flag
                      ? Navigator.pushNamed(context, '/login')
                      : _controller.jumpToPage(index))),
          body: StoreConnector<MainState, HandleActions>(
              // onWillChange: _onReduxChange,
              // onInitialBuild: _afterBuild,
              distinct: true,
              converter: (store) => HandleActions(store),
              onInit: (store) => store.dispatch({'type': StoreActions.init}),
              builder: (context, hAction) {
                // MainState mainState = hAction.getMainState();
                return PageView(
                  // physics: const NeverScrollableScrollPhysics(),
                  controller: _controller,
                  onPageChanged: (index) => _onItemTapped(index, (flag) {
                    if (flag) {
                      Navigator.pushNamed(context, '/login');
                      Timer(const Duration(milliseconds: 500), () {
                        _controller.jumpToPage(currentIndex);
                      });
                    } else {
                      setState(() {
                        currentIndex = index;
                      });
                    }
                  }),
                  children: const [
                    PictureList(),
                    // SliverAppBarExample(),
                    SearchPage(),
                    FavoritesPage(),
                    Account()
                  ],
                );
                // return [
                //   const PictureList(),
                //   const SliverAppBarExample(),
                //   const FavoritesPage(),
                //   const Account()
                // ][mainState.bottomNavIndex];
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
  double width = 0;
  double height = 0;
  WallImage(this.src);
  String href = '';
  @override
  String toString() {
    return "src:$src pSrc:$pSrc width:$width height:$height href:$href";
  }
}
