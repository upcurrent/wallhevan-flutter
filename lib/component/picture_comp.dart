
// ignore_for_file: file_names
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../main.dart' show WallImage;
import '../store/searchResult/picture_info.dart';

class PictureComp extends StatelessWidget{
  final double? pHeight;
  final double? halfWidth;
  final PictureInfo image;
  final int type;
  const PictureComp({super.key, required this.image,this.pHeight,this.halfWidth,required this.type});

  // factory PictureComp.create(BuildContext context,WallImage image){
  //   double width = MediaQuery.of(context).size.width / 2;
  //   double height = image.height / (image.width / width);
  //   return PictureComp(
  //     pHeight: height,
  //     halfWidth: width,
  //       image: image,
  //       type: WallImage.previewPicture);
  // }

  factory PictureComp.create(BuildContext context,PictureInfo picture){
    double width = MediaQuery.of(context).size.width / 2;
    double height = picture.dimensionY / (picture.dimensionX / width);
    return PictureComp(
        pHeight: height,
        halfWidth: width,
        image: picture,
        type: WallImage.previewPicture);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: pHeight,
        // width: pWidth,
        width: halfWidth,
        padding: const EdgeInsets.all(2),
        child: ExtendedImage.network(
          type == WallImage.fullSizePicture ? image.path : image.thumbs!.original!,
          fit: type == WallImage.fullSizePicture ? BoxFit.scaleDown : BoxFit.fitWidth,
          cache: true,
          loadStateChanged: (ExtendedImageState state){
            switch(state.extendedImageLoadState){
              case LoadState.loading:
                if(type == WallImage.fullSizePicture){
                  // double halfWidth = MediaQuery.of(context).size.width;
                  return ExtendedImage.network(image.thumbs!.original!,width: double.infinity,fit: BoxFit.fitWidth,);
                }
                return Shimmer(
                  duration: const Duration(seconds: 2), //Default value
                  color: const Color.fromRGBO(112, 142, 122,1), //Default value
                  enabled: true, //Default value
                  direction: const ShimmerDirection.fromLeftToRight(),  //Default Value
                  child: Container(
                    color: const Color.fromRGBO(230, 230, 230,1),
                  ),
                );
              case LoadState.completed:
                return null;
              case LoadState.failed:
                return null;
            }
          },
          mode: type == WallImage.previewPicture ? ExtendedImageMode.none : ExtendedImageMode.gesture,
          initGestureConfigHandler: type == WallImage.previewPicture ? null : (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              initialAlignment: InitialAlignment.center,
            );
          },
          //cancelToken: cancellationToken,
        )
    );
  }

}