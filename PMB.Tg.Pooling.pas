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
  const
    BOT_TOKEN = '1225990942:AAEfSINTq5fMdAOiswxNScZ8wQUDD_5KDYQ';
  private
    fBot: TTelegramBotApi;
    fPooling: TtgPollingConsole;
    FRouter: TtgRouter;
    FRouteUsersState: TtgRouteUserStateManagerRAM;
    FRouterBuilder: TRouterBuilder;
  protected
    procedure UpdateConsoleTitle(ABot: TTelegramBotApi);

    procedure DoReadMessage(AMsg: TtgMessage);
  public
    procedure Main;
    constructor Create(ADb: TRestClientDB);
    destructor Destroy; override;

  end;

implementation

uses
  System.Rtti,
  PMB.Log,
  TelegramBotApi.Types.Enums,
  TelegramBotApi.Types.Request,
  TelegramBotApi.Types.Keyboards,
  Winapi.Windows, CloudAPI.Exceptions;

constructor TDemoPooling.Create(ADb: TRestClientDB);
begin
  fBot := TTelegramBotApi.Create(BOT_TOKEN);

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
