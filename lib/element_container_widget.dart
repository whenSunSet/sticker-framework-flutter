import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sticker/rotate_scale_gesture_recognizer.dart';

import 'ws_element.dart';

enum BaseActionMode {
  MOVE,
  SELECT,
  SELECTED_CLICK_OR_MOVE,
  SINGLE_TAP_BLANK_SCREEN,
  DOUBLE_FINGER_SCALE_AND_ROTATE,
}

class ElementContainerWidget extends StatefulWidget {
  final ElementContainerWidgetState elementContainerWidgetState;

  ElementContainerWidget(this.elementContainerWidgetState);

  @override
  State<StatefulWidget> createState() {
    return elementContainerWidgetState;
  }
}

class ElementContainerWidgetState extends State<ElementContainerWidget> {
  static const String TAG = "ElementContainerWidgetState";
  final GlobalKey globalKey = GlobalKey();
  List<WsElement> mElementList = []; // 元素列表
  Set<ElementActionListener> mElementActionListenerSet = {}; // 监听列表
  WsElement mSelectedElement; // 当前选中的 元素
  BaseActionMode mMode = BaseActionMode.SELECTED_CLICK_OR_MOVE; // 当前手势所处的模式
  Rect mEditRect; // 当前 widget 的区域
  Offset mOffset; // 当前 widget 与屏幕左上角位置偏移
  bool mIsNeedAutoUnSelect = true; // 是否需要自动取消选中
  int mAutoUnSelectDuration = 2000; // 自动取消选中的时间，默认 2000 毫秒，

  @override
  initState() {
    super.initState();

    print("initState rect:$mEditRect");
  }

