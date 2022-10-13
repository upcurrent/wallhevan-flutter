import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallhevan/store/model_view/picture_list_model.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import '../component/picture_comp.dart';
import '../store/index.dart';

class PictureList extends StatefulWidget {
  const PictureList(
      {super.key, required this.viewType, this.keepAlive});

  final StoreActions viewType;

  final bool? keepAlive;

  @override
  State<StatefulWidget> createState() {
    return _PictureListState();
  }
}

class _PictureListState extends State<PictureList>
    with AutomaticKeepAliveClientMixin {
  List<PictureInfo> getPicture(MainState state) {
    switch (widget.viewType) {
      case StoreActions.viewFav:
        return state.favPictureList;
      default:
        return state.imageDataList;
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StoreConnector<MainState, PictureListModel>(
        distinct: true,
        converter: (store) =>
            PictureListModel.formStore(store, widget.viewType),
        onInit: (store) => store
            .dispatch({'type': StoreActions.init, 'viewType': widget.viewType}),
        builder: (context, pictureModel) {
          List<PictureInfo> pictures = pictureModel.pictures;
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 400) {
                pictureModel.loadMore();
                return true;
              }
              return false;
            },
            child: MasonryGridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              itemCount: pictures.length,
              itemBuilder: (context, index) {
                String url = pictures[index].thumbs.original!;
                String path = pictures[index].path;
                PictureComp pictureComp =
                    PictureComp.create(context, pictures[index], url);
                return GestureDetector(
                    onTap: () {
                      pictureModel.preview(index);
                      Navigator.pushNamed(context, '/pictureViews');
                    },
                    child: StoreConnector<MainState, Set>(
                      converter: (store) => store.state.cachePic,
                      builder: (context, cache) {
                        return cache.contains(path)
                            ? PictureComp.create(context, pictures[index], path)
                            : pictureComp;
                      },
                    ));
              },
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => widget.keepAlive ?? true;
}
