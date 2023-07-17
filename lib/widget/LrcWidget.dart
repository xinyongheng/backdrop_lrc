// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LrcPainter extends CustomPainter {
  final List<TextSpan> list;
  final TextPainter textPainter;
  LrcPainter(this.list, this.textPainter, {Listenable? repaint})
      : super(repaint: repaint);
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // print(rect);
    // 限制绘制区域
    canvas.clipRect(rect);
    /* TextPainter textPainter = TextPainter(
      text: TextSpan(
        children: list,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 23,
          // fontFamily: 'PingFang',
        ),
      ),
      textDirection: TextDirection.ltr,
    ); 
    textPainter.layout(maxWidth: size.width);*/
    textPainter.paint(canvas, Offset.zero);
    // var box = textPainter
    //     .getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: 14));
    // print(box);
    canvas.drawRect(
        const Rect.fromLTRB(0.0, -0.4, 236.2, 31.8),
        Paint()
          ..color = Colors.blue
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke);
    canvas.drawRect(
        const Rect.fromLTRB(236.2, 0.4, 243.4, 33.0),
        Paint()
          ..color = Colors.red
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke);
    // print(list);
  }

  @override
  bool shouldRepaint(covariant LrcPainter oldDelegate) {
    return oldDelegate.list != list;
  }
}
