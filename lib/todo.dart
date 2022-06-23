/// Todoモデルのクラス
///
/// 以下の責務を持つ
/// ・Todoのプロパティを持つ
class Todo {
  /// ID
  late int id;

  /// タイトル
  late String title;

  /// 詳細
  late String detail;

  /// 納期
  late String finishDateTime;

  /// 完了か
  late bool done;

  /// 作成日時
  late String createDate;

  /// 更新日時
  late String updateDate;

  /// コンストラクタ
  Todo(
    this.id,
    this.title,
    this.detail,
    this.finishDateTime,
    this.done,
    this.createDate,
    this.updateDate,
  );

  /// TodoモデルをMapに変換する(保存時に使用)
  Map toJson() {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'finishDateTime': finishDateTime,
      'done': done,
      'createDate': createDate,
      'updateDate': updateDate
    };
  }

  /// MapをTodoモデルに変換する(読込時に使用)
  Todo.fromJson(Map json) {
    id = json['id'];
    title = json['title'];
    detail = json['detail'];
    finishDateTime = json['finishDateTime'];
    done = json['done'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
  }
}