  @override
  Widget build(BuildContext context) {
    RawGestureDetector gestureDetectorTwo = GestureDetector(
      child: GestureDetector(
        child: Stack(
            alignment: AlignmentDirectional.center,
            key: globalKey,
            children: mElementList.map((e) {
              return e.buildTransform();
            })
                .toList()
                .reversed
                .toList()
        ),
        onPanUpdate: onMove,
        behavior: HitTestBehavior.opaque,
      ),
    ).build(context);
    gestureDetectorTwo.gestures[RotateScaleGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<RotateScaleGestureRecognizer>(
              () => RotateScaleGestureRecognizer(debugOwner: this),
              (RotateScaleGestureRecognizer instance) {
            instance
              ..onStart = onDoubleFingerScaleAndRotateStart
              ..onUpdate = onDoubleFingerScaleAndRotateProcess
              ..onEnd = onDoubleFingerScaleAndRotateEnd;
          },
        );
    return Listener(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: double.infinity,
          minWidth: double.infinity,
        ),
        child: gestureDetectorTwo,
      ),
      behavior: HitTestBehavior.opaque,
      onPointerDown: onDown,
      onPointerUp: onUp,
    );
  }

  onDown(PointerDownEvent event) {
    cancelAutoUnSelect();
    final x = getRelativeX(event.position.dx),
        y = getRelativeY(event.position.dy);
    mMode = BaseActionMode.SELECTED_CLICK_OR_MOVE;
    WsElement clickedElement = findElementByPosition(x, y);

    print(
        "$TAG onDown |||||||||| x:$x,y:$y,clickedElement:$clickedElement,mSelectedElement:$mSelectedElement");
    if (mSelectedElement != null) {
      if (isSameElement(clickedElement, mSelectedElement)) {
        bool result = downSelectTapOtherAction(event);
        if (result) {
          print("$TAG onDown other action");
          return;
        }
        if (mSelectedElement.isInWholeDecoration(x, y)) {
          mMode = BaseActionMode.SELECTED_CLICK_OR_MOVE;
          print("$TAG onDown SELECTED_CLICK_OR_MOVE");
          return;
        }
        print("$TAG onDown error not action");
      } else {
        if (clickedElement == null) {
          mMode = BaseActionMode.SINGLE_TAP_BLANK_SCREEN;
          print("$TAG onDown SINGLE_TAP_BLANK_SCREEN");
        } else {
          mMode = BaseActionMode.SELECT;
          unSelectElement();
          selectElement(clickedElement);
          update();
          print("$TAG onDown unSelect old element, select new element");
        }
      }
    } else {
      if (clickedElement != null) {
        mMode = BaseActionMode.SELECT;
        selectElement(clickedElement);
        update();
        print("$TAG onDown select new element");
      } else {
        mMode = BaseActionMode.SINGLE_TAP_BLANK_SCREEN;
        print("$TAG onDown SINGLE_TAP_BLANK_SCREEN");
      }
    }
  }

  onMove(DragUpdateDetails dragUpdateDetails) {
    List<DragUpdateDetails> dragUpdateDetailList = [dragUpdateDetails];
    if (scrollSelectTapOtherAction(dragUpdateDetailList)) {
      return;
    } else {
      if (mMode == BaseActionMode.SELECTED_CLICK_OR_MOVE
          || mMode == BaseActionMode.SELECT
          || mMode == BaseActionMode.MOVE) {
        if (mMode == BaseActionMode.SELECTED_CLICK_OR_MOVE ||
            mMode == BaseActionMode.SELECT) {
          onSingleFingerMoveStart(dragUpdateDetailList[0]);
        } else {
          onSingleFingerMoveProcess(dragUpdateDetailList[0]);
        }
        update();
        mMode = BaseActionMode.MOVE;
      }
    }
  }

  onSingleFingerMoveStart(DragUpdateDetails d) {
    mSelectedElement.onSingleFingerMoveStart();
    update();
    callListener((elementActionListener) {
      elementActionListener.onSingleFingerMoveStart(mSelectedElement);
    });
  }

  onSingleFingerMoveProcess(DragUpdateDetails d) {
    mSelectedElement.onSingleFingerMoveProcess(d);
    update();
    callListener((elementActionListener) {
      elementActionListener.onSingleFingerMoveProcess(mSelectedElement);
    });
  }

  onSingleFingerMoveEnd() {
    mSelectedElement.onSingleFingerMoveEnd();
    update();
    callListener((elementActionListener) {
      elementActionListener.onSingleFingerMoveEnd(mSelectedElement);
    });
  }

  onDoubleFingerScaleAndRotateStart(RotateScaleStartDetails s) {
    mSelectedElement.onDoubleFingerScaleAndRotateStart(s);
    update();
    callListener((elementActionListener) {
      elementActionListener.onDoubleFingerScaleAndRotateStart(mSelectedElement);
    });
  }

  onDoubleFingerScaleAndRotateProcess(RotateScaleUpdateDetails s) {
    mSelectedElement.onDoubleFingerScaleAndRotateProcess(s);
    update();
    callListener((elementActionListener) {
      elementActionListener.onDoubleFingerScaleAndRotateProcess(
          mSelectedElement);
    });
  }

  onDoubleFingerScaleAndRotateEnd(RotateScaleEndDetails s) {
    mSelectedElement.onDoubleFingerScaleAndRotateEnd(s);
    update();
    autoUnSelect();
    callListener((elementActionListener) {
      elementActionListener.onDoubleFingerScaleRotateEnd(mSelectedElement);
    });
  }

  onUp(PointerUpEvent event) {
    autoUnSelect();
    print("$TAG singleFingerUp |||||||||| position:${event.position}");
    if (!upSelectTapOtherAction(event)) {
      switch (mMode) {
        case BaseActionMode.SELECTED_CLICK_OR_MOVE:
          selectedClick(event);
          update();
          return;
        case BaseActionMode.SINGLE_TAP_BLANK_SCREEN:
          onClickBlank(event);
          return;
        case BaseActionMode.MOVE:
          onSingleFingerMoveEnd();
          return;
        default:
          print("$TAG singleFingerUp other action");
      }
    }
  }

  /// 添加一个元素，如果元素已经存在，那么就会添加失败
  /// [wsElement] 被添加的元素
  bool addElement(WsElement wsElement) {
    if (mEditRect == null || mEditRect.width == 0 || mEditRect.height == 0) {
      mEditRect = Rect.fromLTRB(0, 0, globalKey.currentContext.size.width,
          globalKey.currentContext.size.height);
      RenderBox renderBox = globalKey.currentContext.findRenderObject();
      mOffset = renderBox.localToGlobal(Offset.zero);
      print("addElement init mEditRect:$mEditRect, offset:$mOffset");
    }
    if (wsElement == null) {
      print("$TAG addElement element is null");
      return false;
    }

    if (mElementList.contains(wsElement)) {
      print("$TAG addElement element is added");
      return false;
    }

    for (int i = 0; i < mElementList.length; i++) {
      WsElement nowElement = mElementList[i];
      nowElement.mZIndex++;
    }
    wsElement.mZIndex = 0;
    wsElement.mEditRect = mEditRect;
    wsElement.mOffset = mOffset;
    if (mElementList.length == 0) {
      mElementList.add(wsElement);
    } else {
      mElementList.insert(0, wsElement);
    }
    wsElement.add();
    callListener((elementActionListener) {
      elementActionListener.onAdd(mSelectedElement);
    });
    autoUnSelect();
    return true;
  }

  /// 删除一个元素，只能删除当前最顶层的元素
  /// [wsElement] 被删除的元素
  bool deleteElement([WsElement wsElement]) {
    if (wsElement == null) {
      if (mElementList.length <= 0) {
        return false;
      }
      wsElement = mElementList.first;
    }

    if (mElementList.first != wsElement) {
      print("$TAG deleteElement element is not in top");
      return false;
    }

    mElementList.remove(wsElement);
    for (int i = 0; i < mElementList.length; i++) {
      WsElement nowElement = mElementList[i];
      nowElement.mZIndex--;
    }
    wsElement.delete();
    callListener((elementActionListener) {
      elementActionListener.onDelete(mSelectedElement);
    });
    return true;
  }

  /// 更新界面
  update() {
    setState(() {
      if (mSelectedElement != null) {
        mSelectedElement.update();
      }
    });
  }

  /// 选中一个元素，如果需要选中的元素没有被添加到 container 中则选中失败
  /// [wsElement] 被选中的元素
  bool selectElement(WsElement wsElement) {
    print("$TAG selectElement |||||||||| element:$wsElement");
    if (wsElement == null) {
      print("$TAG selectElement element is null");
      return false;
    }

    if (!mElementList.contains(wsElement)) {
      print("$TAG selectElement element was not added");
      return false;
    }

    for (int i = 0; i < mElementList.length; i++) {
      WsElement nowElement = mElementList[i];
      if (!identical(nowElement, wsElement)
          && wsElement.mZIndex > nowElement.mZIndex) {
        nowElement.mZIndex++;
      }
    }
    mElementList.remove(wsElement);
    wsElement.select();
    if (mElementList.length == 0) {
      mElementList.add(wsElement);
    } else {
      mElementList.insert(0, wsElement);
    }
    mSelectedElement = wsElement;
    callListener((elementActionListener) {
      elementActionListener.onSelect(mSelectedElement);
    });
    return true;
  }

  /// 取消选中当前元素
  bool unSelectElement() {
    print("$TAG unSelectElement |||||||||| mSelectedElement:$mSelectedElement");
    if (mSelectedElement == null) {
      print("$TAG unSelectElement unSelect element is null");
      return false;
    }

    if (!mElementList.contains(mSelectedElement)) {
      print("$TAG unSelectElement unSelect elemnt not in container");
      return false;
    }

    mSelectedElement.unSelect();
    mSelectedElement = null;
    callListener((elementActionListener) {
      elementActionListener.onUnSelect(mSelectedElement);
    });
    return true;
  }

  /// 根据位置找到 元素
  /// [x] container widget 中的坐标
  /// [y] container widget 中的坐标
  WsElement findElementByPosition(double x, double y) {
    WsElement realFoundedElement;
    for (int i = mElementList.length - 1; i >= 0; i--) {
      WsElement nowElement = mElementList[i];
      if (nowElement.isInWholeDecoration(x, y)) {
        realFoundedElement = nowElement;
      }
    }
    print(
        "$TAG findElementByPosition |||||||||| realFoundedElement:$realFoundedElement,x:$x,y:$y");
    return realFoundedElement;
  }

  /// 选中之后再次点击选中的元素
  selectedClick(PointerUpEvent event) {
    callListener((elementActionListener) {
      elementActionListener.onSelectedClick(mSelectedElement);
    });
  }

  /// 点击空白区域
  onClickBlank(PointerUpEvent event) {
    callListener((elementActionListener) {
      elementActionListener.onSingleTapBlankScreen(mSelectedElement);
    });
  }

  /// 按下了已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  bool downSelectTapOtherAction(PointerDownEvent event) {
    return false;
  }

  /// 滑动已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  bool scrollSelectTapOtherAction(List<DragUpdateDetails> d) {
    return false;
  }

  /// 抬起已经选中的元素，如果子类中有操作的话可以给它，优先级最高
  bool upSelectTapOtherAction(PointerUpEvent event) {
    return false;
  }

  double getRelativeX(double screenX) {
    if (mOffset == null) {
      return screenX;
    }
    return screenX - mOffset.dx;
  }

  double getRelativeY(double screenY) {
    if (mOffset == null) {
      return screenY;
    }
    return screenY - mOffset.dy;
  }

  StreamSubscription autoUnSelectFuture;

  /// 一定的时间之后自动取消当前元素的选中
  autoUnSelect() {
    if (mIsNeedAutoUnSelect) {
      cancelAutoUnSelect();
      autoUnSelectFuture =
          Future.delayed(Duration(milliseconds: mAutoUnSelectDuration))
              .asStream().listen((a) {
            unSelectElement();
            update();
            print("autoUnSelect unselect");
          });
      print("autoUnSelect");
    }
  }

  /// 取消自动取消选中
  cancelAutoUnSelect() {
    print("cancelAutoUnSelect");
    if (mIsNeedAutoUnSelect && autoUnSelectFuture != null) {
      autoUnSelectFuture.cancel();
      autoUnSelectFuture = null;
      print("cancelAutoUnSelect cancel");
    }
  }

  /// 是否需要自动取消选中
  setNeedAutoUnSelect(bool needAutoUnSelect) {
    mIsNeedAutoUnSelect = needAutoUnSelect;
  }

  /// 添加一个监听器
  void addElementActionListener(ElementActionListener elementActionListener) {
    if (elementActionListener == null) {
      return;
    }
    mElementActionListenerSet.add(elementActionListener);
  }

  /// 移除一个监听器
  void removeElementActionListener(
      ElementActionListener elementActionListener) {
    mElementActionListenerSet.remove(elementActionListener);
  }

  void callListener(
      Consumer<ElementActionListener> decorationActionListenerConsumer) {
    mElementActionListenerSet.map((elementActionListener) {
      decorationActionListenerConsumer(elementActionListener);
    });
  }
}

