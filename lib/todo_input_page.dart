import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'todo_list_store.dart';
import 'todo.dart';

/// Todo入力画面のクラス
///
/// 以下の責務を持つ
/// ・Todo入力画面の状態を生成する
class TodoInputPage extends StatefulWidget {
  /// Todoのモデル
  final Todo? todo;

  /// コンストラクタ
  /// Todoを引数で受け取った場合は更新、受け取らない場合は追加画面となる
  const TodoInputPage({Key? key, this.todo}) : super(key: key);

  /// Todo入力画面の状態を生成する
  @override
  State<TodoInputPage> createState() => _TodoInputPageState();
}

/// Todo入力ト画面の状態クラス
///
/// 以下の責務を持つ
/// ・Todoを追加/更新する
/// ・Todoリスト画面へ戻る
class _TodoInputPageState extends State<TodoInputPage> {
  /// ストア
  final TodoListStore _store = TodoListStore();

  /// 新規追加か
  late bool _isCreateTodo;

  /// 画面項目：タイトル
  late String _title;

  /// 画面項目：詳細
  late String _detail;

  /// 画面項目：終了日時
  late String _finishDateTime;

  /// 画面項目：完了か
  late bool _done;

  /// 画面項目：作成日時
  late String _createDate;

  /// 画面項目：更新日時
  late String _updateDate;

  /// 初期処理を行う
  @override
  void initState() {
    super.initState();
    var todo = widget.todo;

    _title = todo?.title ?? "";
    _detail = todo?.detail ?? "";
    _finishDateTime = todo?.finishDateTime ?? "";
    _done = todo?.done ?? false;
    _createDate = todo?.createDate ?? "";
    _updateDate = todo?.updateDate ?? "";
    _isCreateTodo = todo == null;
  }

  /// 画面を作成する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // アプリケーションバーに表示するタイトル
        title: Text(_isCreateTodo ? 'Todo追加' : 'Todo更新'),
      ),
      body: Container(
        // 全体のパディング
        padding: const EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            // 完了かのチェックボックス
            // タイトルのテキストフィールド
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "タイトル",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              // TextEditingControllerを使用することで、いちいちsetStateしなくても画面を更新してくれる
              controller: TextEditingController(text: _title),
              onChanged: (String value) {
                _title = value;
              },
            ),
            const SizedBox(height: 15),
            // 詳細のテキストフィールド
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: "詳細",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              // TextEditingControllerを使用することで、いちいちsetStateしなくても画面を更新してくれる
              controller: TextEditingController(text: _detail),
              onChanged: (String value) {
                _detail = value;
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        // onChanged内の処理はDatepickerの選択に応じて毎回呼び出される
                        onChanged: (date) {
                      // print('change $date');
                    },
                        // onConfirm内の処理はDatepickerで選択完了後に呼び出される
                        onConfirm: (date) {
                      setState(() {
                        initializeDateFormatting('ja');
                        _finishDateTime =
                            DateFormat('yyyy-MM-dd HH:mm:ss', "ja")
                                .format(date);
                      });
                    },
                        // Datepickerのデフォルトで表示する日時
                        currentTime: DateTime.now(),
                        // localによって色々な言語に対応
                        locale: LocaleType.jp);
                  },
                  child: Text(
                    _finishDateTime == "" ? '納期日時を選択' : "納期：$_finishDateTime",
                  )),
            ),
            const SizedBox(height: 20),
            // 追加/更新ボタン
            Row(
              children: <Widget>[
                Expanded(
                  child:
                      // キャンセルボタン
                      SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Todoリスト画面に戻る
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      child: const Text(
                        "キャンセル",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isCreateTodo) {
                          // Todoを追加する
                          _store.add(_done, _title, _detail, _finishDateTime);
                        } else {
                          // Todoを更新する
                          _store.update(widget.todo!, _done, _title, _detail,
                              _finishDateTime);
                        }
                        // Todoリスト画面に戻る
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        _isCreateTodo ? '追加' : '更新',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 作成日時のテキストラベル
            Visibility(
              visible: !_isCreateTodo,
              child: Text("作成日時 : $_createDate\n更新日時 : $_updateDate"),
            ),
          ],
        ),
      ),
    );
  }
}
