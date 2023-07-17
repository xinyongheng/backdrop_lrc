import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui
    show
        Image,
        decodeImageFromPixels,
        PixelFormat,
        Codec,
        FrameInfo,
        instantiateImageCodec;
import 'render_custom.dart';

///坐标位置
class LocalPoint {
  Offset start;
  Offset? end;

  //信息
  dynamic data;

  LocalPoint(this.start, {this.end, this.data});

  void autoAdd() {
    if (end == null) {
      end =
          start.translate(Random().nextInt(20) + 10, Random().nextInt(10) + 5);
    } else {
      start = end!;
      end = end!.translate(Random().nextInt(20) + 10, Random().nextInt(10) + 5);
    }
  }
}

class MovePage extends StatefulWidget {
  const MovePage({Key? key}) : super(key: key);

  @override
  State<MovePage> createState() => _MovePageState();
}

class _MovePageState extends State<MovePage> {
  final timeout = const Duration(seconds: 5);
  late Timer timer;
  List<LocalPoint> list = [];
  List<RenderMoveWidget> moveList = [];

  @override
  void initState() {
    // var autoPlayer = AudioPlayer();
    // autoPlayer.audioCache = AudioCache(prefix: 'data/');
    // var duration = autoPlayer.getDuration();
    // print(duration);
    // TODO: implement initState
    super.initState();
    list.add(LocalPoint(const Offset(50, 50), data: 1));
    list.add(LocalPoint(const Offset(200, 200), data: 2));
    list.add(LocalPoint(const Offset(300, 50), data: 3));
    list.add(LocalPoint(const Offset(400, 200), data: 4));
    list.add(LocalPoint(const Offset(500, 150), data: 5));
    // renderObject
    timer = Timer.periodic(timeout, (timer) {
      for (LocalPoint element in list) {
        element.autoAdd();
      }
      /*for (int i = 0; i < list.length; i++) {
        LocalPoint element = list[i];
        element.autoAdd();
        if (moveList.isNotEmpty) {
          // moveList[i].renderObject;
        }
      }*/
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('动画'), centerTitle: true),
      body: Container(
        width: 1536.0,
        height: 689.4,
        color: Colors.white,
        child: FutureBuilder<ui.Image>(
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  print(snapshot.stackTrace);
                  return const Text('出问题了');
                }
                ui.Image image = snapshot.data!;
                return body(image);
              default:
                return const Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                        color: Colors.blue,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
                  ),
                );
            }
          },
          future: loadImage(),
        ),
      ),
    );
  }

  Widget body(ui.Image image) {
    return Stack(
      children: childItems(image),
    );
  }

  Future<ui.Image> loadImage() async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ByteData byteData = await rootBundle.load('images/car1.png');
    int width = 130 ~/ 5;
    int height = 280 ~/ 5;
    /* ui.decodeImageFromPixels(
      byteData.buffer.asUint8List(),
      width,
      height,
      ui.PixelFormat.rgbaFloat32,
      (ui.Image image) => completer.complete(image),
    ); */
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: width,
        targetHeight: height);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    completer.complete(frameInfo.image);
    return completer.future;
  }

  List<RenderMoveWidget> childItems(ui.Image image) {
    List<RenderMoveWidget> list = [];
    for (LocalPoint element in this.list) {
      list.add(makeWidget(image, element.start, element.end));
    }
    moveList = list;
    return list;
  }

  RenderMoveWidget makeWidget(ui.Image image, Offset start, Offset? end) {
    return RenderMoveWidget(
      image: image,
      defaultSize: const Size(300, 300),
      start: start,
      end: end,
    );
  }
}

class RenderMoveWidget extends LeafRenderObjectWidget {
  const RenderMoveWidget({
    super.key,
    required this.image,
    required this.defaultSize,
    required this.start,
    this.end,
  });

  final ui.Image image;
  final Size defaultSize;
  final Offset start;
  final Offset? end;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMoveBox(
        image: image, defaultSize: defaultSize, start: start, end: end);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderMoveBox renderObject) {
    if (start != renderObject._start || end != renderObject._end) {
      renderObject.updatePoint(start, end);
    }
  }
}

class RenderMoveBox extends RenderBox with RenderObjectAnimationMixin {
  RenderMoveBox({
    required this.image,
    required this.defaultSize,
    required Offset start,
    required Offset? end,
  })  : _start = start,
        _end = end {
    if (_end != null) {
      animationStatus = AnimationStatus.forward;
    } else {
      progress = 1;
    }
  }

  final ui.Image image;
  final Size defaultSize;
  Offset _start;

  Offset get start => _start;
  Offset? _end;

  Offset? get end => _end;

  void updatePoint(Offset start, Offset? end) {
    if (start != _start || end != _end) {
      _start = start;
      _end = end;
      if (_end != null) {
        progress = 0;
        animationStatus = AnimationStatus.forward;
      } else {
        progress = 1;
        markNeedsPaint();
      }
    }
  }

  @override
  Duration get duration => const Duration(seconds: 3);

  @override
  void performLayout() {
    Size parentSize = constraints.biggest;
    print(parentSize);
    // size = defaultSize;
    size = constraints.constrain(
      constraints.isTight ? Size.infinite : parentSize,
    );
    print(size);
  }

  @override
  bool get sizedByParent => false;
  final _paint = Paint()
    ..isAntiAlias = true
    ..color = Colors.blue;

  @override
  void doPaint(PaintingContext context, Offset offset) {
    // Rect rect = offset & size;
    Canvas canvas = context.canvas;
    // canvas.drawColor(Colors.white, BlendMode.srcATop);
    Offset offsetProgress =
        _end == null ? _start : Offset.lerp(_start, _end!, progress)!;
    // print(offsetProgress);
    canvas.drawCircle(offsetProgress, 10, Paint()..color = Colors.yellow);
    canvas.drawImage(image, offsetProgress, _paint);
  }
}
