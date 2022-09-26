import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/main.dart' show WallImage;
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/store/index.dart';

class PictureViews extends StatelessWidget {
  // List<WallImage> pics;
  // int currentIndex;

  const PictureViews({super.key});

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
              // onWillChange: _onReduxChange,
              // onInitialBuild: _afterBuild,
              distinct: true,
              converter: (store) => HandleActions(store),
              builder: (context, hAction) {
                MainState mainState = hAction.getMainState();
                return ExtendedImageGesturePageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var item = mainState.imageDataList[index].src;
                    Widget image = PictureComp(
                        image: mainState.imageDataList[index], type: WallImage.fullSizePicture);
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
                  itemCount: mainState.imageDataList.length,
                  onPageChanged: (int index) {
                     if(index >= mainState.imageDataList.length - 2){
                       hAction.loadMore();
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
