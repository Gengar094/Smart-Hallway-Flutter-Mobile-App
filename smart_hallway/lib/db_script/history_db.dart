String HISTORY_DB_CREATION = '''
  CREATE TABLE history (
    trialId INTEGER PRIMARY KEY,
    fileName TEXT,
    comment TEXT,
    saved INTEGER,
    trialTime TEXT
  )
  ''';
