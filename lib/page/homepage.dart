// ignore_for_file: must_be_immutable

import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:audio_play/data/bean/lrc.dart';
import 'package:audio_play/view/blur_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  Source? _urlSource;
  late AnimationController animation;
  late ui.Image image;
  final ValueNotifier<Offset> _valueNotifier = ValueNotifier(Offset.zero);
  int duration = 0;
  final AsyncMemoizer<List<LrcBean>> _memoizer = AsyncMemoizer();
  _readText() {
    return _memoizer.runOnce(() async {
      audioPlayer.audioCache.prefix = 'data/';
      /*  Uri uri = await audioPlayer.audioCache.load('起风了.mp3');
    print(uri.path);
    String path = Uri.decodeComponent(uri.path);
    print(path); */
      // _urlSource = DeviceFileSource(path);
      _urlSource = AssetSource('起风了.mp3');
      // await audioPlayer.play(_urlSource!);
      await audioPlayer.setSourceAsset('起风了.mp3');
      audioPlayer.onPositionChanged.listen((Duration event) {
        // print(event);
        var position = event.inMilliseconds;
        var rate = _audioBean!.rate(position.toDouble());
        /* LrcBean? lrc = _audioBean!.findLrcBean(position);
      if (lrc != null) {
        lrc.index
      } */
        var offset = _audioBean!.findCursorPosition(rate);
        if (offset != null) {
          var list = <Rect>[];
          for (var element in _audioBean!.textBoxBean.list) {
            list.add(element.toRect());
          }
          rectList = list;
          // print(
          //     "updateRenderObject rate=$rate ,offset=$offset ${_myCustomPaint.rects1}");
          setState(() {});
          foregroundPainter.offset = offset;
          _valueNotifier.value = offset;
        }
      });
      // await audioPlayer.play(_urlSource!);
      duration = (await audioPlayer.getDuration())!.inMicroseconds;
      print(duration);
      // await audioPlayer.resume();
      // await audioPlayer.setReleaseMode(ReleaseMode.loop);
      String text = await rootBundle.loadString('data/起风了-买辣椒也用券.lrc');
      List<LrcBean> list = LrcBean.parse(text);
      _audioBean = AudioBean.make(duration, list);
      image = await makePic();
      return list;
    });
  }

  // __readText()

  Future<ui.Image> makePic({int? targetWidth, int? targetHeight}) async {
    ByteData byteData = await rootBundle.load('images/cursor_tag.png');
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: targetWidth,
        targetHeight: targetHeight);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
    // canvas.drawImage(image, Offset.zero, Paint()..isAntiAlias = true);
    // return;
  }

  @override
  void dispose() {
    audioPlayer.release();
    super.dispose();
  }

  AudioBean? _audioBean;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _readText(),
        builder: (context, AsyncSnapshot<List<LrcBean>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                // print(snapshot.error);
                // print(snapshot.stackTrace);
                return const Text('出错了');
              }
              // audioPlayer.play(_urlSource!);
              return body(snapshot.requireData);
            default:
              return const CircularProgressIndicator(
                backgroundColor: Colors.blue,
                // color: Colors.red,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              );
          }
        },
      ),
    );
  }

  late MyPainter myPainter;
  late CurrsorPainter foregroundPainter;
  late MyCustomPaint _myCustomPaint;
  List<Rect> rectList = [];
  // Anima

  Widget body(list) {
    myPainter = MyPainter(
      list,
      image: image,
      width: 600,
      completePaint: (value) {
        if (_audioBean?.boxListIsEmpty() == true) {
          _audioBean?.updateBoxList(value);
          audioPlayer.resume().then((value1) => audioPlayer
              .seek(Duration(milliseconds: _audioBean!.list.first.timestamp)));
        }
      },
    );
    foregroundPainter =
        CurrsorPainter(Offset.zero, image: image, repaint: _valueNotifier);
    // var rect = const Rect.fromLTRB(650.0, 630.0, 830.0, 672.0);
    _myCustomPaint = MyCustomPaint(
      painter: myPainter,
      foregroundPainter: foregroundPainter,
      size: const Size(840, 1470),
      rects1: rectList,
    );
    return SingleChildScrollView(
      child: SizedBox(
        // width: 850,
        // height: 1000,
        child: Stack(
          children: [
            _myCustomPaint,
            // Positioned(
            //   left: offset.dx,
            //   top: offset.dy,
            //   child: Image.asset('images/cursor_tag.png'),
            // )
            /*RectBackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              size: const Size(850, 840),
              rects: [
                rect,
                // Rect.fromLTRB(0.0, 42.0, 240.0, 84.0)
              ],
                child: Container(
                color: Colors.transparent,
                width: 850,
                height: 840,
              ),*/ /*
            ),*/
          ],
        ),
      ),
    );
  }

  Widget paragraphView() {
    // BackdropFilter();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "images/horn.png",
          fit: BoxFit.fill,
          width: 40.w,
          height: 40.w,
        ),
        Text.rich(
          // ignore: prefer_const_constructors
          TextSpan(children: const [TextSpan(text: 'ss', style: TextStyle())]),
          style: TextStyle(fontSize: 24.sp, color: Colors.black),
        ),
      ],
    );
  }
}

