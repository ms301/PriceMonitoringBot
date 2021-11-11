unit PMB.Log;

interface

uses
  mormot.core.base,
  mormot.core.Log;

type
  TSynLogInfo = mormot.core.base.TSynLogInfo;

function Log: TSynLogClass;

implementation

uses
  mormot.db.raw.sqlite3;

var
  LogFamily: TSynLogFamily;

procedure BuildLog;
begin
  LogFamily := SQLite3Log.Family;
  LogFamily.Level := LOG_VERBOSE;
  LogFamily.PerThreadLog := ptIdentifiedInOnFile;
  LogFamily.EchoToConsole := LOG_VERBOSE;
end;

function Log: TSynLogClass;
begin
  Result := SQLite3Log;
end;

initialization

BuildLog;

finalization

end.
