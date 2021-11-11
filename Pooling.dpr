program Pooling;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  PMB.Daemon in 'PMB.Daemon.pas',
  PMB.Orm.Model in 'PMB.Orm.Model.pas',
  mormot.core.os,
  mormot.core.base,
  PMB.Tg.Pooling in 'PMB.Tg.Pooling.pas',
  PMB.Log in 'PMB.Log.pas',
  PMB.Tg.Routing in 'PMB.Tg.Routing.pas';

var
  SampleDaemon: TSampleDaemon;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    SampleDaemon := TSampleDaemon.Create(TSampleDaemonSettings, Executable.ProgramFilePath, '', '');
    Log.Add.log(sllInfo, 'Daemon started, listening on port ' + HttpPort);
    try
      SampleDaemon.CommandLine;
    finally
      Log.Add.log(sllInfo, 'Daemon shut down');
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
