// ignore_for_file: invalid_use_of_protected_member, must_be_immutable

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LrcWidget extends SingleChildRenderObjectWidget {
  LrcWidget({
    super.key,
    required this.rects,
    required this.textPainter,
    super.child,
  });

  List<Rect> rects;
  final TextPainter textPainter;
  @override
  LrcRenderObject createRenderObject(BuildContext context) {
    return LrcRenderObject(rects: rects, textPainter: textPainter);
  }

  @override
  updateRenderObject(BuildContext context, LrcRenderObject renderObject) {
    renderObject.rects = rects;
  }

  @override
  void didUnmountRenderObject(LrcRenderObject renderObject) {
    renderObject.rects = null;
  }
}

class LrcRenderObject extends RenderProxyBox {
  LrcRenderObject({
    required List<Rect> rects,
    required this.textPainter,
  })  : _rects = rects,
        super(null);
  final ui.Paint _paint = ui.Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.clear;
  List<Rect>? get rects => _rects;
  List<Rect>? _rects;
  final TextPainter textPainter;
  set rects(List<Rect>? value) {
    if (_rects == value) {
      return;
    }
    _rects = value;
    // print('object-----------rects $_rects');
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = textPainter.size;
  }

  @override
  BackdropFilterLayer? get layer => super.layer as BackdropFilterLayer?;

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    layer ??= BackdropFilterLayer();
    layer!.filter = ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4);
    _paintWithPainter(context.canvas, offset);
    pushLayer(context, layer!, super.paint, offset,
        childPaintBounds:
            Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
  }

  _paintWithPainter(Canvas canvas, Offset offset) {
    Rect rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    // print(rect);
    // 限制绘制区域
    canvas.clipRect(rect);
    textPainter.paint(canvas, offset);
  }

  void pushLayer(PaintingContext context, ContainerLayer childLayer,
      PaintingContextCallback painter, Offset offset,
      {Rect? childPaintBounds}) {
    if (childLayer.hasChildren) {
      childLayer.removeAllChildren();
    }
    context.stopRecordingIfNeeded();
    final PaintingContext childContext = context.createChildContext(
        childLayer, childPaintBounds ?? context.estimatedBounds);
    context.appendLayer(childLayer);
    // print('estimatedBounds= ${childContext.estimatedBounds} ${_rects}');
    final Canvas canvas = childContext.canvas;
    canvas.translate(offset.dx, offset.dy);
    if (_rects != null) {
      for (Rect element in _rects!) {
        canvas.drawRect(element, _paint);
        // print(element);
        // canvas.drawRect(Rect.fromLTRB(270.0, 0.0, 570.0, 42.0), _paint);
      }
    }

    // canvas.drawCircle(Offset(400, 400), 10, _paint..color = Colors.red);
    // canvas.drawRect(Rect.fromCircle(center: Offset(200, 400), radius: 30),
    //     _paint..color = Colors.blue);

    // painter(childContext, offset);
    // super.paint(childContext, offset);
    childContext.stopRecordingIfNeeded();
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }
}
