import 'package:flutter/material.dart';
import 'package:sticker_framework/decoration_element.dart';

class StickerElement extends DecorationElement {
  StickerElement(double mOriginWidth, double mOriginHeight)
      : super(mOriginWidth, mOriginHeight);

  @override
  Widget initWidget() {
    return Image(
      image: NetworkImage(
          'http://pic40.nipic.com/20140412/18428321_144447597175_2.jpg'),
      width: mOriginWidth,
      height: mOriginHeight,
      fit: BoxFit.cover,
    );
  }
}