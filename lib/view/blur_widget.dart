// ignore_for_file: invalid_use_of_protected_member, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

class RectBackdropFilter extends SingleChildRenderObjectWidget {
  const RectBackdropFilter({
    Key? key,
    required this.filter,
    required this.rects,
    this.size = Size.zero,
    Widget? child,
    this.blendMode = BlendMode.srcOver,
  }) : super(key: key, child: child);

  final ui.ImageFilter filter;
  final BlendMode blendMode;
  final List<Rect> rects;
  final Size size;

  @override
  _RenderBackdropFilter createRenderObject(BuildContext context) {
    return _RenderBackdropFilter(
        filter: filter,
        preferredSize: size,
        blendMode: blendMode,
        rects: rects);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderBackdropFilter renderObject) {
    renderObject
      ..preferredSize = size
      ..filter = filter
      ..blendMode = blendMode
      ..rects = rects;
  }
}

//850.0, 840.0
class _RenderBackdropFilter extends RenderProxyBox {
  _RenderBackdropFilter(
      {RenderBox? child,
      required ui.ImageFilter filter,
      required List<Rect> rects,
      Size preferredSize = Size.zero,
      BlendMode blendMode = BlendMode.srcOver})
      : _filter = filter,
        _rects = rects,
        _blendMode = blendMode,
        _preferredSize = preferredSize,
        super(child);

  @override
  BackdropFilterLayer? get layer => super.layer as BackdropFilterLayer?;
  final ui.Paint _paint = ui.Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.clear;

  ui.ImageFilter get filter => _filter;
  ui.ImageFilter _filter;

  set filter(ui.ImageFilter value) {
    if (_filter == value) return;
    _filter = value;
    markNeedsPaint();
  }

  Size get preferredSize => _preferredSize;
  Size _preferredSize;

  set preferredSize(Size value) {
    if (preferredSize == value) {
      return;
    }
    _preferredSize = value;
    markNeedsLayout();
  }

  BlendMode get blendMode => _blendMode;
  BlendMode _blendMode;

  set blendMode(BlendMode value) {
    if (_blendMode == value) return;
    _blendMode = value;
    markNeedsPaint();
  }

  List<Rect> get rects => _rects;
  List<Rect> _rects;

  set rects(List<Rect> value) {
    if (_rects == value) {
      return;
    }
    _rects = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child == null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      assert(needsCompositing);
      layer ??= BackdropFilterLayer();
      layer!.filter = _filter;
      layer!.blendMode = _blendMode;
      pushLayer(context, layer!, super.paint, offset);
    } else {
      layer = null;
    }
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
    // print('estimatedBounds= ${childContext.estimatedBounds}');
    final Canvas canvas = childContext.canvas;
    for (Rect element in _rects) {
      canvas.drawRect(element, _paint);
    }
    canvas.drawCircle(Offset(400, 400), 10, Paint()..color = Colors.red);
    painter(childContext, offset);
    childContext.stopRecordingIfNeeded();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child == null) {
      return preferredSize.width.isFinite ? preferredSize.width : 0;
    }
    return super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child == null) {
      return preferredSize.width.isFinite ? preferredSize.width : 0;
    }
    return super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child == null) {
      return preferredSize.height.isFinite ? preferredSize.height : 0;
    }
    return super.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child == null) {
      return preferredSize.height.isFinite ? preferredSize.height : 0;
    }
    return super.computeMaxIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    size = computeSizeForNoChild(constraints);
    // super.performLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.constrain(preferredSize);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    // if (child != null) {
    //   return child!.getDryLayout(constraints);
    // }
    return computeSizeForNoChild(constraints);
  }
}

