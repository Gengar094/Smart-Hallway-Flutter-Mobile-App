class HistoryItem {
  String fileName;
  String comment;
  int trialId;
  bool saved;
  DateTime trialTime = DateTime.now();

  HistoryItem(
      {this.fileName = '',
      this.comment = '',
      required this.trialId,
      this.saved = false});
}
