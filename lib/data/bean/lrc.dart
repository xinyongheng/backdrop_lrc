import 'dart:math';
import 'dart:ui';

final RegExp regExpTime = RegExp(r'\[(\d{2}):(\d{2}).(\d{0,3})\]');

class AudioBean {
  //开始时间戳
  int start = 0;
  // 结束时间戳
  int end = 0;
  // 获取的时长
  int duration = 0;
  // 真实 时长
  int realDuration = 0;

  late List<LrcBean> list;

  List<TextBoxBean> _boxList = [];
  double boxSumLength = 0;
  int indexTag = 0;
  AudioBean.make(this.duration, List<LrcBean> list,
      {List<List<TextBox>>? boxList}) {
    start = list[0].timestamp;
    var last = list.last;
    if (last.during == 0) {
      end = last.timestamp;
    } else {
      print('对应歌词请设置结束时间');
      throw LrcError('对应歌词请设置结束时间');
    }
    realDuration = end - start;
    this.list = [];
    for (var i = 0; i < list.length - 1; i++) {
      this.list.add(list[i]);
    }
    print('list length=${this.list.length}');
    if (boxList != null) {
      updateBoxList(boxList);
    }
  }

  void updateBoxList(List<List<TextBox>> list) {
    _boxList = [];
    double sum = 0.0;
    for (var i = 0; i < list.length; i++) {
      var bean = TextBoxBean(list[i]);
      bean.index = i;
      double childSum = 0.0;
      for (TextBox item in bean.list) {
        childSum += (item.right - item.left);
      }
      bean.stampLength = sum;
      bean.boxLength = childSum;
      sum += childSum;
      _boxList.add(bean);
    }
    boxSumLength = sum;
    for (var box in _boxList) {
      box.rate = box.stampLength / sum;
    }
  }

  bool boxListIsEmpty() => _boxList.isEmpty;
  List<TextBoxBean> getBoxList() => _boxList;

  LrcBean? findLrcBean(double position) {
    for (var i = 0; i < list.length; i++) {
      LrcBean lrcBean = list[i];
      if (lrcBean.timestamp <= position &&
          lrcBean.timestamp + lrcBean.during >= position) {
        indexTag = i;
        if (i != lrcBean.index) {
          throw Error();
        }
        // print("findLrcBean $position ${lrcBean.timestamp} $duration $indexTag");
        return lrcBean;
      }
    }
    return null;
  }

  double rate(double position) {
    // print('positoon = ${position} $start');
    return max(0, (position - start)) / realDuration;
  }

  late TextBoxBean textBoxBean;
  late LrcBean lrcBean;
  Offset? findCursorPosition(double rate) {
    for (var i = 0; i < _boxList.length; i++) {
      var bean = _boxList[i];
      if (i + 1 >= _boxList.length ||
          (bean.rate <= rate && _boxList[i + 1].rate >= rate)) {
        var boxPosition = boxSumLength * rate - bean.stampLength;
        var childLength = 0.0;
        for (var i = 0; i < bean.list.length; i++) {
          var element = bean.list[i];
          var childWidth = element.right - element.left;
          if (boxPosition >= childLength &&
              boxPosition <= childLength + childWidth) {
            // print('dddd: ${element.left}, ${boxPosition} ${childLength}');
            textBoxBean = bean;
            lrcBean = list[bean.index];
            return Offset(
                boxPosition - childLength + element.left, element.top);
          }
          childLength += childWidth;
        }
      }
    }
    return null;
  }
}

class LrcBean {
  int index = 0;
  int min;
  int second;
  int millisecond;
  String content;
  int timestamp;
  int during = 0;
  LrcBean(
    this.min,
    this.second,
    this.millisecond,
    this.timestamp,
    this.content,
  );

  @override
  String toString() {
    return '$min:$second.$millisecond timestamp=$timestamp during=$during $content';
  }

  static LrcBean parseItem(String item) {
    RegExpMatch match = regExpTime.firstMatch(item)!;
    // if (match.groupCount < 3) throw '正则匹配错误';
    int min = int.parse(match.group(1)!);
    int second = int.parse(match.group(2)!);
    int millisecond = int.parse(match.group(3)!);
    String childContent = '';
    if (item.length > match.end) {
      childContent = item.substring(match.end);
    }
    var timestamp = min * 60 * 1000 + second * 1000 + millisecond;
    LrcBean bean = LrcBean(min, second, millisecond, timestamp, childContent);
    return bean;
  }

  static List<LrcBean> parse(String content) {
    List<String> array = content.split('\n');
    List<LrcBean> list = [];
    for (int i = 0; i < array.length; i++) {
      LrcBean bean = LrcBean.parseItem(array[i]);
      list.add(bean);
      bean.index = i;
      if (i > 0) {
        LrcBean last = list[i - 1];
        last.during = bean.timestamp - last.timestamp;
      }
    }
    return list;
  }
}

class TextBoxBean {
  int index = 0;
  double boxLength = 0;
  double stampLength = 0;
  double rate = 0;
  List<TextBox> list;
  TextBoxBean(
    this.list,
  );
}

class LrcError extends Error {
  final String message;
  LrcError(this.message);
  String toString() => "Bad state: $message";
}
