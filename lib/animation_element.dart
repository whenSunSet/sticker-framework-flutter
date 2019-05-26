//import 'package:flutter/src/widgets/framework.dart';
//import 'package:meta/meta.dart';
//import 'package:sticker/ws_element.dart';
//import 'package:sticker/element_container_widget.dart';
//
//class AnimationElement extends WsElement {
//  static const String TAG = "heshixi:AElement";
//  static const int DEFAULT_ANIMATION_DURATION = 300; // 默认动画时间为 300 毫秒
//  TransformParam mBeforeTransformParam = TransformParam();
//  bool mIsInAnimation;
//
//  AnimationElement(double mOriginWidth, double mOriginHeight)
//      : super(mOriginWidth, mOriginHeight); // 是否处于动画中
//
//  /// 开始对 element 做动画
//  /// [to]      element 进行动画的参数
//  /// [endRun]  动画完成时的操作
//  /// [milTime] 动画进行的时间
//  void startElementAnimation(
//      {@required TransformParam to, EndRun endRun, int milTime}) {
//    mBeforeTransformParam.mRotate = mRotate;
//    mBeforeTransformParam.mScale = mScale;
//    mBeforeTransformParam.mAlpha = mAlpha;
//    mBeforeTransformParam.mMoveX = mMoveX;
//    mBeforeTransformParam.mMoveY = mMoveY;
//    mBeforeTransformParam.mEnableRotate = to.mEnableRotate;
//    mBeforeTransformParam.mEnableScale = to.mEnableScale;
//    mBeforeTransformParam.mEnableAlpha = to.mEnableAlpha;
//    mBeforeTransformParam.mEnableMoveX = to.mEnableMoveX;
//    mBeforeTransformParam.mEnableMoveY = to.mEnableMoveY;
//    mBeforeTransformParam.mIsNeedLimitXY = to.mIsNeedLimitXY;
//    mBeforeTransformParam.mIsNeedLimitScale = to.mIsNeedLimitScale;
//    startViewAnimation(to, endRun, milTime);
//  }
//
//  void restoreToBeforeAnimation({EndRun endRun, int milTime}) {
//    startViewAnimation(mBeforeTransformParam, endRun, milTime);
//  }
//
//  /**
//   * 开始对传入的 view 做动画，这里做动画的参数为 scale、translation 等等
//   *
//   * @param to            element 进行动画的参数
//   * @param endRun        动画完成时的操作
//   * @param milTime       动画进行的时间
//   * @param animationView 需要进行动画的 view
//   */
//  void startViewAnimation(TransformParam to, EndRun endRun, int milTime) {
//    if (to == null) {
//      print("$TAG startElementAnimation error to is null");
//      return;
//    }
//
//    AnimatorSet elementAnimator = new AnimatorSet();
//    List<Animator> animatorList = new ArrayList<>();
//    if (to.mEnableRotate) {
//      ObjectAnimator rotationAnimator = ObjectAnimator
//          .ofdouble(animationView, "rotation", mRotate, to.mRotate);
//      animatorList.add(rotationAnimator);
//    }
//
//    if (to.mEnableScale) {
//      ObjectAnimator scaleXAnimator = ObjectAnimator
//          .ofdouble(animationView, "scaleX", mScale, to.mScale);
//      animatorList.add(scaleXAnimator);
//    }
//
//    if (to.mEnableScale) {
//      ObjectAnimator scaleYAnimator = ObjectAnimator
//          .ofdouble(animationView, "scaleY", mScale, to.mScale);
//      animatorList.add(scaleYAnimator);
//    }
//
//    if (to.mEnableAlpha) {
//      ObjectAnimator alphaYAnimator = ObjectAnimator
//          .ofdouble(animationView, "alpha", mAlpha, to.mAlpha);
//      animatorList.add(alphaYAnimator);
//    }
//
//    if (to.mEnableMoveX) {
//      ObjectAnimator translateXAnimator =
//      ObjectAnimator.ofdouble(
//          animationView, "translationX", getRealX(mMoveX, animationView),
//          getRealX(to.mMoveX, animationView));
//      animatorList.add(translateXAnimator);
//    }
//
//    if (to.mEnableMoveY) {
//      ObjectAnimator translateYAnimator = ObjectAnimator
//          .ofdouble(
//          animationView, "translationY", getRealY(mMoveY, animationView),
//          getRealY(to.mMoveY, animationView));
//      animatorList.add(translateYAnimator);
//    }
//
//    elementAnimator.playTogether(animatorList);
//    elementAnimator.setDuration(milTime);
//    elementAnimator.setInterpolator(new CubicEaseOutInterpolator());
//    elementAnimator.addListener(new AnimatorListenerAdapter() {
//    @Override
//    void onAnimationCancel(Animator animation) {
//    super.onAnimationCancel(animation);
//    animationEnd(endRun, to, animationView);
//    }
//
//    @Override
//    void onAnimationEnd(Animator animation) {
//    super.onAnimationEnd(animation);
//    animationEnd(endRun, to, animationView);
//    }
//    });
//    elementAnimator.start();
//    mIsInAnimation = true;
//    print("$TAG startElementAnimation to:$to");
//  }
//
//  void animationEnd(EndRun endRun, TransformParam to) {
//    if (endRun != null) {
//      endRun();
//    }
//    mRotate = to.mEnableRotate ? to.mRotate : mRotate;
//    mScale = to.mEnableScale ? to.mScale : mScale;
//    mAlpha = to.mEnableAlpha ? to.mAlpha : mAlpha;
//    mMoveX = to.mEnableMoveX ? to.mMoveX : mMoveX;
//    mMoveY = to.mEnableMoveY ? to.mMoveY : mMoveY;
//
//    mIsInAnimation = false;
//  }
//
//  bool isInAnimation() {
//    return mIsInAnimation;
//  }
//
//  TransformParam getBeforeTransformParam() {
//    return mBeforeTransformParam;
//  }
//
//  @override
//  Widget initWidget() {
//    // TODO: implement initWidget
//    return null;
//  }
//}
//
//class TransformParam {
//  double mRotate = 0; // 图像顺时针旋转的角度
//
//  double mScale = 1.0; // 图像缩放的大小
//
//  double mAlpha = 1.0; // 图像的透明度
//
//  double mMoveX = 0; // 初始化后相对 mElementContainerView 中心 的移动距离
//
//  double mMoveY = 0; // 初始化后相对 mElementContainerView 中心 的移动距离
//
//  bool mEnableRotate = true;
//
//  bool mEnableScale = true;
//
//  bool mEnableAlpha = true;
//
//  bool mEnableMoveX = true;
//
//  bool mEnableMoveY = true;
//
//  bool mIsNeedLimitXY = true; // 是否需要限制 mMoveX、mMoveY
//
//  bool mIsNeedLimitScale = true; // 是否需要限制 scale
//
//  TransformParam();
//
//  TransformParam.fromElement(WsElement element) {
//    if (element == null) {
//      return;
//    }
//
//    mRotate = element.mRotate;
//    mScale = element.mScale;
//    mAlpha = element.mAlpha;
//    mMoveX = element.mMoveX;
//    mMoveY = element.mMoveY;
//  }
//
//  TransformParam.copy(TransformParam transformParam) {
//    if (transformParam == null) {
//      return;
//    }
//
//    mRotate = transformParam.mRotate;
//    mScale = transformParam.mScale;
//    mAlpha = transformParam.mAlpha;
//    mMoveX = transformParam.mMoveX;
//    mMoveY = transformParam.mMoveY;
//    mEnableRotate = transformParam.mEnableRotate;
//    mEnableScale = transformParam.mEnableRotate;
//    mEnableAlpha = transformParam.mEnableAlpha;
//    mEnableMoveX = transformParam.mEnableMoveX;
//    mEnableMoveY = transformParam.mEnableMoveY;
//    mIsNeedLimitXY = transformParam.mIsNeedLimitXY;
//    mIsNeedLimitScale = transformParam.mIsNeedLimitScale;
//  }
//
//  @override
//  String toString() {
//    return 'TransformParam{'
//        'mRotate: $mRotate, '
//        'mScale: $mScale, '
//        'mAlpha: $mAlpha, '
//        'mMoveX: $mMoveX, '
//        'mMoveY: $mMoveY, '
//        'mEnableRotate: $mEnableRotate, '
//        'mEnableScale: $mEnableScale, '
//        'mEnableAlpha: $mEnableAlpha, '
//        'mEnableMoveX: $mEnableMoveX, '
//        'mEnableMoveY: $mEnableMoveY, '
//        'mIsNeedLimitXY: $mIsNeedLimitXY, '
//        'mIsNeedLimitScale: $mIsNeedLimitScale}';
//  }
//}