import 'package:flutter/material.dart';
import 'package:wallhevan/main.dart';
import 'package:wallhevan/pictureComp.dart';

class Picture extends StatelessWidget {
  const Picture({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? routeParams =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
        body: Center(
      // child: Image.network(routeParams!['src']),
      child: PictureComp(image: WallImage(routeParams!['src']),type:2),
        // border: Border.all(color: Colors.red, width: 1.0),
        // shape: boxShape,
        // borderRadius: BorderRadius.all(Radius.circular(30.0)),
        //cancelToken: cancellationToken,
      ),
    );
  }
}
