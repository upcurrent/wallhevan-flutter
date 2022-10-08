// ignore_for_file: file_names
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wallhevan/store/index.dart';
import 'package:wallhevan/store/searchResult/thumbs.dart';

import '../main.dart' show WallImage;
import '../store/searchResult/picture_info.dart';

class PictureComp extends StatefulWidget {
  final double? pHeight;
  final double? halfWidth;
  final PictureInfo image;
  final int type;
  final String url;
  const PictureComp(
      {super.key,
      required this.image,
      this.pHeight,
      this.halfWidth,
      required this.type,
      required this.url});

  // factory PictureComp.create(BuildContext context,WallImage image){
  //   double width = MediaQuery.of(context).size.width / 2;
  //   double height = image.height / (image.width / width);
  //   return PictureComp(
  //     pHeight: height,
  //     halfWidth: width,
  //       image: image,
  //       type: WallImage.previewPicture);
  // }

  factory PictureComp.create(
      BuildContext context, PictureInfo picture, String url) {
    double width = MediaQuery.of(context).size.width / 2;
    double height = picture.dimensionY / (picture.dimensionX / width);
    return PictureComp(
      pHeight: height,
      halfWidth: width,
      image: picture,
      type: WallImage.previewPicture,
      url: url,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //       height: pHeight,
  //       // width: pWidth,
  //       width: halfWidth,
  //       padding: const EdgeInsets.all(2),
  //       child: ExtendedImage.network(
  //         type == WallImage.fullSizePicture ? image.path : image.thumbs!.original!,
  //         fit: type == WallImage.fullSizePicture ? BoxFit.scaleDown : BoxFit.fitWidth,
  //         cache: true,
  //         loadStateChanged: (ExtendedImageState state){
  //           switch(state.extendedImageLoadState){
  //             case LoadState.loading:
  //               if(type == WallImage.fullSizePicture){
  //                 // double halfWidth = MediaQuery.of(context).size.width;
  //                 return ExtendedImage.network(image.thumbs!.original!,width: double.infinity,fit: BoxFit.fitWidth,);
  //               }
  //               return Shimmer(
  //                 duration: const Duration(seconds: 2), //Default value
  //                 color: const Color.fromRGBO(112, 142, 122,1), //Default value
  //                 enabled: true, //Default value
  //                 direction: const ShimmerDirection.fromLeftToRight(),  //Default Value
  //                 child: Container(
  //                   color: const Color.fromRGBO(230, 230, 230,1),
  //                 ),
  //               );
  //             case LoadState.completed:
  //               return null;
  //             case LoadState.failed:
  //               return null;
  //           }
  //         },
  //         mode: type == WallImage.previewPicture ? ExtendedImageMode.none : ExtendedImageMode.gesture,
  //         initGestureConfigHandler: type == WallImage.previewPicture ? null : (state) {
  //           return GestureConfig(
  //             minScale: 0.9,
  //             animationMinScale: 0.7,
  //             maxScale: 3.0,
  //             animationMaxScale: 3.5,
  //             speed: 1.0,
  //             inertialSpeed: 100.0,
  //             initialScale: 1.0,
  //             inPageView: true,
  //             initialAlignment: InitialAlignment.center,
  //           );
  //         },
  //         //cancelToken: cancellationToken,
  //       )
  //   );
  // }

  @override
  State<StatefulWidget> createState() => _PictureCompState();
}

class _PictureCompState extends State<PictureComp> {
  // String url = '';
  BoxFit fit = BoxFit.fitWidth;

  @override
  void initState() {
    super.initState();
    setState(() {
      // url = widget.type == WallImage.fullSizePicture
      //     ? widget.image.path
      //     : widget.image.thumbs.original!;
      fit = widget.type == WallImage.fullSizePicture
          ? BoxFit.scaleDown
          : BoxFit.fitWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.pHeight,
        // width: pWidth,
        width: widget.halfWidth,
        padding: const EdgeInsets.all(2),
        child: StoreConnector<MainState, HandleActions>(
          converter: (store) => HandleActions(store),
          builder: (context, hAction) {
            return ExtendedImage.network(
              widget.url,
              fit: fit,
              cache: true,
              loadStateChanged: (ExtendedImageState state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    if (widget.type == WallImage.fullSizePicture) {
                      // double halfWidth = MediaQuery.of(context).size.width;
                      Thumbs? thumbs = widget.image.thumbs;
                      return ExtendedImage.network(
                        thumbs.original!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      );
                    }
                    return Shimmer(
                      duration: const Duration(seconds: 2), //Default value
                      color: const Color.fromRGBO(
                          112, 142, 122, 1), //Default value
                      enabled: true, //Default value
                      direction: const ShimmerDirection
                          .fromLeftToRight(), //Default Value
                      child: Container(
                        color: const Color.fromRGBO(230, 230, 230, 1),
                      ),
                    );
                  case LoadState.completed:
                    if (widget.type == WallImage.fullSizePicture) {
                      hAction.store.dispatch(
                          {'type': StoreActions.updatePic, 'url': widget.url});
                    }
                    return null;
                  case LoadState.failed:
                    return null;
                }
              },
              mode: widget.type == WallImage.previewPicture
                  ? ExtendedImageMode.none
                  : ExtendedImageMode.gesture,
              initGestureConfigHandler: widget.type == WallImage.previewPicture
                  ? null
                  : (state) {
                      return GestureConfig(
                        minScale: 0.9,
                        animationMinScale: 0.7,
                        maxScale: 3.0,
                        animationMaxScale: 3.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        inPageView: true,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
              //cancelToken: cancellationToken,
            );
          },
        ));
  }
}
