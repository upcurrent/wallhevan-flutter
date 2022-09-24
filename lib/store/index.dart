
import 'package:flutter/material.dart';

import '../main.dart' show WallImage;

enum Actions { increment }

class MainState {

  final List<Widget> imageList;
  final List<WallImage> imageDataList;
  bool preview;
  bool loading;
  int pageNum;
  int currentIndex;
  int bottomNavIndex;

  MainState(this.imageList, this.imageDataList, this.preview, this.loading,
      this.pageNum, this.currentIndex,this.bottomNavIndex);

  factory MainState.initState() => MainState([],[],false,false,1,0,0);

  void addWallImage(WallImage img){
    imageDataList.add(img);
  }

  void addPictureWidget(Widget widget){
    imageList.add(widget);
  }

}