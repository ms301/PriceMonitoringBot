unit PMB.Daemon;

interface

uses
  mormot.app.Daemon,
  mormot.rest.http.server,
  mormot.rest.sqlite3,
  mormot.orm.core,
  mormot.db.raw.sqlite3.static,
  System.SysUtils,
  PMB.Tg.Pooling;

type
  TSampleDaemonSettings = class(TSynDaemonSettings)
  end;

  TSampleDaemon = class(TSynDaemon)
  protected
    FClient: TRestClientDB;
    FCore: TDemoPooling;
  public
    constructor Create(aSettingsClass: TSynDaemonSettingsClass;
      const aWorkFolder, aSettingsFolder, aLogFolder: TFileName; const aSettingsExt: TFileName = '.settings';
      const aSettingsName: TFileName = '');
    procedure Start; override;
    procedure Stop; override;
  end;

var
  Model: TOrmModel;

implementation

uses
  PMB.orm.Model,
  mormot.db.raw.sqlite3, mormot.core.os, mormot.core.base;

{
  ******************************** TSampleDaemon *********************************
}
constructor TSampleDaemon.Create(aSettingsClass: TSynDaemonSettingsClass;
  const aWorkFolder, aSettingsFolder, aLogFolder: TFileName; const aSettingsExt: TFileName = '.settings';
  const aSettingsName: TFileName = '');
begin
  inherited Create(aSettingsClass, aWorkFolder, aSettingsFolder, aLogFolder, aSettingsExt, aSettingsName);

end;

procedure TSampleDaemon.Start;
begin
  SQLite3Log.Enter(self);
  FCore := TDemoPooling.Create;
  Model := CreateSampleModel;
  FClient := TRestClientDB.Create(Model, nil, ChangeFileExt(Executable.ProgramFileName, '.db'), TRestServerDB,
    false, '');
  FClient.server.server.CreateMissingTables;
  FCore.Main;
  SQLite3Log.Add.Log(sllInfo, 'HttpServer started at Port: ' + HttpPort);
end;

procedure TSampleDaemon.Stop;
begin
  SQLite3Log.Enter(self);
  FClient.Free;
  Model.Free;
  FCore.Free;
end;

end.
