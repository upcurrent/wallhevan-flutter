import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'package:wallhevan/pages/picture_list.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/store/index.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Widget> getBtn(HandleActions hAction) {
    MainState state = hAction.getMainState();
    List<Widget> tabs = [];
    for (var fav in state.favList) {
      tabs.add(
        HGFButton(
            type: '0',
            text: fav.label,
            selected: fav.id == state.favId,
            onSelected: (value) {
              hAction.store.dispatch({
                'type': StoreActions.init,
                'viewType': StoreActions.viewFav,
                'id': fav.id
              });
            }),
      );
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MainState, HandleActions>(
      converter: (store) => HandleActions(store),
      onInit: (store) => store.dispatch({'type': StoreActions.initFav}),
      builder: (context, hAction) {
        return GlobalTheme.backImg(Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
              headerSliverBuilder: (context, sel) {
                return <Widget>[
                  SliverAppBar(
                    elevation: 0,
                    pinned: false,
                    snap: false,
                    floating: false,
                    backgroundColor: Colors.transparent,
                    title: Row(
                      children: getBtn(hAction),
                    ),
                  )
                ];
              },
              body: const PictureList(
                viewType: StoreActions.viewFav,
                keepAlive: false,
              )),
        ));
      },
    );
  }
}
