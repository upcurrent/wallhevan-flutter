import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'package:wallhevan/pages/fav_list.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/store/index.dart';

import '../store/model_view/favorites_model.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Widget> getBtn(FavoritesModel favModel) {
    List<Widget> tabs = [];
    for (var fav in favModel.favList) {
      tabs.add(
        HGFButton(
            type: '0',
            text: fav.label,
            selected: fav.id == favModel.favId,
            onSelected: (value) {
              favModel.init(fav.id);
            }),
      );
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MainState, FavoritesModel>(
      converter: (store) => FavoritesModel.fromStore(store),
      onInit: (store) => store.dispatch({'type': StoreActions.initFav}),
      builder: (context, favModel) {
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
                      children: getBtn(favModel),
                    ),
                  )
                ];
              },
              body: const FavPictureList(
                keepAlive: false,
              )),
        ));
      },
    );
  }
}
