import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';

import 'package:redux/redux.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'pages/favorites.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/picture_views.dart';
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
              '/pictureViews': (context) => const PictureViews(),
              '/account': (context) => const Account(),
              '/login': (context) => const Login(),
              // '/search':(context) => const SearchBarDemo(),
            },
            home: StoreBuilder<MainState>(
              builder: (BuildContext context, Store<MainState> store) =>
                  MyHomePage(store: store),
            )));
  }
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
  int pageIndex = 0;
  PageController _controller = PageController();

  final ScrollController _scrollController = ScrollController(keepScrollOffset: false);

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
    if(pageIndex == index && index == 0){
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve:Curves.ease);
    }
    callback(false);
    // store.dispatch({'type': StoreActions.selectBottomNav, 'data': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: GFDrawer(
          elevation: 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: const <Widget>[
              ListTile(
                title: Text('Item 1'),
                onTap: null,
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: null,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
                    : _controller.jumpToPage(index))),
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
          children:  [
            HomePage(scrollController: _scrollController),
            // SliverAppBarExample(),
            const SearchPage(),
            const FavoritesPage(),
            const Account()
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
