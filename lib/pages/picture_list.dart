import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallhevan/model_view/picture_view_model.dart';
import 'package:wallhevan/pages/global_theme.dart';
import 'package:wallhevan/pages/picture_views.dart';
import 'package:wallhevan/store/search_response/picture_info.dart';

import '../component/picture_comp.dart';
import '../store/index.dart';

class PictureList extends StatefulWidget {

  const PictureList({super.key, this.keepAlive, required this.q, this.sort});

  final String q;

  final String? sort;

  final bool? keepAlive;

  @override
  State<StatefulWidget> createState() {
    return _PictureListState();
  }
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
class _PictureListState extends State<PictureList>
    with AutomaticKeepAliveClientMixin {

  PictureReq req = PictureReq();

  @override
  void didUpdateWidget(covariant PictureList oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      req.q = widget.q;
      req.sort = widget.sort ?? req.sort;
      req.pageNum = 1;
      req.total = 0;
    });
    init();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      req.sort = widget.sort ?? 'toplist';
      req.q = widget.q;
    });
  }

  void addData(List<PictureInfo> data,int total){
    setState(() {
      req.pictures.addAll(data);
      req.pageNum++;
      req.total = total;
    });
  }
  void setData(List<PictureInfo> data,int total){
    setState(() {
      req.pictures.clear();
      req.pictures.addAll(data);
      req.pageNum++;
      req.total = total;
    });
  }
  Function loadMore = (){};
  Function init = (){};

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GlobalTheme.backImg(StoreConnector<MainState, PictureViewModel>(
        distinct: true,
        converter: (store) => PictureViewModel.fromStore(store),
        onInitialBuild:(listModel){
          listModel.getPictureList(req,setData);
          setState(() {
            init = (){
              listModel.getPictureList(req,setData);
            };
            loadMore = (Function callBack) async {
              listModel.getPictureList(req,(List<PictureInfo> data,int total){
                addData(data,total);
                callBack(data);
              });
            };
          });
        },
        builder: (context, listModel) {
          List<PictureInfo> pictures = req.pictures;
          // print(pictures.length);
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 400) {
                listModel.getPictureList(req,addData);
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
                return GestureDetector(
                    onTap: () {
                      listModel.preview(path);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PictureViews(
                                  pictures: pictures,
                                  curIndex: index,
                                  loadMore: loadMore,
                                  updatePic: listModel.updatePic,)));
                      // Navigator.pushNamed(context, '/pictureViews');
                    },
                    child: StoreConnector<MainState, Set>(
                      converter: (store) => store.state.cachePic,
                      builder: (context, cache) {
                        return cache.contains(path)
                            ? PictureComp.create(context, pictures[index], path)
                            : PictureComp.create(context, pictures[index], url);
                      },
                    ));
              },
            ),
          );
        }));
  }

  @override
  bool get wantKeepAlive => widget.keepAlive ?? true;
}
