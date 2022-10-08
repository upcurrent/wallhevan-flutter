import 'package:flutter/material.dart';
import 'package:wallhevan/main.dart' show WallImage;
import 'package:wallhevan/component/picture_comp.dart';

import '../store/searchResult/picture_info.dart';

class Picture extends StatelessWidget {
  const Picture({super.key});

  @override
  Widget build(BuildContext context) {
    PictureInfo routeParams =
        ModalRoute.of(context)?.settings.arguments as PictureInfo;
    return Scaffold(
      body: PictureComp(image: routeParams, type: WallImage.fullSizePicture,url:''),
      // border: Border.all(color: Colors.red, width: 1.0),
      // shape: boxShape,
      // borderRadius: BorderRadius.all(Radius.circular(30.0)),
      //cancelToken: cancellationToken,
    );
  }
}
