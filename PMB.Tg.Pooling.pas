unit PMB.Tg.Pooling;

interface

uses
  System.SysUtils,
  TelegramBotApi.Client,
  TelegramBotApi.Router,
  TelegramBotApi.Polling.Console,
  TelegramBotApi.Types,
  PMB.Tg.Routing,
  mormot.rest.sqlite3;

type
  TDemoPooling = class
  private
    fBot: TTelegramBotApi;
    fPooling: TtgPollingConsole;
    FRouter: TtgRouter;
    FRouteUsersState: TtgRouteUserStateManagerRAM;
    FRouterBuilder: TRouterBuilder;
  protected
    procedure UpdateConsoleTitle(ABot: TTelegramBotApi);
    function ReadToken: string;
    procedure SaveToken(const AToken: string);
    procedure DoReadMessage(AMsg: TtgMessage);
  public
    procedure Main;
    constructor Create(ADb: TRestClientDB);
    destructor Destroy; override;

  end;

implementation

uses
  System.Rtti,
  System.IOUtils,
  PMB.Log,
  TelegramBotApi.Types.Enums,
  TelegramBotApi.Types.Request,
  TelegramBotApi.Types.Keyboards,
  Winapi.Windows,
  CloudAPI.Exceptions,
  mormot.core.Log,
  mormot.core.os;

constructor TDemoPooling.Create(ADb: TRestClientDB);
begin
  fBot := TTelegramBotApi.Create(ReadToken);
  TcaExceptionManager.Current.OnAlert := procedure(AExcept: ECloudApiException)
    begin
      Log.Add.Log(TSynLogInfo.sllError, AExcept.ToString);
    end;
  fPooling := TtgPollingConsole.Create;
  fPooling.Bot := fBot;
  FRouteUsersState := TtgRouteUserStateManagerRAM.Create;
  FRouter := TtgRouter.Create(FRouteUsersState);
  FRouter.OnRouteMove := procedure(AUserID: Int64; AFrom, ATo: TtgRoute)
    begin
      Log.Add.Log(TSynLogInfo.sllInfo, 'RouteEnd: ' + AFrom.Name + ', RouteStart: ' + ATo.Name + ', UserID=' +
        AUserID.ToString);
    end;
  FRouterBuilder := TRouterBuilder.Create(FRouter, fBot, ADb);
end;

destructor TDemoPooling.Destroy;
begin
  SaveToken(fBot.BotToken);
  FRouterBuilder.Free;
  FRouteUsersState.Free;
  fBot.Free;
  fPooling.Free;
  FRouter.Free;
  inherited;
end;

procedure TDemoPooling.DoReadMessage(AMsg: TtgMessage);
begin
  FRouter.SendMessage(AMsg);
end;

procedure TDemoPooling.Main;
begin
  UpdateConsoleTitle(fBot);
  fPooling.OnMessage := procedure(AMsg: TtgMessage)
    begin
      DoReadMessage(AMsg);
    end;
  fPooling.Start;
end;

function TDemoPooling.ReadToken: string;
var
  lFileToken: string;
begin
  lFileToken := ChangeFileExt(Executable.ProgramFileName, '.token');
  if TFile.Exists(lFileToken) then
    Result := TFile.ReadAllText(lFileToken);
end;

procedure TDemoPooling.SaveToken(const AToken: string);
var
  lFileToken: string;
begin
  lFileToken := ChangeFileExt(Executable.ProgramFileName, '.token');
  TFile.WriteAllText(lFileToken, AToken);
end;

procedure TDemoPooling.UpdateConsoleTitle(ABot: TTelegramBotApi);
var
  lUser: TtgUser;
begin
  lUser := ABot.GetMe.Result;
  try
    SetConsoleTitle(pwideChar(lUser.Username));
  finally
    // lUser.Free; <-- Autofree in TelegaPi core
  end;
end;

end.
