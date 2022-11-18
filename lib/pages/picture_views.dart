import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wallhevan/component/picture_comp.dart';
import 'package:wallhevan/pages/search.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import '../component/search_page.dart';
import '../store/picture_res/picture_data.dart';
import 'global_theme.dart';

class PictureViews extends StatefulWidget {
  const PictureViews(
      {super.key,
      required this.pictures,
      required this.curIndex,
      required this.loadMore,
      required this.updatePic});
  final List<PictureInfo> pictures;
  final int curIndex;
  final Function loadMore;
  final Function updatePic;
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

  List<PictureInfo> pictures = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      pictures = widget.pictures;
    });
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
            ExtendedImageGesturePageView.builder(
              itemBuilder: (BuildContext context, int index) {
                var item = pictures[index].path;
                Widget image = PictureComp(
                    image: pictures[index],
                    type: PictureComp.fullSizePicture,
                    url: pictures[index].path);
                image = SingleChildScrollView(
                  child: Column(
                    children: [
                      // Expanded(child: image),
                      image,
                      picDataBuild(pictures[index].id, (int tagId) {
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
              itemCount: pictures.length,
              onPageChanged: (int index) {
                widget.updatePic(pictures[index].path);
                if (index >= pictures.length - 2) {
                  widget.loadMore((List<PictureInfo> data) {
                    setState(() {
                      pictures.addAll(data);
                    });
                  });
                }
              },
              controller: ExtendedPageController(
                initialPage: widget.curIndex,
              ),
              scrollDirection: Axis.horizontal,
            ),
          )),
    );
  }
}
