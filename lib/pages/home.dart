import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/pages/picture_list.dart';

import '../store/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> cartList(HandleActions hAction) {
    bool sortingSelected(String value) {
      return hAction.store.state.search.params['sorting'] == value;
    }

    void setSorting(String value) {
      hAction.setParams('sorting', value, search: true);
    }

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
          child: GestureDetector(
            onTap: () => setSorting(value),
            child: Container(
              decoration: sortingSelected(value) ? selDecoration : decoration,
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
            ),
          ));
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

  void setKeyword(String value) {
    setState(() {
      keyword = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        child: StoreConnector<MainState, HandleActions>(
          converter: (store) => HandleActions(store),
          builder: (context, hAction) {
            return NestedScrollView(
              headerSliverBuilder: (context, sel) {
                return <Widget>[
                  SliverAppBar(
                    pinned: false,
                    snap: false,
                    floating: false,
                    toolbarHeight: 190,
                    backgroundColor: Colors.transparent,
                    title: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal, //方向
                            children: cartList(hAction),
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
                              textInputAction: TextInputAction.search,
                              cursorColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              onSubmitted: (value) {
                                hAction.setParams('q', value, search: true);
                                setKeyword(value);
                              },
                              decoration: const InputDecoration(
                                  hintText: 'Search....',
                                  suffixIcon: Icon(
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
              body: const PictureList(viewType: StoreActions.viewList),
            );
          },
        ));
  }
}