class MyRenderCustomPaint extends RenderCustomPaint {
  MyRenderCustomPaint({
    CustomPainter? painter,
    CustomPainter? foregroundPainter,
    Size? preferredSize,
    required List<Rect> rects,
    isComplex = false,
    willChange = false,
    RenderBox? child,
  })  : _rects = rects,
        super(
            painter: painter,
            foregroundPainter: foregroundPainter,
            preferredSize: preferredSize ?? Size.zero,
            isComplex: isComplex,
            willChange: willChange);
  @override
  void markNeedsPaint() {
    super.markNeedsPaint();
  }

  final ui.Paint _paint = ui.Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.clear;

  List<Rect> get rects => _rects;
  List<Rect> _rects;

  set rects(List<Rect> value) {
    if (_rects == value) {
      return;
    }
    _rects = value;
    print('object-----------rects $_rects');
    markNeedsPaint();
  }

  @override
  BackdropFilterLayer? get layer => super.layer as BackdropFilterLayer?;
  void _paintWithPainter(Canvas canvas, Offset offset, CustomPainter painter) {
    late int debugPreviousCanvasSaveCount;
    canvas.save();
    assert(() {
      debugPreviousCanvasSaveCount = canvas.getSaveCount();
      return true;
    }());
    if (offset != Offset.zero) {
      canvas.translate(offset.dx, offset.dy);
    }
    painter.paint(canvas, size);
    assert(() {
      // This isn't perfect. For example, we can't catch the case of
      // someone first restoring, then setting a transform or whatnot,
      // then saving.
      // If this becomes a real problem, we could add logic to the
      // Canvas class to lock the canvas at a particular save count
      // such that restore() fails if it would take the lock count
      // below that number.
      final int debugNewCanvasSaveCount = canvas.getSaveCount();
      if (debugNewCanvasSaveCount > debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.save() or canvas.saveLayer() at least '
            '${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount} more '
            'time${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.restore().',
          ),
          ErrorDescription(
              'This leaves the canvas in an inconsistent state and will probably result in a broken display.'),
          ErrorHint(
              'You must pair each call to save()/saveLayer() with a later matching call to restore().'),
        ]);
      }
      if (debugNewCanvasSaveCount < debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.restore() '
            '${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount} more '
            'time${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.save() or canvas.saveLayer().',
          ),
          ErrorDescription(
              'This leaves the canvas in an inconsistent state and will result in a broken display.'),
          ErrorHint(
              'You should only call restore() if you first called save() or saveLayer().'),
        ]);
      }
      return debugNewCanvasSaveCount == debugPreviousCanvasSaveCount;
    }());
    canvas.restore();
  }

  void _setRasterCacheHints(PaintingContext context) {
    if (isComplex) {
      context.setIsComplexHint();
    }
    if (willChange) {
      context.setWillChangeHint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // super.paint(context, offset);

    if (painter != null) {
      _paintWithPainter(context.canvas, offset, painter!);
      _setRasterCacheHints(context);
    }
    // super.paint(context, offset);

    layer ??= BackdropFilterLayer();
    layer!.filter = ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4);
    // layer!.blendMode = BlendMode.dstOut;
    pushLayer(context, layer!, super.paint, offset,
        childPaintBounds:
            Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    if (foregroundPainter != null) {
      _paintWithPainter(context.canvas, offset, foregroundPainter!);
      _setRasterCacheHints(context);
    }
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
    print('estimatedBounds= ${childContext.estimatedBounds} ${_rects}');
    final Canvas canvas = childContext.canvas;
    canvas.translate(offset.dx, offset.dy);
    for (Rect element in _rects) {
      canvas.drawRect(element, _paint);
      print(element);
      // canvas.drawRect(Rect.fromLTRB(270.0, 0.0, 570.0, 42.0), _paint);
    }

    // canvas.drawCircle(Offset(400, 400), 10, _paint..color = Colors.red);
    // canvas.drawRect(Rect.fromCircle(center: Offset(200, 400), radius: 30),
    //     _paint..color = Colors.blue);

    // painter(childContext, offset);
    // super.paint(childContext, offset);
    childContext.stopRecordingIfNeeded();
  }
}
