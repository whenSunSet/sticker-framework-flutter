import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

// 用于测试已经发布的包
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AW();
  }
}

class AW extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AWS();
  }
}

class AWS extends State<AW> {
  final TextEditingController _controller = new TextEditingController();
  bool a = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        print("state");
        a = !a;
        WidgetsBinding.instance.addPostFrameCallback(onAfterRendering);
      });
    });

    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text('输入和选择'),
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: double.infinity,
            minWidth: double.infinity,
          ),
          child: get(),
        ),
      ),
    );
  }

  Widget get() {
//    TextField textField = TextField(
//      controller: _controller,
//      decoration: InputDecoration(
//        contentPadding: EdgeInsets.all(100.0),
//      ),
//    );
//    if (a) {
//      return Stack(
//        children: <Widget>[
//          textField,
//        ],
//      );
//    } else {
//
//    }
    return GestureDetector(
      child: Stack(
//          children: <Widget>[
//            textField,
////          Text('输入和选择'),
//          ],
        children: <Widget>[
          Text("")
        ],
      ),
      onLongPress: longs,
      onTap: taps,
      behavior: HitTestBehavior.opaque,
    );
  }

  void longs() {
    print("longs");
  }

  void taps() {
    print("taps");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(onAfterRendering);
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback(onAfterRendering);
  }

  void onAfterRendering(Duration timeStamp) {
    RenderObject renderObject = context?.findRenderObject();
    if (renderObject != null) {
      Size size = renderObject.paintBounds.size;
      Vector3 vector3 = renderObject.getTransformTo(null)?.getTranslation();
      print("x:${vector3.x}, y:${vector3.y}, width:${size.width}, height:${size
          .height}");
    }
  }

}
