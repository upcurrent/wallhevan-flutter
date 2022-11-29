import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';
import 'package:wallhevan/store/store.dart';

import '../component/search_page.dart';
import '../store/picture_res/picture_data.dart';
import 'global_theme.dart';

class PictureViews extends StatefulWidget {
  const PictureViews({
    super.key,
    required this.load,
    required this.curIndex,
  });
  final LoadResult load;
  final int curIndex;
  @override
  State<StatefulWidget> createState() => _PictureViewsState();
}

class _PictureViewsState extends State<PictureViews> {
  String getType(String purity) {
    switch (purity) {
      case 'sketchy':
        return '2';
      case 'nsfw':
        return '3';
      default:
        return '1';
    }
  }

  final StoreController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.updatePic(widget.load.pictures[widget.curIndex].path);
  }

  Widget picDataBuild(String id, Function showSearch) {
    return FutureBuilder<PictureData>(
        future: getPictureInfo(id),
        builder: (context, AsyncSnapshot<PictureData> snapshot) {
          var data = snapshot.data;
          if (data != null) {
            var tags = data.tags;
            List<Widget> tagWidgets = [];
            tagWidgets.addAll(tags.map((tag) => HGFButton(
                type: getType(tag.purity),
                text: tag.name,
                selected: true,
                onSelected: (_) => showSearch(tag.id))));
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
    var load = widget.load;
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ExtendedImageSlidePage(
          slideAxis: SlideAxis.vertical,
          slideType: SlideType.onlyImage,
          onSlidingPage: (state) {},
          // slideScaleHandler:(offset){
          //
          // },
          // slideEndHandler: (){
          //
          // },
          child: GlobalTheme.backImg(
            GetBuilder(
                init: load,
                builder: (_) {
                  return ExtendedImageGesturePageView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var item = load.pictures[index].path;
                      Widget image = PictureComp(
                          image: load.pictures[index],
                          type: PictureComp.fullSizePicture,
                          url: load.pictures[index].path);
                      image = SingleChildScrollView(
                          child: Column(
                        children: [
                          // Expanded(child: image),
                          image,
                          picDataBuild(load.pictures[index].id, (int tagId) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SearchBarPage(keyword: 'id:$tagId')));
                          }),
                        ],
                      ));
                      // image = Container(
                      //   padding: const EdgeInsets.all(5.0),
                      //   child: image,
                      // );
                      if (index == widget.curIndex) {
                        return Hero(
                          tag: item + index.toString(),
                          child: image,
                        );
                      } else {
                        return image;
                      }
                    },
                    itemCount: load.pictures.length,
                    onPageChanged: (int index) {
                      controller.updatePic(load.pictures[index].path);
                      if (index >= load.pictures.length - 2) {
                        getPictureList(load);
                      }
                    },
                    controller: ExtendedPageController(
                      initialPage: widget.curIndex,
                    ),
                    scrollDirection: Axis.horizontal,
                  );
                }),
          )),
    );
  }
}
