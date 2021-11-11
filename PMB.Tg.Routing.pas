unit PMB.Tg.Routing;

interface

uses
  TelegramBotApi.Router, TelegramBotApi.Client, TelegramBotApi.Types;

type
  TRouterBuilder = class
  private
    FRouter: TtgRouter;
    FBot: TTelegramBotApi;
  protected
    procedure SendTextMessage(const UserLink: TtgUserLink; const MsgText: string);
  protected

    function RouteStart: TtgRoute;
    function RouteGetGeo: TtgRoute;

  public
    procedure Build;
    constructor Create(ARouter: TtgRouter; ABot: TTelegramBotApi);
    destructor Destroy; override;
  end;

implementation

uses
  PMB.Log,
  System.SysUtils,
  TelegramBotApi.Types.Enums, TelegramBotApi.Types.Request;

{ TRouterBuilder }

procedure TRouterBuilder.Build;
begin
  FRouter.RegisterRoutes([RouteStart, RouteGetGeo]);
end;

constructor TRouterBuilder.Create(ARouter: TtgRouter; ABot: TTelegramBotApi);
begin
  inherited Create();
  FRouter := ARouter;
  FBot := ABot;
  Build;
end;

destructor TRouterBuilder.Destroy;
begin

  inherited Destroy;
end;

function TRouterBuilder.RouteGetGeo: TtgRoute;
begin
  Result := TtgRoute.Create('/geo');
  Result.OnStartCallback := procedure(AUserID: Int64)
    begin

    end;
  Result.OnMessageCallback := procedure(AMsg: TtgMessage)
    begin
      if AMsg.&Type <> TtgMessageType.Location then
      begin
        SendTextMessage(AMsg.Chat.ID, ':le rfhd')
      end;
    end;
end;

function TRouterBuilder.RouteStart: TtgRoute;
begin
  Result := TtgRoute.Create('/start');
  Result.OnMessageCallback := procedure(AMsg: TtgMessage)
    begin
      if AMsg.Text = RouteStart.Name then
        FRouter.MoveTo(AMsg.From.ID, RouteGetGeo);
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
