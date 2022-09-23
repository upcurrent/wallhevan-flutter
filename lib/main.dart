import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wallhevan/pictureComp.dart';
import './picture.dart';

void main() {
  runApp(const MyApp());
}

class Photo {
  String src;

  Photo({required this.src});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// class ImageList <List> {
//
// }
class WallImage {
  String src = '';
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
    // TODO: implement toString
    return "src:$src size:$size href:$href";
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> _imageList = [];
  List<WallImage> _imageDataList = [];
  int _pageNum = 1;
  bool _loading = false;
  void _incrementCounter() {
    getImage();
  }

  void getImage() {
    print(_imageList.length);
    if (_loading) return;
    //https://wallhaven.cc/search?categories=010&purity=110&topRange=1M&sorting=toplist&order=desc
    var params = {
      'categories': '010',
      'purity': '110',
      'topRange': '1M',
      'sorting': 'toplist',
      'order': 'desc',
      'page': _pageNum.toString(),
    };
    var url = Uri.https('wallhaven.cc', 'search', params);
    setState(() {
      _pageNum++;
      _loading = true;
    });
    http
        .get(url, headers: {'x-requested-with': 'XMLHttpRequest'})
        .then((response) => {
              // print(response.body),
              setState(() {
                _loading = false;
                var document =
                    parse(response.body.replaceAll("/small/", "/orig/"));
                var figureList = document.getElementsByTagName("figure");
                var list = _imageList;
                var dataList = _imageDataList;
                for (var element in figureList) {
                  var img = element.querySelector('img');
                  var href = element.querySelector('.preview');
                  var size = element.querySelector('.wall-res');
                  var png = element.querySelector('.png');
                  var obj = WallImage('');
                  img?.attributes.forEach((key, value) {
                    if (key == "data-src") {
                      obj.src = value;
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
                    double maxWidth = MediaQuery.of(context).size.width * 0.48;
                    double halfWidth = MediaQuery.of(context).size.width / 2;
                    double rWidth = double.parse(sizes[0]);
                    double rHeight = double.parse(sizes[1]);
                    double pHeight = rHeight / (rWidth / (halfWidth - 4));
                    obj.size = {
                      'pWidth': halfWidth,
                      'pHeight': pHeight,
                      'width': rWidth,
                      'height': rHeight
                    };
                    //   w1   h1
                    //   45   45 / pr
                    // height = height * pr;
                    //https://th.wallhaven.cc/orig/x8/x8x7dz.jpg
                    //https://w.wallhaven.cc/full/x8/wallhaven-x8x7dz.jpg
                    List<String> fullSrc = obj.src
                        .replaceAll(
                            '/th.wallhaven.cc/orig/', '/w.wallhaven.cc/full/')
                        .split('/');
                    fullSrc[fullSrc.length - 1] =
                        "wallhaven-${fullSrc[fullSrc.length - 1]}";
                    if (png != null) {
                      fullSrc[fullSrc.length - 1] = fullSrc[fullSrc.length - 1]
                          .replaceAll('.jpg', '.png');
                    }
                    Map<String, dynamic> args = {'src': fullSrc.join('/')};
                    list.add(GestureDetector(
                        onTap: () => {
                              Navigator.pushNamed(context, '/picture',
                                  arguments: args),
                              obj.src = fullSrc.join('/'),
                            },
                        child: PictureComp(pHeight: pHeight, halfWidth: halfWidth, image: obj,type:1)
                    ));
                  } else {
                    list.add(Image.network(obj.src, fit: BoxFit.scaleDown));
                  }
                  print(obj);
                  dataList.add(obj);
                }
                _imageList = list;
                _imageDataList = dataList;
              })
            })
        .catchError((error) => {debugPrint(error.toString())});
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // getImage();
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // var cur = scrollInfo.metrics.pixels;
          // var max = scrollInfo.metrics.maxScrollExtent;
          // print("$cur $max");
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 400) {
            getImage();
            // print(scrollInfo.metrics.pixels);
            return true;
          }
          return false;
        },
        child: MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: _imageList.length,
          itemBuilder: (context, index) {
            return _imageList.isNotEmpty ? _imageList[index] : const Text("");
          },
        ),
        // child:Container(
        //   width:194,
        //   height:300,
        //   decoration: BoxDecoration(
        //     border:Border.all(width:1,color:Colors.grey)
        //   ),
        //   child:Image.network("https://th.wallhaven.cc/orig/72/72yvov.jpg",fit:BoxFit.cover),
        //   //2267 x 3507
        // )
      ),
      // body: Center(
      //   // Center is a layout widget. It takes a single child and positions it
      //   // in the middle of the parent.
      //   child: ListView.builder(
      //     itemCount: _imageList.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return _imageList[index];
      //     },
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
