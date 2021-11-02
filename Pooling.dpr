program Pooling;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  mormot.core.log,
  mormot.db.raw.sqlite3,
  TelegramBotApi.Client,
  TelegramBotApi.Types,
  TelegramBotApi.Types.Enums,
  TelegramBotApi.Types.Request,
  TelegramBotApi.Polling.Console,
  System.SysUtils,
  System.Rtti,
  Winapi.Windows,
  TelegramBotApi.Types.Keyboards,
  PMB.Daemon in 'PMB.Daemon.pas',
  PMB.Orm.Model in 'PMB.Orm.Model.pas',
  mormot.core.os,
  mormot.core.base,
  PMB.Tg.Pooling in 'PMB.Tg.Pooling.pas';

var
  LogFamily: TSynLogFamily;
  SampleDaemon: TSampleDaemon;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    LogFamily := SQLite3Log.Family;
    LogFamily.Level := LOG_VERBOSE;
    LogFamily.PerThreadLog := ptIdentifiedInOnFile;
    LogFamily.EchoToConsole := LOG_VERBOSE;
    SampleDaemon := TSampleDaemon.Create(TSampleDaemonSettings, Executable.ProgramFilePath, '', '');
    SQLite3Log.Add.log(sllInfo, 'Daemon started, listening on port ' + HttpPort);
    try
      SampleDaemon.CommandLine;
    finally
      SQLite3Log.Add.log(sllInfo, 'Daemon shut down');
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
