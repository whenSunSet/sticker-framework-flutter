import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sticker/rotate_scale_gesture_recognizer.dart';
import 'package:sticker/ws_element.dart';

abstract class DecorationElement extends WsElement {
  static const String TAG = "heshixi:DElement";

  static const double ELEMENT_BUTTON_WIDTH = 24; // 按钮的宽度

  static const double REDUNDANT_AREA_WIDTH = 20; // 延伸区域的宽度

  bool mIsSingleFingerScaleAndRotate; // 是否处于单指旋转缩放的状态

  double mRedundantAreaLeftRight = 0; // 内容区域左右向外延伸的一段距离，用于扩展元素的可点击区域

  double mRedundantAreaTopBottom = 0; // 内容区域上下向外延伸的一段距离，用于扩展元素的可点击区域

  bool mIsShowDecoration = false;

  DecorationElement(double originWidth, double originHeight)
      : super(originWidth, originHeight) {
    mRedundantAreaTopBottom = REDUNDANT_AREA_WIDTH + ELEMENT_BUTTON_WIDTH / 2;
    mRedundantAreaLeftRight = REDUNDANT_AREA_WIDTH + ELEMENT_BUTTON_WIDTH / 2;
  }

  @override
  buildTransform() {
    if (!mIsShowDecoration) {
      return super.buildTransform();
    }
    Rect originWholeRect = getOriginWholeRect();
    Matrix4 matrix4 = Matrix4.translationValues(mMoveX, mMoveY, 0);
    matrix4.rotateZ(mRotate);
    Matrix4 matrix4Scale = Matrix4.translationValues(0, 0, 0);
    matrix4Scale.scale(mScale, mScale, 1);
    Rect originContentRect = getOriginContentRect();
    Rect contentRect = getContentRect();
    double contentChangeWidth = contentRect.width - originContentRect.width;
    double contentChangeHeight = contentRect.height - originContentRect.height;
    Matrix4 matrix4ScaleForBox = Matrix4.translationValues(0, 0, 0);
    double boxScale = (getContentRect().width + 2 * mRedundantAreaLeftRight -
        ELEMENT_BUTTON_WIDTH) /
        (getOriginContentRect().width + 2 * mRedundantAreaLeftRight -
            ELEMENT_BUTTON_WIDTH);
    matrix4ScaleForBox.scale(boxScale, boxScale, 1);
    return Transform(
      alignment: Alignment.center,
      transform: matrix4,
      child: Container(
        width: originWholeRect.width,
        height: originWholeRect.height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Transform(
              alignment: Alignment.center,
              transform: matrix4ScaleForBox,
              child: Container(
                width: originWholeRect.width - ELEMENT_BUTTON_WIDTH,
                height: originWholeRect.height - ELEMENT_BUTTON_WIDTH,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 2.0 / boxScale, color: Colors.white),
                    left: BorderSide(
                        width: 2.0 / boxScale, color: Colors.white),
                    right: BorderSide(
                        width: 2.0 / boxScale, color: Colors.white),
                    bottom: BorderSide(
                        width: 2.0 / boxScale, color: Colors.white),
                  ),
                ),
              ),
            ),
            Transform(
              alignment: Alignment.center,
              transform: matrix4Scale,
              child: Opacity(
                opacity: mAlpha,
                child: mElementShowingWidget,
              ),
            ),
            Positioned(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.translationValues(
                    -contentChangeWidth / 2, -contentChangeHeight / 2, 0),
                child: Image.asset(
                  "images/default_decoration_delete.png",
                  width: ELEMENT_BUTTON_WIDTH,
                  height: ELEMENT_BUTTON_WIDTH,
                ),
              ),
              left: 0,
              top: 0,
            ),
            Positioned(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.translationValues(
                    contentChangeWidth / 2, contentChangeHeight / 2, 0),
                child: Image.asset(
                  "images/default_decoration_scale.png",
                  width: ELEMENT_BUTTON_WIDTH,
                  height: ELEMENT_BUTTON_WIDTH,
                ),
              ),
              bottom: 0,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  select() {
    super.select();
    mIsShowDecoration = true;
  }

  @override
  unSelect() {
    super.unSelect();
    mIsShowDecoration = false;
  }

  @override
  delete() {
    super.delete();
    mIsShowDecoration = false;
  }

  @override
  onSingleFingerMoveStart() {
    super.onSingleFingerMoveStart();
    mIsShowDecoration = false;
  }

  @override
  onSingleFingerMoveEnd() {
    super.onSingleFingerMoveEnd();
    mIsShowDecoration = true;
  }

  @override
  onDoubleFingerScaleAndRotateStart(
      RotateScaleStartDetails rotateScaleStartDetails) {
    super.onDoubleFingerScaleAndRotateStart(rotateScaleStartDetails);
    mIsShowDecoration = false;
  }

  @override
  onDoubleFingerScaleAndRotateEnd(
      RotateScaleEndDetails rotateScaleEndDetails) {
    super.onDoubleFingerScaleAndRotateEnd(rotateScaleEndDetails);
    mIsShowDecoration = true;
  }

  ///当前 Element 开始单指旋转缩放
  onSingleFingerScaleAndRotateStart() {
    mIsSingleFingerScaleAndRotate = true;
    mIsShowDecoration = false;
  }

  ///当前 Element 单指旋转缩放中
  onSingleFingerScaleAndRotateProcess(double motionEventX,
      double motionEventY) {
    scaleAndRotateForSingleFinger(motionEventX, motionEventY);
  }

  ///当前 Element 单指旋转缩放结束
  onSingleFingerScaleAndRotateEnd() {
    mIsSingleFingerScaleAndRotate = true;
    mIsShowDecoration = true;
  }

  ///判断坐标是否处于 旋转缩放按钮 区域中
  ///[motionEventX]
  ///[motionEventY]
  isInScaleAndRotateButton(double motionEventX, double motionEventY) {
    return isPointInTheRect(motionEventX, motionEventY,
        getScaleAndRotateButtonRect());
  }

  ///判断坐标是否处于 删除按钮 区域中
  ///[motionEventX]
  ///[motionEventY]
  isInRemoveButton(double motionEventX, double motionEventY) {
    return isPointInTheRect(motionEventX, motionEventY, getRemoveButtonRect());
  }

  ///计算单指缩放的旋转角度
  ///  [motionEventX]
  ///  [motionEventY]
  scaleAndRotateForSingleFinger(double motionEventX, double motionEventY) {
    Rect originWholeRect = getOriginWholeRect();
    double halfWidth = originWholeRect.width / 2.0;
    double halfHeight = originWholeRect.height / 2.0;
    double newRadius = Offset(motionEventX - originWholeRect.center.dx,
        motionEventY - originWholeRect.center.dy).distance;
    double oldRadius = Offset(halfHeight, halfWidth).distance;

    mScale = newRadius / oldRadius;
    mScale = (mScale < MIN_SCALE_FACTOR ? MIN_SCALE_FACTOR : mScale);
    mScale = (mScale > MAX_SCALE_FACTOR ? MAX_SCALE_FACTOR : mScale);

    mRotate = math.atan2(halfWidth, halfHeight) - math.atan2(
        motionEventX - originWholeRect.center.dx,
        motionEventY - originWholeRect.center.dy);
    print(
        "$TAG scaleAndRotateForSingleFinger "
            "mScale:$mScale ,mRotate:$mRotate, "
            "x:$motionEventX, y:$motionEventY, "
            "rect:$originWholeRect, newRadius:$newRadius, oldRadius:$oldRadius");
  }

  ///包括旋转、删除按钮的最小矩形区域
  @override
  getWholeRect() {
    Rect contentDrawRect = getContentRect();
    Rect wholeRect = Rect.fromLTRB(
        contentDrawRect.left - mRedundantAreaLeftRight,
        contentDrawRect.top - mRedundantAreaLeftRight,
        contentDrawRect.right + mRedundantAreaTopBottom,
        contentDrawRect.bottom + mRedundantAreaTopBottom);
    print("getWholeRect wholeRect:$wholeRect");
    return wholeRect;
  }

  @override
  getOriginWholeRect() {
    Rect originContentRect = getOriginContentRect();
    Rect originWholeRect = Rect.fromLTRB(
        originContentRect.left - mRedundantAreaLeftRight,
        originContentRect.top - mRedundantAreaTopBottom,
        originContentRect.right + mRedundantAreaLeftRight,
        originContentRect.bottom + mRedundantAreaTopBottom);
    print("getOriginWholeRect wholeRect:$originWholeRect");
    return originWholeRect;
  }

  ///获取 元素 删除按钮在 @EditRect 坐标下的 Rect
  getRemoveButtonRect() {
    Rect wholeRect = getWholeRect();
    Rect removeButtonRect = Rect.fromLTRB(
        wholeRect.left,
        wholeRect.top,
        wholeRect.left + ELEMENT_BUTTON_WIDTH,
        wholeRect.top + ELEMENT_BUTTON_WIDTH);
    print("getRemoveButtonRect removeButtonRect:$removeButtonRect");
    return removeButtonRect;
  }

  ///获取 元素 旋转缩放按钮在 @EditRect 坐标下的 Rect
  getScaleAndRotateButtonRect() {
    Rect wholeRect = getWholeRect();
    Rect scaleAndRotateButtonRect = Rect.fromLTRB(
        wholeRect.right - ELEMENT_BUTTON_WIDTH,
        wholeRect.bottom - ELEMENT_BUTTON_WIDTH,
        wholeRect.right,
        wholeRect.bottom);
    print(
        "getScaleAndRotateButtonRect scaleAndRotateButtonRect:$scaleAndRotateButtonRect");
    return scaleAndRotateButtonRect;
  }

  isSingleFingerScaleAndRotate() {
    return mIsSingleFingerScaleAndRotate;
  }
}
