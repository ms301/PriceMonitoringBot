unit PMB.Tg.Routing;

interface

uses
  TelegramBotApi.Router,
  TelegramBotApi.Client,
  TelegramBotApi.Types.Keyboards,
  TelegramBotApi.Types,
  mormot.rest.sqlite3;

type
  TRouterBuilder = class
  private
    FRouter: TtgRouter;
    FBot: TTelegramBotApi;
    FDb: TRestClientDB;
  protected
    procedure SendTextMessage(const UserLink: TtgUserLink; const MsgText: string);
    procedure SendReplyKeyboard(AMsg: TtgMessage); overload;
    procedure SendReplyKeyboard(const UserLink: TtgUserLink; const MsgText: string;
      Kb: TtgReplyKeyboardMarkup); overload;
  protected
    procedure RegisterMenu;
    function RouteStart: TtgRoute;
    function RouteHelp: TtgRoute;
    function RouteGetGeo: TtgRoute;
    function RouteBestPrice: TtgRoute;
  public
    procedure Build;
    constructor Create(ARouter: TtgRouter; ABot: TTelegramBotApi; ADb: TRestClientDB);
    destructor Destroy; override;
  end;

implementation

uses
  PMB.Log,
  System.SysUtils,
  TelegramBotApi.Types.Enums,
  TelegramBotApi.Types.Request,
  PMB.Orm.Model;

{ TRouterBuilder }

procedure TRouterBuilder.Build;
begin
  FRouter.RegisterRoutes([RouteStart, RouteHelp, RouteGetGeo, RouteBestPrice]);
end;

constructor TRouterBuilder.Create(ARouter: TtgRouter; ABot: TTelegramBotApi; ADb: TRestClientDB);
begin
  inherited Create();
  FRouter := ARouter;
  FBot := ABot;
  FDb := ADb;
  Build;
  RegisterMenu;
end;

destructor TRouterBuilder.Destroy;
begin

  inherited Destroy;
end;

procedure TRouterBuilder.RegisterMenu;
var
  LSetMyCommands: TtgSetMyCommandsArgument;
  LResult: ItgResponse<Boolean>;
begin
  LSetMyCommands := TtgSetMyCommandsArgument.Create;
  try
    LSetMyCommands.Commands := [ //
      TtgBotCommand.Create(RouteStart.Name.Substring(1), 'Start command'), //
      TtgBotCommand.Create(RouteHelp.Name.Substring(1), 'Help command'), //
      TtgBotCommand.Create(RouteGetGeo.Name.Substring(1), 'Указать местоположение'), //
      TtgBotCommand.Create(RouteGetGeo.Name.Substring(1), 'Найти лучшую цену на товар')];
    LSetMyCommands.Scope := TtgBotCommandScopeDefault.Create;
    LResult := FBot.SetMyCommands(LSetMyCommands);
  finally
    LSetMyCommands.Free;
  end;
end;

function TRouterBuilder.RouteBestPrice: TtgRoute;
begin
  Result := TtgRoute.Create('/best_price');
end;

function TRouterBuilder.RouteGetGeo: TtgRoute;
begin
  Result := TtgRoute.Create('/geo');
  Result.OnStartCallback := procedure(AUserID: Int64)
    begin

    end;
  Result.OnMessageCallback := procedure(AMsg: TtgMessage)
    var
      LOrmLocation: TOrmLocation;
    begin
      if AMsg.&Type <> TtgMessageType.Location then
      begin
        SendTextMessage(AMsg.Chat.ID, 'Ожидаю карту');
        Exit;
      end;
      LOrmLocation := TOrmLocation.Create;
      try
        LOrmLocation.Longitude := AMsg.Location.Longitude;
        LOrmLocation.Latitude := AMsg.Location.Latitude;
        LOrmLocation.UserID := AMsg.From.ID;
        FDb.Add(LOrmLocation, True);
        SendTextMessage(AMsg.Chat.ID, 'Map saved');
        FRouter.MoveTo(AMsg.From.ID, RouteBestPrice);
      finally
        LOrmLocation.Free;
      end;
    end;
end;

function TRouterBuilder.RouteHelp: TtgRoute;
begin
  Result := TtgRoute.Create('/help');
end;

function TRouterBuilder.RouteStart: TtgRoute;
begin
  Result := TtgRoute.Create('/start');
  Result.OnMessageCallback := procedure(AMsg: TtgMessage)
    const
      MSG_WELCOME = 'Привет, %s, я помогу тебе сравнить цены. ' +
        'Пришли мне свое местоположение, что бы я мог сравнивать цены в твоем городе';
    var
      LMsgWelcome: string;
      lKB: TtgReplyKeyboardMarkup;
      lBtnUpdateGEO: TtgKeyboardButton;
    begin
      LMsgWelcome := Format(MSG_WELCOME, [AMsg.From.FirstName]);
      if AMsg.Text = RouteStart.Name then
      begin
        lKB := TtgReplyKeyboardMarkup.Create;
        lBtnUpdateGEO := TtgKeyboardButton.Create;
        try
          lBtnUpdateGEO.Text := '📍 Местоположение';
          lBtnUpdateGEO.RequestLocation := True;
          lKB.AddRow([lBtnUpdateGEO]);
          SendReplyKeyboard(AMsg.Chat.ID, LMsgWelcome, lKB);
          FRouter.MoveTo(AMsg.From.ID, RouteGetGeo);
        finally
          // lKB.Free;     <-- Autofree in TelegaPi core
        end;
      end;
    end;
end;

procedure TRouterBuilder.SendReplyKeyboard(AMsg: TtgMessage);
var
  lKB: TtgReplyKeyboardMarkup;
  lBtnUpdateGEO: TtgKeyboardButton;
  lMsg: TtgMessageArgument;
begin
  lMsg := TtgMessageArgument.Create;
  lKB := TtgReplyKeyboardMarkup.Create;

  lBtnUpdateGEO := TtgKeyboardButton.Create;
  try
    lBtnUpdateGEO.Text := 'Местоположение';
    lKB.AddRow([lBtnUpdateGEO]);
    lMsg.ChatId := AMsg.Chat.ID;
    lMsg.Text := 'Choose';
    lMsg.ReplyMarkup := lKB;
    FBot.SendMessage(lMsg);
  finally
    lMsg.Free;
    // lKB.Free;     <-- Autofree in TelegaPi core
  end;
end;

procedure TRouterBuilder.SendReplyKeyboard(const UserLink: TtgUserLink; const MsgText: string;
  Kb: TtgReplyKeyboardMarkup);
var
  lMsg: TtgMessageArgument;
begin
  lMsg := TtgMessageArgument.Create;
  try
    lMsg.ChatId := UserLink;
    lMsg.Text := MsgText;
    lMsg.ReplyMarkup := Kb;
    FBot.SendMessage(lMsg);
  finally
    lMsg.Free;
    // lKB.Free;     <-- Autofree in TelegaPi core
  end;
end;

procedure TRouterBuilder.SendTextMessage(const UserLink: TtgUserLink; const MsgText: string);
var
  lMsg: TtgMessageArgument;
begin
  lMsg := TtgMessageArgument.Create;
  try
    lMsg.ChatId := UserLink;
    lMsg.Text := MsgText;
    FBot.SendMessage(lMsg);
  finally
    lMsg.Free;
  end;
end;

end.