class CurrsorPainter extends CustomPainter {
  Offset offset;
  ui.Image? image;
  ValueNotifier<Offset>? repaint;
  CurrsorPainter(
    this.offset, {
    this.image,
    this.repaint,
  }) : super(repaint: repaint);
  @override
  void paint(Canvas canvas, Size size) {
    print('CurrsorPainter size = ');
    print(size);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (image != null) {
      canvas.drawImage(
          image!, repaint?.value ?? Offset.zero, Paint()..isAntiAlias = true);
    }
    canvas.drawRect(
        const Rect.fromLTWH(70, 170, 300, 40),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(covariant CurrsorPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.image != image;
  }

  Future<ui.Image> makePic({int? targetWidth, int? targetHeight}) async {
    ByteData byteData = await rootBundle.load('images/cursor_tag.png');
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: targetWidth,
        targetHeight: targetHeight);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

class MyPainter extends CustomPainter {
  final List<LrcBean> _list;
  final double width;
  ui.Image? image;
  ValueChanged<List<List<TextBox>>>? completePaint;
  MyPainter(this._list,
      {Listenable? repaint,
      required this.width,
      this.image,
      this.completePaint})
      : super(repaint: repaint) {
    textSelections = <TextSelection>[];
    textSpans = <TextSpan>[];
    _init();
  }

  void _init() {
    // _makePic().then((value) => image = value);
    textSelections.clear();
    textSpans.clear();
    int start = 0;
    int end = 0;
    for (LrcBean item in _list) {
      String element = item.content;
      if (element.isNotEmpty) {
        end = start + element.length;
        textSelections.add(TextSelection(baseOffset: start, extentOffset: end));
        start = end;
        // print('${item.index}: $element');
        textSpans.add(TextSpan(text: element));
      }
    }
  }

  late List<TextSelection> textSelections;
  late List<TextSpan> textSpans;
  List<List<TextBox>> rects = [];

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    print('size = ');
    print(size);
    var textPainter = TextPainter(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 30,
          fontFamily: 'PingFang',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    // textPainter.computeLineMetrics();
    // textPainter.layout();
    // textPainter.maxLines;
    // textPainter.width;
    // textPainter.getBoxesForSelection();
    textPainter.layout(maxWidth: size.width);
    // print('textHeight = ${textPainter.height} size=$size');
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, textPainter.height));
    textPainter.paint(canvas, Offset.zero);
    rects.clear();
    // if (image != null) {
    //   canvas.drawImage(image!, Offset.zero, Paint()..isAntiAlias = true);
    // }
    canvas.drawRect(
        const Rect.fromLTWH(100, 100, 100, 50),
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke);
    for (TextSelection element in textSelections) {
      List<TextBox> boxs = textPainter.getBoxesForSelection(element);
      rects.add(boxs);
      // print(boxs);
    }
    completePaint?.call(rects);
  }

  Future<ui.Image> makePic({int? targetWidth, int? targetHeight}) async {
    ByteData byteData = await rootBundle.load('images/cursor_tag.png');
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: targetWidth,
        targetHeight: targetHeight);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
    // canvas.drawImage(image, Offset.zero, Paint()..isAntiAlias = true);
    // return;
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return oldDelegate._list != _list;
  }

  static bool compareRects(List<Rect> list1, List<Rect> list2) {
    if (list1 == list2) return true;
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      var item1 = list1[i];
      var item2 = list2[i];
      if (item1 != item2) return false;
    }
    return true;
  }
}

class MyCustomPaint extends SingleChildRenderObjectWidget {
  /// Creates a widget that delegates its painting.
  MyCustomPaint({
    super.key,
    this.painter,
    this.foregroundPainter,
    this.size,
    this.isComplex = false,
    this.willChange = false,
    required this.rects1,
    super.child,
  }) : assert(painter != null ||
            foregroundPainter != null ||
            (!isComplex && !willChange));

  final CustomPainter? painter;

  final CustomPainter? foregroundPainter;

  final Size? size;
  final List<Rect> rects1;

  final bool isComplex;

  final bool willChange;

  @override
  MyRenderCustomPaint createRenderObject(BuildContext context) {
    return MyRenderCustomPaint(
      rects: rects1,
      painter: painter,
      foregroundPainter: foregroundPainter,
      preferredSize: size,
      isComplex: isComplex,
      willChange: willChange,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, MyRenderCustomPaint renderObject) {
    // print('updateRenderObject $rects1');
    renderObject
      ..rects = rects1
      ..painter = painter
      ..foregroundPainter = foregroundPainter
      ..preferredSize = size ?? Size.zero
      ..isComplex = isComplex
      ..willChange = willChange;
  }

  @override
  void didUnmountRenderObject(MyRenderCustomPaint renderObject) {
    renderObject
      ..painter = null
      ..foregroundPainter = null;
  }
}
