import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';

import 'package:redux/redux.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'package:wallhevan/store/model_view/main_view.dart';
import 'package:wallhevan/store/store.dart';
import 'pages/favorites.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'store/index.dart';
import 'component/picture.dart';
import 'account/account.dart';
import 'account/login.dart';
import 'generated/l10n.dart';

void main() {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
  Store<MainState> store = Store<MainState>(
    counterReducer,
    initialState: MainState(),
    middleware: [
      fetchContactorMiddleware,
    ],
  );
  Get.put(StoreController());
  Get.put(SearchQuery());
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
    return StoreProvider<MainState>(
        store: store,
        child: MaterialApp(
          title: 'wallhaven',
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
            textTheme: const TextTheme(
              headline1: TextStyle(
                  fontSize: 32.0,
                  color: Colors.white),
              headline2: TextStyle(
                  fontSize: 28.0,
                  color: Colors.white),
              headline3: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white),
              headline4: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white),
              headline6: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white),
              bodyText1: TextStyle(
                fontSize: 15.0,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff387799),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: Color(0x801b1b1b),
              filled: true,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white),
            ),
            primaryColor: const Color(0xff387799),
            primarySwatch: Colors.teal,
          ),
          initialRoute: '/',
          routes: {
            '/picture': (context) => const Picture(),
            // '/pictureViews': (context) => PictureViews(load: LoadResult(),curIndex: 0,),
            '/account': (context) => const Account(),
            '/login': (context) => const Login(),
            // '/search':(context) => const SearchBarDemo(),
          },
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 0;
  PageController _controller = PageController();

  final StoreController storeController = Get.find();

  @override
  void initState() {
    _controller = PageController(initialPage: pageIndex, keepPage: true);
    super.initState();
  }

  void _onPageChanged(int index, Function callback) async {
    // if (index == 2 || index == 3) {
    //   final prefs = await SharedPreferences.getInstance();
    //   String? rememberCookie = prefs.getString('remember_web');
    //   callback(rememberCookie == null);
    //   return;
    // }
    if (pageIndex == index && index == 0) {
      storeController.homeScrollTop();
    }
    callback(false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: GFDrawer(
          // elevation: 0,
          child: GlobalTheme.backImg(SearchPage()),
        ),
        bottomNavigationBar:
            StoreConnector<MainState, MainModel>(converter: (store) {
          return MainModel.fromStore(store);
        }, builder: (context, main) {
          return BottomNavigationBar(
              backgroundColor: const Color(0xff387799),
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
                  icon: const Icon(Icons.settings),
                  label: S.current.my,
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: pageIndex,
              unselectedItemColor: const Color(0xff14303a),
              selectedItemColor: const Color(0xffffffff),
              onTap: (index) => _onPageChanged(
                  index,
                  (flag) => flag
                      ? Navigator.pushNamed(context, '/login')
                      : _controller.jumpToPage(index)));
        }),
        body: GlobalTheme.backImg(PageView(
          // physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          onPageChanged: (index) => _onPageChanged(index, (flag) {
            if (flag) {
              Navigator.pushNamed(context, '/login');
              Timer(const Duration(milliseconds: 500), () {
                _controller.jumpToPage(pageIndex);
              });
            } else {
              setState(() {
                pageIndex = index;
              });
            }
          }),
          children:  const [
            HomePage(),
            SearchPage(),
            FavoritesPage(),
            Account()
          ],
        )));
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
