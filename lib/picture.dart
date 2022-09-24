import 'package:flutter/material.dart';
import 'package:wallhevan/main.dart' show WallImage;
import 'package:wallhevan/pictureComp.dart';

class Picture extends StatelessWidget {
  const Picture({super.key});

  @override
  Widget build(BuildContext context) {
    WallImage routeParams =
        ModalRoute.of(context)?.settings.arguments as WallImage;
    return Scaffold(
      body: PictureComp(image: routeParams, type: WallImage.fullSizePicture),
      // border: Border.all(color: Colors.red, width: 1.0),
      // shape: boxShape,
      // borderRadius: BorderRadius.all(Radius.circular(30.0)),
      //cancelToken: cancellationToken,
    );
  }
}
