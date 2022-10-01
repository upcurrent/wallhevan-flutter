import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../component/picture_comp.dart';
import '../store/index.dart';

class PictureList extends StatelessWidget {
  const PictureList({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MainState, HandleActions>(
        // onWillChange: _onReduxChange,
        // onInitialBuild: _afterBuild,
        distinct: true,
        converter: (store) => HandleActions(store),
        onInit: (store) => store.dispatch({'type': StoreActions.init}),
        builder: (context, hAction) {
          MainState mainState = hAction.getMainState();
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 400) {
                hAction.store.dispatch({'type': StoreActions.loadMore});
                return true;
              }
              return false;
            },
            child:MasonryGridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                itemCount: mainState.imageDataList.length,
                itemBuilder: (context, index) {
                  // return Tile(
                  //   index: index,
                  //   extent: (index % 5 + 1) * 100,
                  // );
                  return PictureComp.create(  context, mainState.imageDataList[index]);
                  // return GestureDetector(
                  //     onTap: () => {
                  //       hAction.store.dispatch({
                  //         'type': StoreActions.preview,
                  //         'currentIndex': index
                  //       }),
                  //       Navigator.pushNamed(context, '/pictureViews'),
                  //     },
                  //     child: PictureComp.create(
                  //         context, mainState.imageDataList[index]));
                },
              ),
          );
        });
  }
}