typedef Consumer<T> = void Function(T t);

abstract class ElementActionListener {

  /// 增加了一个元素之后的回调
  void onAdd(WsElement element);

  /// 删除了一个元素之后的回调
  void onDelete(WsElement element);

  /// 选中了一个元素之后再次点击该元素触发的事件
  void onSelectedClick(WsElement element);

  /// 选中了元素之后，对元素单指移动开始的回调
  void onSingleFingerMoveStart(WsElement element);

  /// 选中了元素之后，对元素单指移动过程的回调
  void onSingleFingerMoveProcess(WsElement element);

  /// 一次 单指移动操作结束的回调
  void onSingleFingerMoveEnd(WsElement element);

  /// 选中了元素之后，对元素双指旋转缩放开始的回调
  void onDoubleFingerScaleAndRotateStart(WsElement element);

  /// 选中了元素之后，对元素双指旋转缩放过程的回调
  void onDoubleFingerScaleAndRotateProcess(WsElement element);

  /// 一次 双指旋转、缩放 操作结束的回调
  void onDoubleFingerScaleRotateEnd(WsElement element);

  /// 选中元素
  void onSelect(WsElement element);

  /// 取消选中元素
  void onUnSelect(WsElement element);

  // 点击空白区域
  void onSingleTapBlankScreen(WsElement element);
}

class DefaultElementActionListener implements ElementActionListener {

  @override
  void onAdd(WsElement element) {}

  @override
  void onDelete(WsElement element) {}

  @override
  void onSelectedClick(WsElement element) {}

  @override
  void onSingleFingerMoveStart(WsElement element) {}

  @override
  void onSingleFingerMoveProcess(WsElement element) {}

  @override
  void onSelect(WsElement element) {}

  @override
  void onUnSelect(WsElement element) {}

  @override
  void onSingleFingerMoveEnd(WsElement element) {}

  @override
  void onDoubleFingerScaleAndRotateStart(WsElement element) {}

  @override
  void onDoubleFingerScaleAndRotateProcess(WsElement element) {}

  @override
  void onDoubleFingerScaleRotateEnd(WsElement element) {}

  @override
  void onSingleTapBlankScreen(WsElement element) {}
}
