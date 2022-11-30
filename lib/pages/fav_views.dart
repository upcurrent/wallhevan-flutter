import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/model_view/picture_list_model.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import '../store/picture_res/picture_data.dart';
import 'global_theme.dart';

class FavPictureViews extends StatelessWidget {
  const FavPictureViews({super.key, required this.back, required this.currentIndex});
  final bool back;
  final int currentIndex;
  String getType(String purity){
    switch(purity){
     case 'sketchy':
        return '2';
     case 'nsfw':
        return '3';
     default:
        return '1';
    }
  }
  Widget picDataBuild(String id,Function showSearch) {

    return FutureBuilder<PictureData>(
        future: getPictureInfo(id),
        builder: (context, AsyncSnapshot<PictureData> snapshot) {
          var data = snapshot.data;
          if (data != null) {
            var tags = data.tags;
            List<Widget> tagWidgets = [];
            tagWidgets.addAll(
                tags.map((tag) => HGFButton(
                    type: getType(tag.purity),
                    text: tag.name,
                    selected: true,
                    onSelected: (_)=>showSearch(tag.id))));
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 2,
                  children: tagWidgets,
                )
              ],
            );
          }
          return Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ExtendedImageSlidePage(
          slideAxis: SlideAxis.vertical,
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
              onWillChange: (now,old){
              },
              converter: (store) =>
                  PictureListModel.formStore(store),
              builder: (context, pictureView) {
                List<PictureInfo> pictures = pictureView.pictures;
                return GlobalTheme.backImg(
                  ExtendedImageGesturePageView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var item = pictures[index].path;
                      Widget image = PictureComp(
                          image: pictures[index],
                          type: PictureComp.fullSizePicture,
                          url: pictures[index].path);
                      image = ListView(
                        children: [
                          image,
                          picDataBuild(pictures[index].id,(int tagId){
                            // if(back){
                            //   pictureView.setParams('id:$tagId',init:true);
                            //   Navigator.pop(context);
                            // }else{
                              pictureView.setParams('id:$tagId');
                              // Navigator.push(context, MaterialPageRoute(builder: (_)=> SearchBarPage(keyword: 'id:$tagId')));
                            // }
                          }),
                        ],
                      );
                      image = Container(
                        padding: const EdgeInsets.all(5.0),
                        child: image,
                      );
                      if (index == currentIndex) {
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
                    // slideScaleHandler:(offset){
                    //
                    // },
                    controller: ExtendedPageController(
                      initialPage: currentIndex,
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                );
              })),
    );
  }
}
