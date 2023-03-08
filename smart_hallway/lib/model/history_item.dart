class HistoryItem {
  String fileName;
  String comment;
  int trialId;
  bool saved;
  DateTime trialTime;

  HistoryItem(
      {this.fileName = '',
      this.comment = '',
      required this.trialId,
      this.saved = false,
      required this.trialTime});

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
        trialId: map['trialId'],
        fileName: map['fileName'],
        saved: map['saved'] == 0 ? false : true,
        comment: map['comment'],
        trialTime: DateTime.parse(map['trialTime'])
    );
  }
}
