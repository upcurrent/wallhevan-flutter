import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/main.dart' show WallImage;
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/searchResult/picture_info.dart';

class PictureViews extends StatelessWidget {

  const PictureViews({super.key});

  List<PictureInfo> getPicture(MainState state) {
    switch (state.viewType) {
      case StoreActions.viewFav:
        return state.favPictureList;
      default:
        return state.imageDataList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ExtendedImageSlidePage(
          slideAxis: SlideAxis.both,
          slideType: SlideType.onlyImage,
          onSlidingPage: (state) {
            ///you can change other widgets' state on page as you want
            ///base on offset/isSliding etc
            //var offset= state.offset;
            // var showSwiper = !state.isSliding;
            // if (showSwiper != _showSwiper) {
            //   // do not setState directly here, the image state will change,
            //   // you should only notify the widgets which are needed to change
            //   // setState(() {
            //   // _showSwiper = showSwiper;
            //   // });
            //
            //   _showSwiper = showSwiper;
            //   rebuildSwiper.add(_showSwiper);
            // }
          },
          child: StoreConnector<MainState, HandleActions>(
              distinct: true,
              converter: (store) => HandleActions(store),
              builder: (context, hAction) {
                MainState mainState = hAction.getMainState();
                List<PictureInfo> pictures = getPicture(mainState);
                return ExtendedImageGesturePageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var item = pictures[index].path;
                    Widget image = PictureComp(
                        image: pictures[index],
                        type: WallImage.fullSizePicture,
                        url: pictures[index].path);
                    image = Container(
                      padding: const EdgeInsets.all(5.0),
                      child: image,
                    );
                    if (index == mainState.currentIndex) {
                      return Hero(
                        tag: item + index.toString(),
                        child: image,
                      );
                    } else {
                      return image;
                    }
                  },
                  itemCount: pictures.length,
                  onPageChanged: (int index) {
                    if (index >= pictures.length - 2) {
                      hAction.loadMore(mainState.viewType);
                    }
                  },
                  controller: ExtendedPageController(
                    initialPage: mainState.currentIndex,
                  ),
                  scrollDirection: Axis.horizontal,
                );
              })),
    );
  }
}
