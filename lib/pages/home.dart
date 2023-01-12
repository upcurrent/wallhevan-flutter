import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallhevan/pages/picture_list.dart';

import '../component/search_page.dart';
import '../store/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String tag = getTag();
  String sorting = 'toplist';
  late LoadResult load;

  final StoreController storeController = Get.find();

  List<Widget> cartList() {
    // load.init();
    const BoxDecoration decoration = BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x1a000000),
        Color(0x80000000),
      ],
    ));
    BoxDecoration selDecoration = BoxDecoration(
      border: Border.all(color: const Color(0x50000000), width: 1),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x5a000000),
          offset: Offset.zero,
          spreadRadius: 1,
          blurRadius: 1,
        ),
      ],
    );

    Padding card(Text text, Image image, String value) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: GetBuilder<LoadResult>(
              init: load,
              builder: (load) {
                return GestureDetector(
                    onTap: () {
                      load.sort = value;
                      load.init(renderer: true);
                      getPictureList(load);
                    },
                    child: Container(
                      decoration:
                          load.sort == value ? selDecoration : decoration,
                      height: 120,
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: image,
                          ),
                          text,
                        ],
                      ),
                    ));
              }));
    }

    return [
      card(const Text('Latest', style: TextStyle(color: Color(0xffaadd33))),
          Image.asset('images/clock.png'), 'date_added'),
      card(const Text('TopList', style: TextStyle(color: Color(0xffb760f0))),
          Image.asset('images/gem.png'), 'toplist'),
      card(const Text('Hot', style: TextStyle(color: Color(0xffdd5555))),
          Image.asset('images/fire.png'), 'hot'),
      card(const Text('Random', style: TextStyle(color: Color(0xffee7733))),
          Image.asset('images/random.png'), 'random'),
    ];
  }

  String keyword = '';

  void scrollTop() {}

  @override
  void initState() {
    super.initState();
    load = Get.find(tag: tag);
  }

  void setKeyword(String value) {
    setState(() {
      keyword = value;
    });
  }

  // void _onReduxChange(HandleActions? old, HandleActions now) {
  //   // print(old);
  //   // print(now);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        child: NestedScrollView(
          controller: storeController.homeScrollCtrl,
          headerSliverBuilder: (context, sel) {
            return <Widget>[
              SliverAppBar(
                pinned: false,
                snap: false,
                floating: false,
                toolbarHeight: 190,
                backgroundColor: Colors.transparent,
                leadingWidth: 0,
                leading: const Icon(Icons.menu, color: Colors.transparent),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: ListView(
                        scrollDirection: Axis.horizontal, //方向
                        children: cartList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: TextEditingController(
                            text: keyword,
                          ),
                          readOnly: true,
                          textInputAction: TextInputAction.search,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SearchBarPage(
                                          keyword: '',
                                          tag: getTag(sort: 'relevance'),
                                        )));
                          },
                          // onSubmitted: (value) {
                          //   home.setParams(
                          //       value != ''
                          //           ? {'q': value, 'sorting': "relevance"}
                          //           : {'q': value},
                          //       init: true);
                          //   setKeyword(value);
                          // },
                          decoration: InputDecoration(
                              hintText: 'Search....',
                              prefixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  }),
                              suffixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    )
                  ],
                ),
                expandedHeight: 190,
              )
            ];
          },
          body: PictureList(tag: tag),
        ));
  }
}
