import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Config {
  static final defaultSize = 28.sp;
  static const defaultWeight = FontWeight.w400;
  static const themeColor = Color(0xFF3E7BFA);
  static const hintColor = Color.fromRGBO(0, 0, 0, 0.15);

  static startPage(BuildContext context, page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  static finishPage(BuildContext context, {bool refresh = false}) {
    Navigator.of(context).pop(refresh);
  }
}

Text text(
  String? data, {
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  String? fontFamily,
  List<String>? fontFamilyFallback,
  String? package,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Paint? foreground,
  Paint? background,
  TextOverflow? overflow,
}) =>
    Text(
      data ?? '',
      style: TextStyle(
        color: color ?? Colors.black,
        backgroundColor: backgroundColor ?? Colors.white,
        fontSize: fontSize ?? Config.defaultSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        foreground: foreground,
        background: background,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        package: package,
        overflow: overflow,
      ),
    );
