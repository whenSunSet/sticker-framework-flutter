import 'package:flutter/material.dart';
import 'package:sticker/libsample/test_sticker_element.dart';
import 'package:sticker_framework/element_container_widget.dart';
import 'package:sticker_framework/rule_line_element_container_widget.dart';

// 用于测试已经发布的包
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RuleLineElementContainerState decorationElementContainerWidgetState = RuleLineElementContainerState();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.grey
            ),
            child: ElementContainerWidget(
                decorationElementContainerWidgetState),
          ),
          Positioned(
            child: RaisedButton(
              child: Text("add"),
              onPressed: () {
                StickerElement stickerElement = StickerElement(100, 100);
                decorationElementContainerWidgetState
                    .addSelectAndUpdateElement(
                    stickerElement);
              },
            ),
            left: 0,
            top: 50,
          ),
          Positioned(
            child: RaisedButton(
              child: Text("delete"),
              onPressed: () {
                decorationElementContainerWidgetState
                    .unSelectDeleteAndUpdateTopElement();
              },
            ),
            left: 100,
            top: 50,
          ),
        ],
      ),
    );
  }
}

