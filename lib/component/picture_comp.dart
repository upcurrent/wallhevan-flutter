// ignore_for_file: file_names
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wallhevan/store/search_response/thumbs.dart';

import '../store/search_response/picture_info.dart';

class PictureComp extends StatefulWidget {
  final double? pHeight;
  final double? halfWidth;
  final PictureInfo image;
  final int type;
  final String url;
  static const int pictureList = 1;
  static const int pictureViews = 2;
  static const int fallSizePicture = 3;
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
      type: pictureList,
      url: url,
    );
  }

  @override
  State<StatefulWidget> createState() => _PictureCompState();
}

class _PictureCompState extends State<PictureComp> {
  EdgeInsets getPadding() {
    var size = MediaQuery.of(context).size;
    double height =
        size.width * (widget.image.dimensionY / widget.image.dimensionX);
    double padding = (size.height - height) / 2;
    padding = padding < 0 ? 0 : padding;
    return EdgeInsets.fromLTRB(0, padding, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.pHeight,
        width: widget.halfWidth,
        padding: const EdgeInsets.all(2),
        child: widget.type == PictureComp.pictureViews
            ? GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/picture',
                      arguments: widget.image);
                },
                child: Padding(
                  padding: getPadding(),
                  child: ExtendedImage.network(
                    widget.url,
                    fit: BoxFit.scaleDown,
                    // enableSlideOutPage:true,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          Thumbs? thumbs = widget.image.thumbs;
                          return ExtendedImage.network(
                            thumbs.original!,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          );
                        case LoadState.completed:
                          return null;
                        case LoadState.failed:
                          return null;
                      }
                    },
                    mode: ExtendedImageMode.none,
                    //cancelToken: cancellationToken,
                  ),
                ),
              )
            : widget.type == PictureComp.fallSizePicture
                ? ExtendedImage.network(
                    widget.url,
                    fit: BoxFit.scaleDown,
                    // enableSlideOutPage:true,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          Thumbs? thumbs = widget.image.thumbs;
                          return ExtendedImage.network(
                            thumbs.original!,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          );
                        case LoadState.completed:
                          return null;
                        case LoadState.failed:
                          return null;
                      }
                    },
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
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
                  )
                : ExtendedImage.network(
                    widget.url,
                    fit: BoxFit.fitWidth,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Shimmer(
                            duration:
                                const Duration(seconds: 2), //Default value
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
                          return null;
                        case LoadState.failed:
                          return null;
                      }
                    },
                    mode: ExtendedImageMode.none,
                    //cancelToken: cancellationToken,
                  ));
  }
}
