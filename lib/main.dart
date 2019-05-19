import 'package:flutter/material.dart';
import 'package:sticker/decoration_element_container_widget.dart';
import 'package:sticker/element_container_widget.dart';
import 'package:sticker/sticker_element.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DecorationElementContainerWidgetState decorationElementContainerWidgetState = new DecorationElementContainerWidgetState();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Column(
        children: <Widget>[
          Image.asset(
            "images/default_decoration_delete.png",
            width: 100,
            height: 100,
          ),
          Image.asset(
            "images/default_decoration_delete.png",
            width: 100,
            height: 100,
          ),
          SizedBox(
            width: 300,
            height: 400,
            child: Stack(
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
          )
        ],
      ),
    );
  }
}

