import 'package:flutter/material.dart';
import 'package:sticker/decoration_element_container_widget.dart';

class RuleLineElementContainerState
    extends DecorationElementContainerWidgetState {
  static const String TAG = "heshixi:RLECV";
  static const double IS_CHECK_X_RULE_THRESHOLD =
  2.0; // 在 x 轴移动元素 deltaX 低于阈值的时候进行移动规则监测
  static const double IS_CHECK_Y_RULE_THRESHOLD =
  2.0; // 在 y 轴移动元素 deltaY 低于阈值的时候进行移动规则监测
  static const double CHECK_X_IS_IN_RULE_THRESHOLD = 2; // 检测元素的 x 是否在规则中的阈值
  static const double CHECK_Y_IS_IN_RULE_THRESHOLD = 2; // 检测元素的 y 是否在规则中的阈值
  // 某次 x 轴移动规则累计吸收的 x 轴移动距离的最大值
  static const double X_RULE_TOTAL_ABSORPTION_MAX = 30;

  // 某次 y 轴移动规则累计吸收的 y 轴移动距离的最大值
  static const double Y_RULE_TOTAL_ABSORPTION_MAX = 30;
  static const double VIBRATOR_DURATION_IN_RULE = 10; // 进入规则时的震动的时长
  static const double NOT_IN_RULE = -1; // 当前元素不处于任何规则中
  // x 轴上的规则监测点，单位为 view 的百分比
  static const List<double> X_RULES = [0.05, 0.5, 0.95];

  // y 轴上的规则监测点，单位为 view 的百分比
  static const List<double> Y_RULES = [0.10, 0.5, 0.90];

  List<RuleLine> mRuleLines = [RuleLine(), RuleLine()];
  double mXRuleTotalAbsorption = 0; // 某次 x 轴移动规则累计吸收的 x 轴移动距离
  double mYRuleTotalAbsorption = 0; // 某次 y 轴移动规则累计吸收的 y 轴移动距离
  List<Rect> mNoRuleRectList = []; // 不在规则范围内的 Rect 列表
  bool mIsShowRuleLine = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [];
    childs.add(super.build(context));
    if (mIsShowRuleLine) {
      childs.add(CustomPaint(
        size: Size(mEditRect.width, mEditRect.height),
        painter: RuleLineWidget(mRuleLines),
      ));
    }
    return Stack(
      children: childs,
    );
  }

  @override
  bool scrollSelectTapOtherAction(List<DragUpdateDetails> distance) {
    print("$TAG scrollSelectTapOtherAction distance:$distance");
    if (mSelectedElement == null) {
      print("$TAG scrollSelectTapOtherAction mSelectedElement is null");
      return super.scrollSelectTapOtherAction(distance);
    }
    double newDeltaX = distance[0].delta.dx;
    double newDeltaY = distance[0].delta.dy;
    bool xCanCheckRule = (abs(newDeltaX) <= IS_CHECK_X_RULE_THRESHOLD);
    bool yCanCheckRule = (abs(newDeltaY) <= IS_CHECK_Y_RULE_THRESHOLD);
    bool xInRule = false;
    bool yInRule = false;

    double xRulePercent = 0;
    if (xCanCheckRule) {
      xRulePercent = checkElementInXRule(distance[0]);
      xInRule = (xRulePercent != NOT_IN_RULE);
      if (xInRule) {
        RuleLine xRuleLine = new RuleLine();
        xRuleLine.mStartPoint = Offset(xRulePercent * mEditRect.width, 0);
        xRuleLine.mEndPoint =
            Offset(xRulePercent * mEditRect.width, mEditRect.height);
        mRuleLines[0] = xRuleLine;

        if (mXRuleTotalAbsorption == 0 && newDeltaX != 0) {
          // todo 震动需要使用 native
//          mVibrator.vibrate(VIBRATOR_DURATION_IN_RULE);
          print("$TAG scrollSelectTapOtherAction x vibrate");
        }
        mXRuleTotalAbsorption += newDeltaX;
        if (abs(mXRuleTotalAbsorption) >= X_RULE_TOTAL_ABSORPTION_MAX) {
          print(
              "$TAG scrollSelectTapOtherAction clear mXRuleTotalAbsorption:$mXRuleTotalAbsorption");
          mXRuleTotalAbsorption = 0;
          newDeltaX += (newDeltaX < 0 ? -2 * CHECK_X_IS_IN_RULE_THRESHOLD : 2 *
              CHECK_X_IS_IN_RULE_THRESHOLD);
        } else {
          newDeltaX = 0;
          print(
              "$TAG scrollSelectTapOtherAction add mXRuleTotalAbsorption |||||||||| mXRuleTotalAbsorption:$mXRuleTotalAbsorption");
        }
      } else {
        mRuleLines[0] = null;
      }
    } else {
      mRuleLines[0] = null;
      mXRuleTotalAbsorption = 0;
    }

    double yRulePercent = 0;
    if (yCanCheckRule) {
      yRulePercent = checkElementInYRule(distance[0]);
      yInRule = (yRulePercent != NOT_IN_RULE);
      if (yInRule) {
        RuleLine yRuleLine = new RuleLine();
        yRuleLine.mStartPoint = Offset(0, yRulePercent * mEditRect.height);
        yRuleLine.mEndPoint =
            Offset(mEditRect.width, yRulePercent * mEditRect.height);
        mRuleLines[1] = yRuleLine;

        if (mYRuleTotalAbsorption == 0 && newDeltaY != 0) {
          // todo 震动需要使用 native
//          mVibrator.vibrate(VIBRATOR_DURATION_IN_RULE);
          print("$TAG scrollSelectTapOtherAction y vibrate");
        }
        mYRuleTotalAbsorption += newDeltaY;
        if (abs(mYRuleTotalAbsorption) >= Y_RULE_TOTAL_ABSORPTION_MAX) {
          print(
              "$TAG scrollSelectTapOtherAction clear mYRuleTotalAbsorption:$mYRuleTotalAbsorption");
          mYRuleTotalAbsorption = 0;
          newDeltaY += (newDeltaY < 0 ? -2 * CHECK_Y_IS_IN_RULE_THRESHOLD : 2 *
              CHECK_Y_IS_IN_RULE_THRESHOLD);
        } else {
          newDeltaY = 0;
          print(
              "$TAG scrollSelectTapOtherAction add mYRuleTotalAbsorption |||||||||| mYRuleTotalAbsorption:$mYRuleTotalAbsorption");
        }
      } else {
        mRuleLines[1] = null;
      }
    } else {
      mRuleLines[1] = null;
      mYRuleTotalAbsorption = 0;
    }

    if ((xCanCheckRule && xInRule) || (yCanCheckRule && yInRule)) {
      mIsShowRuleLine = true;
      setState(() {});
    } else {
      mIsShowRuleLine = false;
      setState(() {});
    }
    DragUpdateDetails dragUpdateDetails = DragUpdateDetails(
        sourceTimeStamp: distance[0].sourceTimeStamp,
        delta: Offset(newDeltaX, newDeltaY),
        primaryDelta: distance[0].primaryDelta,
        globalPosition: distance[0].globalPosition);
    distance[0] = dragUpdateDetails;
    print("$TAG scrollSelectTapOtherAction d:$dragUpdateDetails");
    return super.scrollSelectTapOtherAction(distance);
  }

  @override
  bool upSelectTapOtherAction(PointerUpEvent event) {
    mIsShowRuleLine = false;
    setState(() {});
    return super.upSelectTapOtherAction(event);
  }

  /**
   * 检查当前元素是否处于哪条规则中view 中心的时候可以进行提醒
   *
   * @return 返回当前元素处于哪条规则中
   */
  double checkElementInXRule(DragUpdateDetails distance) {
    if (mSelectedElement == null) {
      print("$TAG checkElementInXRule mSelectedElement is null");
      return NOT_IN_RULE;
    }

    if (!mSelectedElement.mIsSingeFingerMove) {
      return NOT_IN_RULE;
    }

    double elementCenterX = mSelectedElement
        .getContentRect()
        .center
        .dx;
    double elementCenterY = mSelectedElement
        .getContentRect()
        .center
        .dy;
    for (int i = 0; i < mNoRuleRectList.length; i++) {
      if (mNoRuleRectList[i].contains(Offset(elementCenterX, elementCenterY))) {
        return NOT_IN_RULE;
      }
    }

    double viewCenterX = mEditRect.width * X_RULES[1];
    if (abs(viewCenterX - elementCenterX) < CHECK_X_IS_IN_RULE_THRESHOLD) {
      return X_RULES[1];
    }

    double elementLeft = mSelectedElement
        .getContentRect()
        .left;
    double viewLeft = mEditRect.width * X_RULES[0];
    if (abs(viewLeft - elementLeft) < CHECK_X_IS_IN_RULE_THRESHOLD) {
      return X_RULES[0];
    }

    double elementRight = mSelectedElement
        .getContentRect()
        .right;
    double viewRight = mEditRect.width * X_RULES[2];
    if (abs(viewRight - elementRight) < CHECK_X_IS_IN_RULE_THRESHOLD) {
      return X_RULES[2];
    }

    return NOT_IN_RULE;
  }

  /**
   * 同 checkElementInXRule
   */
  double checkElementInYRule(DragUpdateDetails distance) {
    if (mSelectedElement == null) {
      print("$TAG checkElementInYRule mSelectedElement is null");
      return NOT_IN_RULE;
    }

    if (!mSelectedElement.mIsSingeFingerMove) {
      return NOT_IN_RULE;
    }

    double elementCenterX = mSelectedElement
        .getContentRect()
        .center
        .dx;
    double elementCenterY = mSelectedElement
        .getContentRect()
        .center
        .dy;
    for (int i = 0; i < mNoRuleRectList.length; i++) {
      if (mNoRuleRectList[i].contains(Offset(elementCenterX, elementCenterY))) {
        return NOT_IN_RULE;
      }
    }

    double viewCenterY = mEditRect.height * Y_RULES[1];
    if (abs(viewCenterY - elementCenterY) < CHECK_Y_IS_IN_RULE_THRESHOLD) {
      return Y_RULES[1];
    }

    double elementTop = mSelectedElement
        .getContentRect()
        .top;
    double viewTop = mEditRect.height * Y_RULES[0];
    if (abs(viewTop - elementTop) < CHECK_Y_IS_IN_RULE_THRESHOLD) {
      return Y_RULES[0];
    }

    double elementBottom = mSelectedElement
        .getContentRect()
        .bottom;
    double viewBottom = mEditRect.height * Y_RULES[2];
    if (abs(viewBottom - elementBottom) < CHECK_Y_IS_IN_RULE_THRESHOLD) {
      return Y_RULES[2];
    }
    return NOT_IN_RULE;
  }
}

