import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'package:wallhevan/pages/picture_views.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import '../component/picture_comp.dart';
import '../store/store.dart';

class PictureList extends StatefulWidget {
  const PictureList({super.key, this.keepAlive, this.sort, required this.tag});

  final String? sort;

  final bool? keepAlive;

  final String tag;

  @override
  State<StatefulWidget> createState() {
    return _PictureListState();
  }
}

class _PictureListState extends State<PictureList>
    with AutomaticKeepAliveClientMixin {
  late LoadResult load;
  StoreController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // load = widget.load ?? load;
    load = Get.find(tag: widget.tag);
    getPictureList(load);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GlobalTheme.backImg(NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 400 &&
            load.pictures.length < load.total) {
          getPictureList(load);
          return true;
        }
        return false;
      },
      child: GetBuilder<LoadResult>(
          tag: widget.tag,
          builder: (load) {
            return MasonryGridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              itemCount: load.pictures.length,
              itemBuilder: (context, index) {
                String url = load.pictures[index].thumbs.original!;
                String path = load.pictures[index].path;
                return GestureDetector(onTap: () {
                  // listModel.preview(path);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PictureViews(
                                curIndex: index,
                                load: load,
                              )));
                }, child: Obx(() {
                  return controller.cachePic.contains(path)
                      ? PictureComp.create(context, load.pictures[index], path)
                      : PictureComp.create(context, load.pictures[index], url);
                }));
                // PictureComp.create(context, load.pictures[index], url));

                // ? PictureComp.create(context, load.pictures[index], path)
                // : PictureComp.create(context, load.pictures[index], url)));
              },
            );
          }),
    ));
  }

  @override
  bool get wantKeepAlive => widget.keepAlive ?? true;
}

class PictureReq {
  int pageNum = 1;
  int total = 0;
  int index = 0;
  String q = '';
  String sort = '';
  bool loading = false;
  List<PictureInfo> pictures = [];
}
