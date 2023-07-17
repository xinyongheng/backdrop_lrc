import 'dart:ui' as ui;
// import 'dart:ui';

import 'package:audio_play/config/config.dart';
import 'package:audio_play/view/move_animall.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'page/autopage.dart';
import 'page/homepage.dart';

void main() async {
  runApp(const MyApp());
  // ui.window.onBeginFrame = beginFrame;
  // ui.window.onDrawFrame = draw1stFrame;

  // ///画第一帧
  // ui.window.scheduleFrame();

  ///画第二帧，
  // await Future.delayed(Duration(milliseconds: 500), () {
  //   ui.window.onDrawFrame = draw2ndFrame;
  //   ui.window.scheduleFrame();
  // });

  // ///画第三帧
  // await Future.delayed(Duration(milliseconds: 500), () {
  //   ui.window.onDrawFrame = draw3rdFrame;
  //   ui.window.scheduleFrame();
  // });

  ///画第四帧
  // await Future.delayed(Duration(milliseconds: 500), () {
  //   ui.window.onDrawFrame = draw4thFrame;
  //   ui.window.scheduleFrame();
  // });
}

void beginFrame(Duration duration) {}

OffsetLayer rootLayer = OffsetLayer();
void draw1stFrame() {
  print('draw1stFrame');
  PaintingContext context =
      PaintingContext(rootLayer, Rect.fromLTRB(0, 0, 1000, 1000));
  context.canvas.drawRect(
      const Rect.fromLTRB(200, 200, 800, 800), Paint()..color = Colors.blue);
  ui.Paragraph paragraph = (ui.ParagraphBuilder(ui.ParagraphStyle(
    fontSize: 30,
  ))
        ..addText(
            'fasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasdadfasdfasdfasdfasdfasdfasdfasd')
        ..pushStyle(ui.TextStyle(color: Colors.yellow, fontSize: 30)))
      .build();
  paragraph.layout(const ui.ParagraphConstraints(width: 600));
  context.canvas.drawParagraph(paragraph, Offset.zero.translate(200, 200));

  context.stopRecordingIfNeeded();

  final ui.SceneBuilder builder = ui.SceneBuilder();
  final ui.Scene scene = rootLayer.buildScene(builder);
  ui.window.render(scene);
  scene.dispose();
}

void draw2ndFrame() {
  print('draw2ndFrame');
  PaintingContext context =
      PaintingContext(rootLayer, const Rect.fromLTRB(0, 0, 1000, 1000));
  context.canvas.drawRect(
      const Rect.fromLTRB(400, 400, 1000, 1000), Paint()..color = Colors.red);
  context.stopRecordingIfNeeded();

  final ui.SceneBuilder builder = ui.SceneBuilder();
  final ui.Scene scene = rootLayer.buildScene(builder);
  ui.window.render(scene);
  scene.dispose();
}

void draw3rdFrame() {
  print('draw3rdFrame');
  PaintingContext context =
      PaintingContext(rootLayer, const Rect.fromLTRB(0, 0, 1200, 1200));
  context.canvas.drawRect(const Rect.fromLTRB(600, 600, 1200, 1200),
      Paint()..color = Colors.yellow);
  context.stopRecordingIfNeeded();

  final ui.SceneBuilder builder = ui.SceneBuilder();
  final ui.Scene scene = rootLayer.buildScene(builder);
  ui.window.render(scene);
  scene.dispose();
}

void draw4thFrame() {
  print('draw4thFrame');
  var childLayer = BackdropFilterLayer();
  childLayer.filter = ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4);
  childLayer.blendMode = BlendMode.srcATop;
  PaintingContext context =
      PaintingContext(childLayer, const Rect.fromLTRB(0, 0, 1000, 2000));
  rootLayer.append(childLayer);
  ui.Paint paint = ui.Paint()..color = Colors.transparent;
  Rect rect = const Rect.fromLTRB(300, 300, 900, 900);
  context.canvas.drawRect(rect, paint);
  context.canvas.drawRect(Rect.fromCircle(center: rect.center, radius: 100),
      ui.Paint()..blendMode = ui.BlendMode.clear);
  context.stopRecordingIfNeeded();

  final ui.SceneBuilder builder = ui.SceneBuilder();
  final ui.Scene scene = rootLayer.buildScene(builder);
  ui.window.render(scene);
  scene.dispose();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1200),
      // 是否根据宽度/高度中的最小值适配文字
      minTextAdapt: false,
      // 支持分屏尺寸
      splitScreenMode: false,
      rebuildFactor: RebuildFactors.sizeAndViewInsets,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '音频播放',
          locale: const Locale('zh', 'CH'),
          scrollBehavior: WebScrollBehavior(),
          theme: ThemeData(
            primaryColor: Config.themeColor,
            hintColor: Config.hintColor,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            fontFamily: 'PingFang',
          ),
          home: child,
          builder: EasyLoading.init(builder: (context, child) {
            EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
            EasyLoading.instance.indicatorColor = Colors.blue;
            EasyLoading.instance.backgroundColor = Colors.white;
            EasyLoading.instance.textColor = Colors.black;
            return child!;
          }),
        );
      },
      // child: const Homepage(),
      child: const AutoPage(),
      // child: const MovePage(),
    );
  }
}

/// 鼠标滚动
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<ui.PointerDeviceKind> get dragDevices => {
        ui.PointerDeviceKind.touch,
        ui.PointerDeviceKind.mouse,
        ui.PointerDeviceKind.stylus,
        ui.PointerDeviceKind.invertedStylus,
        // The VoiceAccess sends pointer events with unknown type when scrolling
        // scrollables.
        ui.PointerDeviceKind.unknown,
      };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: const AutoPage(),
    );
  }
}
