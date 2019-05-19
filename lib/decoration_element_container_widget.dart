import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sticker/decoration_element.dart';
import 'package:sticker/element_container_widget.dart';

import 'ws_element.dart';

enum DecorationActionMode {
  NONE,
  SINGER_FINGER_SCALE_AND_ROTATE,
  CLICK_BUTTON_DELETE,
}

class DecorationElementContainerWidgetState
    extends ElementContainerWidgetState {
  static const String TAG = "heshixi:DECW";

  DecorationActionMode mDecorationActionMode;

  /// 取消选中、删除
  void unSelectDeleteAndUpdateTopElement() {
    unSelectElement();
    deleteElement();
    update();
  }

  /// 添加、选中、更新
  /// [wsElement]
  void addSelectAndUpdateElement(WsElement wsElement) {
    unSelectElement();
    addElement(wsElement);
    selectElement(wsElement);
    update();
  }

  /// 按下了已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  @override
  bool downSelectTapOtherAction(PointerDownEvent event) {
    mDecorationActionMode = DecorationActionMode.NONE;
    final double x = getRelativeX(event.position.dx),
        y = getRelativeY(event.position.dy);
    DecorationElement selectedDecorationElement = mSelectedElement;
    if (selectedDecorationElement.isInScaleAndRotateButton(x, y)) {
      // 开始进行单指旋转缩放
      mDecorationActionMode =
          DecorationActionMode.SINGER_FINGER_SCALE_AND_ROTATE;
      selectedDecorationElement.onSingleFingerScaleAndRotateStart();
      callListener((elementActionListener) {
        if (elementActionListener is DecorationElementActionListener) {
          DecorationElementActionListener decorationElementActionListener = elementActionListener;
          decorationElementActionListener.onSingleFingerScaleAndRotateStart(
              selectedDecorationElement);
        } else {
          print("$TAG not a DecorationElementActionListener");
        }
      });
      print("$TAG downSelectTapOtherAction selected scale and rotate");
      return true;
    }
    if (selectedDecorationElement.isInRemoveButton(x, y)) {
      mDecorationActionMode = DecorationActionMode.CLICK_BUTTON_DELETE;
      print("$TAG downSelectTapOtherAction selected delete");
      return true;
    }
    return false;
  }

  /// 滑动已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  @override
  bool scrollSelectTapOtherAction(DragUpdateDetails dragUpdateDetails) {
    if (mSelectedElement == null) {
      print(
          "$TAG detectorSingleFingerRotateAndScale scale and rotate but not select");
      return false;
    }

    if (mDecorationActionMode == DecorationActionMode.CLICK_BUTTON_DELETE) {
      return true;
    }

    if (mDecorationActionMode ==
        DecorationActionMode.SINGER_FINGER_SCALE_AND_ROTATE) {
      DecorationElement selectedDecorationElement = mSelectedElement;
      selectedDecorationElement.onSingleFingerScaleAndRotateProcess(
          getRelativeX(dragUpdateDetails.globalPosition.dx),
          getRelativeY(dragUpdateDetails.globalPosition.dy));
      update();
      callListener((elementActionListener) {
        if (elementActionListener is DecorationElementActionListener) {
          DecorationElementActionListener decorationElementActionListener = elementActionListener;
          decorationElementActionListener.onSingleFingerScaleAndRotateProcess(
              selectedDecorationElement);
        } else {
          print("$TAG not a DecorationElementActionListener");
        }
      });
      return true;
    }

    return false;
  }

  /// 抬起已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  bool upSelectTapOtherAction(PointerUpEvent event) {
    if (mSelectedElement == null) {
      print("$TAG upSelectTapOtherAction delete but not select ");
      return false;
    }

    DecorationElement selectedDecorationElement = mSelectedElement;
    if (mDecorationActionMode == DecorationActionMode.CLICK_BUTTON_DELETE &&
        selectedDecorationElement.isInRemoveButton(
            getRelativeX(event.position.dx), getRelativeY(event.position.dy))) {
      unSelectDeleteAndUpdateTopElement();
      mDecorationActionMode = DecorationActionMode.NONE;
      print("$TAG upSelectTapOtherAction delete");
      return true;
    }

    if (mDecorationActionMode ==
        DecorationActionMode.SINGER_FINGER_SCALE_AND_ROTATE) {
      selectedDecorationElement.onSingleFingerScaleAndRotateEnd();
      mDecorationActionMode = DecorationActionMode.NONE;
      update();
      callListener((elementActionListener) {
        if (elementActionListener is DecorationElementActionListener) {
          DecorationElementActionListener decorationElementActionListener = elementActionListener;
          decorationElementActionListener.onSingleFingerScaleAndRotateEnd(
              selectedDecorationElement);
        } else {
          print("$TAG not a DecorationElementActionListener");
        }
      });
      print("$TAG upSelectTapOtherAction scale and rotate end");
      return true;
    }
    return false;
  }
}

abstract class DecorationElementActionListener extends ElementActionListener {
  /// 选中了元素之后，对元素单指缩放旋转开始的回调
  void onSingleFingerScaleAndRotateStart(DecorationElement element);

  /// 选中了元素之后，对元素单指缩放旋转过程的回调
  void onSingleFingerScaleAndRotateProcess(DecorationElement element);

  /// 一次单指 缩放旋转 结束
  void onSingleFingerScaleAndRotateEnd(DecorationElement element);
}

class DefaultDecorationElementActionListener
    extends DefaultElementActionListener
    implements DecorationElementActionListener {

  @override
  void onSingleFingerScaleAndRotateStart(DecorationElement element) {}

  @override
  void onSingleFingerScaleAndRotateProcess(DecorationElement element) {}

  @override
  void onSingleFingerScaleAndRotateEnd(DecorationElement element) {}
}
