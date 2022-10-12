import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/main.dart' show WallImage;
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/model_view/picture_list_model.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import 'global_theme.dart';

class PictureViews extends StatelessWidget {
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
          child: StoreConnector<MainState, PictureListModel>(
              distinct: true,
              converter: (store) => PictureListModel.listFromStore(store,store.state.viewType),
              builder: (context, pictureView) {
                List<PictureInfo> pictures = pictureView.pictures;
                return GlobalTheme.backImg(
                  ExtendedImageGesturePageView.builder(
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
                      if (index == pictureView.currentIndex) {
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
                      pictureView.updatePic(index);
                      if (index >= pictures.length - 2) {
                        pictureView.loadMore();
                      }
                    },
                    controller: ExtendedPageController(
                      initialPage: pictureView.currentIndex,
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                );
              })),
    );
  }
}
