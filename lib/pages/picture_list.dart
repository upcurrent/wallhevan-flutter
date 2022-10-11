import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallhevan/store/search_result/picture_info.dart';

import '../component/picture_comp.dart';
import '../store/index.dart';

class PictureList extends StatefulWidget {
  const PictureList({super.key, required this.viewType, this.keepAlive, this.controller});

  final StoreActions viewType;

  final ScrollController? controller;

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
    return StoreConnector<MainState, HandleActions>(
        distinct: true,
        converter: (store) => HandleActions(store),
        onInit: (store) => store
            .dispatch({'type': StoreActions.init, 'viewType': widget.viewType}),
        builder: (context, hAction) {
          MainState mainState = hAction.getMainState();
          List<PictureInfo> pictures = getPicture(mainState);
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 400) {
                hAction.store.dispatch({
                  'type': StoreActions.loadMore,
                  'viewType': widget.viewType
                });
                return true;
              }
              return false;
            },
            child: MasonryGridView.count(
              // controller: widget.controller,
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
                      hAction.store.dispatch({
                        'type': StoreActions.preview,
                        'viewType': widget.viewType,
                        'currentIndex': index
                      });
                      Navigator.pushNamed(context, '/pictureViews');
                    },
                    child: hAction.hasCache(path)
                        ? PictureComp.create(context, pictures[index], path)
                        : pictureComp);
              },
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => widget.keepAlive ?? true;
}
