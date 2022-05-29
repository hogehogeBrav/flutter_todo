import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'todo_input_page.dart';
import 'todo_list_store.dart';
import 'todo.dart';

/// Todoリスト画面のクラス
///
/// 以下の責務を持つ
/// ・Todoリスト画面の状態を生成する
class TodoListPage extends StatefulWidget {
  /// コンストラクタ
  const TodoListPage({Key? key}) : super(key: key);

  /// Todoリスト画面の状態を生成する
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

/// Todoリスト画面の状態クラス
///
/// 以下の責務を持つ
/// ・Todoリストを表示する
/// ・Todoの追加/編集画面へ遷移する
/// ・Todoの削除を行う
class _TodoListPageState extends State<TodoListPage> {
  /// ストア
  final TodoListStore _store = TodoListStore();

  /// Todoリスト入力画面に遷移する
  void _pushTodoInputPage([Todo? todo]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return TodoInputPage(todo: todo);
        },
      ),
    );

    // Todoの追加/更新を行う場合があるため、画面を更新する
    setState(() {});
  }

  /// 初期処理を行う
  @override
  void initState() {
    super.initState();

    ///0.5 Seconds
    Timer.periodic(const Duration(seconds: 1), _onTimer);

    Future(
      () async {
        // ストアからTodoリストデータをロードし、画面を更新する
        setState(() => _store.load());
      },
    );
  }

  void _onTimer(Timer timer) {
    setState(() {});
  }

  /// 画面を作成する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // アプリケーションバーに表示するタイトル
        title: const Text('ToDo Watcher'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          // Todoの件数をリストの件数とする
          itemCount: _store.count(),
          itemBuilder: (context, index) {
            // インデックスに対応するTodoを取得する
            var item = _store.findByIndex(index);
            return Slidable(
                // 右方向にリストアイテムをスライドした場合のアクション
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // Todo編集画面に遷移する
                        _pushTodoInputPage(item);
                      },
                      backgroundColor: Colors.yellow,
                      icon: Icons.edit,
                      label: '編集',
                    ),
                  ],
                ),
                // 左方向にリストアイテムをスライドした場合のアクション
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // Todoを削除し、画面を更新する
                        setState(() => {_store.delete(item)});
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.edit,
                      label: '削除',
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    _pushTodoInputPage(item);
                  },
                  child: Container(
                    height: 105,
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 13),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ListTile(
                      // ID
                      leading: Text(item.id.toString()),
                      // タイトル
                      title: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("・${itemTitle(item.title)}"),
                                    Text("開始：${viewDate(item.createDate)}",
                                        style: TextStyle(fontSize: 12)),
                                    Text("納期：${viewDate(item.finishDateTime)}",
                                        style: TextStyle(fontSize: 12)),
                                  ]),
                            ),
                            // プログレスバー
                            SizedBox(
                                child: LinearProgressIndicator(
                              minHeight: 22.0,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlueAccent),
                              value: double.parse(deadLineCalc(
                                  item.createDate, item.finishDateTime)),
                            )),
                            // 進捗率の文字
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                    progressMsg(double.parse(deadLineCalc(
                                        item.createDate, item.finishDateTime))),
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white))),
                          ]),
                      // 完了か
                      trailing: Checkbox(
                        // チェックボックスの状態
                        value: item.done,
                        onChanged: (bool? value) {
                          // Todo(完了か)を更新し、画面を更新する
                          setState(() => _store.update(item, value!));
                        },
                      ),
                    ),
                  ),
                ));
          },
        ),
      ),

      // Todo追加画面に遷移するボタン
      floatingActionButton: FloatingActionButton(
        // Todo追加画面に遷移する
        onPressed: _pushTodoInputPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// "yyyy/MM/dd HH:mm"形式で日時を取得する
String getDateTime() {
  var format = DateFormat("yyyy-MM-dd HH:mm:ss");
  var dateTime = format.format(DateTime.now());
  return dateTime;
}

String deadLineCalc(String createDate, String finishDateTime) {
  var nowTime = DateTime.now();
  var startTime = DateTime.parse(createDate);
  DateTime endTime = DateTime.parse(finishDateTime);
  var parentTime = endTime.difference(startTime).inSeconds;
  var childTime = nowTime.difference(startTime).inSeconds;
  var result = (childTime / parentTime);
  // return _printDuration(parentTime);
  if (result >= 1.0) {
    result = 1.0;
  }
  return result.toString();
}

String progressMsg(double value) {
  if (value >= 1.0) {
    return "納期になりました！";
  } else if (value <= 0) {
    return "既に納期が過ぎています！";
  } else {
    var result = (value * 100).toStringAsFixed(2);
    return "現在 $result%";
  }
}

String itemTitle(String title) {
  if (title == "") {
    return "no title";
  } else {
    return title;
  }
}

String viewDate(String finishDateTime) {
  DateTime endTime = DateTime.parse(finishDateTime);
  var format = DateFormat("yyyy年MM月dd日 HH:mm");
  var dateTime = format.format(endTime);
  return dateTime;
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