double abs(double num) {
  if (num < 0) {
    return -1 * num;
  } else {
    return num;
  }
}

class RuleLine {
  Offset mStartPoint;
  Offset mEndPoint;

  @override
  String toString() {
    return 'RuleLine{mStartPoint: $mStartPoint, mEndPoint: $mEndPoint}';
  }
}

class RuleLineWidget extends CustomPainter {
  static const String TAG = "heshixi:RuleLineView";
  static const double LINE_WIDTH = 2; // 线的宽度，单位为 px
  static Paint sLinePaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = LINE_WIDTH
    ..style = PaintingStyle.stroke
    ..color = Color(0XFF33B5E5);

  List<RuleLine> _mRuleLines;

  RuleLineWidget(this._mRuleLines);

  @override
  void paint(Canvas canvas, Size size) {
    if (_mRuleLines == null || _mRuleLines.length <= 0) {
      print("$TAG onDraw no rule line");
      return;
    }

    for (int i = 0; i < _mRuleLines.length; i++) {
      if (_mRuleLines[i] == null ||
          _mRuleLines[i].mStartPoint == null ||
          _mRuleLines[i].mEndPoint == null) {
        print("$TAG onDraw start or end point is null");
        continue;
      }
      canvas.drawLine(
          _mRuleLines[i].mStartPoint, _mRuleLines[i].mEndPoint, sLinePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  set mRuleLines(List<RuleLine> value) {
    _mRuleLines = value;
  }
}
