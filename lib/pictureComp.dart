import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'main.dart' show WallImage;

class PictureComp extends StatelessWidget{

  final double? pHeight;
  final double? halfWidth;
  final WallImage image;
  final int type;
  const PictureComp({super.key, required this.image,this.pHeight,this.halfWidth,required this.type});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: pHeight,
        // width: pWidth,
        width: halfWidth,
        padding: const EdgeInsets.all(2),
        child: ExtendedImage.network(
          image.src,
          fit: BoxFit.scaleDown,
          cache: true,
          loadStateChanged: (ExtendedImageState state){
            switch(state.extendedImageLoadState){
              case LoadState.loading:
                return Shimmer(
                  duration: const Duration(seconds: 2), //Default value
                  color: const Color.fromRGBO(212, 212, 212,1), //Default value
                  enabled: true, //Default value
                  direction: const ShimmerDirection.fromLTRB(),  //Default Value
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
          mode: type == 1 ? ExtendedImageMode.none : ExtendedImageMode.gesture,
          initGestureConfigHandler: type == 1 ? null : (state) {
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