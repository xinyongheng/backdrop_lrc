// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:async/async.dart';
import 'package:audio_play/data/bean/lrc.dart';
import 'package:audio_play/widget/LrcWidget.dart';
import 'package:audio_play/widget/lrc_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutoPage extends StatefulWidget {
  const AutoPage({super.key});

  @override
  State<AutoPage> createState() => _AutoPageState();
}

class _AutoPageState extends State<AutoPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '音频',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: content(context),
    );
  }

  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;
  final AsyncMemoizer<Widget> _memoizer = AsyncMemoizer();
  final ScrollController _scrollController = ScrollController();
  late Animation<Offset> animation;
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer()
    ..onTap = () {
      print('click');
    };
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    //用到GestureRecognizer的话一定要调用其dispose方法释放资源
    _tapGestureRecognizer.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    // animation.dispose();
    super.dispose();
  }

  double screenViewHeight = 0;
  List<Rect> rects = [];

  /// 内容ui
  Widget content(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxWidth = constraints.maxWidth;
        final double screenHeight = MediaQuery.of(context).size.height;
        final double appBarHeight = AppBar().preferredSize.height;
        final double statusBarHeight = MediaQuery.of(context).padding.top;
        screenViewHeight = screenHeight - appBarHeight - statusBarHeight;
        return FutureBuilder<Widget>(
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  // print(snapshot.stackTrace);
                  return Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 30,
                    ),
                  );
                }
                _audioPlayer.resume();
                _animationController.forward();
                return snapshot.requireData;
              default:
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    // color: Colors.red,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                );
            }
            // return const Placeholder();
          },
          future: asyncMemoizer('起风了.lrc', '起风了.mp3', maxWidth),
        );
      },
    );
  }

  /// 获取文本内容
  Future<String> _loadContent(String fileName) async {
    return await rootBundle.loadString('data/$fileName');
  }

  Offset _position = Offset.zero;
  Future<Widget> asyncMemoizer(
      String fileName, String audioFileName, double maxWidth) {
    return _memoizer
        .runOnce(() => _makeAudioPlayer(fileName, audioFileName, maxWidth));
  }

  bool preScrollTag = false;
  int nowIndex = -1;
  void updateCursorPositionY(double audioProgress) {
    if (preScrollTag || audioProgress % 20 != 0) {
      return;
    }
    // print('$audioProgress ${audioProgress % 10}');
    double y = _position.dy + 200 - _scrollController.offset;
    // print(
    //     'screenViewHeight=$screenViewHeight y=$y ${_scrollController.offset}');
    // 需要滚动，且没有滚动到底部
    if ((y > screenViewHeight &&
            _scrollController.position.pixels !=
                _scrollController.position.maxScrollExtent) ||
        (_position.dy < _scrollController.offset)) {
      preScrollTag = true;
      _scrollController
          .animateTo(max(_position.dy - screenViewHeight / 4, 0),
              duration: const Duration(milliseconds: 500), curve: Curves.ease)
          .then((value) => preScrollTag = false);
    }
  }

  /// 播放加载准备 以及页面ui计算
  Future<Widget> _makeAudioPlayer(
      String fileName, String audioFileName, double maxWidth) async {
    String content = await _loadContent(fileName);
    var lrcList = LrcBean.parse(content);
    AudioBean audioBean = AudioBean.make(0, lrcList);
    nowIndex = -1;
    AudioPlayer player = AudioPlayer(playerId: '${fileName}lrc');
    _audioPlayer = player;
    player.audioCache.prefix = 'data/';
    await player.setSourceAsset(audioFileName);
    // 播放进度监听
    /* player.onPositionChanged.listen((Duration duration) {
      duration.inMicroseconds;
      
    }); */
    var audioDuration = (await player.getDuration())!;
    audioBean.duration = audioDuration.inMicroseconds;
    _animationController.duration = audioDuration;
    _animationController = AnimationController(
      vsync: this,
      duration: audioDuration,
      lowerBound: 0.0,
      upperBound: audioBean.realDuration.toDouble(),
    );
    var results = calculationText(audioBean.list, maxWidth);
    // print("object:upperBound= ${audioBean.realDuration.toDouble()}");
    Size size = results[0];
    List<List<TextBox>> rects = results[1];
    List<TextSpan> textSpans = results[2];
    TextPainter textPainter = results[3];
    audioBean.updateBoxList(rects);
    _animationController.addListener(() async {
      var position = await _audioPlayer.getCurrentPosition();
      // print(
      //     "***animation: ${_animationController.value} ${position!.inMilliseconds}");
      double t = position!.inMilliseconds.toDouble();
      var bean = audioBean.findLrcBean(t);
      if (bean == null) {
        // _position = const Offset(0, -20);
        return;
      }
      int index = bean.index;
      var box = audioBean.getBoxList()[index];
      var list = box.list;

      if (nowIndex != index) {
        nowIndex = index;
        this.rects.clear();
        for (var element in list) {
          this.rects.add(element.toRect());
        }
      }
      var childTime = t - bean.timestamp;
      double childRate = childTime / bean.during;
      double childProgress = box.boxLength * childRate;
      double start = 0;
      // print(bean);
      // print(
      //     'childProgress=$childProgress index=$index childRate=$childRate t=$t ${bean.timestamp} $childTime');
      for (var item in list) {
        var childWidth = item.right - item.left;
        if (childProgress >= start && childProgress <= start + childWidth) {
          _position = Offset(item.left + childProgress - start, item.top);
          updateCursorPositionY(t);
          return;
        }
        start = start + childWidth;
      }
    });

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // CustomPaint(
          //   painter: LrcPainter(textSpans, textPainter),
          //   size: size,
          // ),
          LrcWidget(rects: this.rects, textPainter: textPainter),
          AnimatedBuilder(
            animation: _animationController,
            child: Image.asset('images/cursor_tag.png'),
            builder: (context, child) => Positioned(
              left: _position.dx,
              top: _position.dy - 8,
              child: child!,
            ),
          ),
        ],
      ),
    );
  }

  // void loadAudio(String name) {}

  /// 测算
  List calculationText(List<LrcBean> list, double maxWidth) {
    List<TextSelection> textSelections = [];
    List<TextSpan> textSpans = [];
    List<List<TextBox>> rects = [];
    int start = 0;
    int end = 0;
    for (int i = 0; i < list.length; i++) {
      var lrcBean = list[i];
      var textSpan = _textSpan(lrcBean.content);
      textSpans.add(textSpan);

      end = start + textSpan.text!.length;
      if (kDebugMode) {
        print('${textSpan.text!}: $start-$end');
      }
      textSelections.add(TextSelection(baseOffset: start, extentOffset: end));
      start = end;
    }
    var textPainter = TextPainter(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 23,
          fontFamily: 'PingFang',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final double height = textPainter.height;
    final size = Size(maxWidth, height + 0);
    for (TextSelection element in textSelections) {
      List<TextBox> boxs = _computer(textPainter.getBoxesForSelection(element));
      // print(boxs);
      rects.add(boxs);
    }
    return [size, rects, textSpans, textPainter];
  }

  TextSpan _textSpan(String content) {
    return TextSpan(text: '$content', recognizer: _tapGestureRecognizer);
  }

  List<TextBox> _computer(List<TextBox> boxs) {
    if (boxs.length < 2) {
      return boxs;
    }
    var last = boxs.last;
    var first = boxs[boxs.length - 2];
    if (first.right == last.left && last.top - first.top < 2) {
      return boxs.sublist(0, boxs.length - 1);
    }
    return boxs;
  }
}
