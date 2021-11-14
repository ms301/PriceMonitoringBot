unit Unit1;

interface

uses
  TelegramBotApi.Router;

type
  TtgRouteUserStateManagerRAM = class(TtgRouteUserStateManagerAbstract)
  private
    // FRouteUserStates: TDictionary<Int64, string>;
  protected
    function DoGetUserState(const AUserID: Int64): string; override;
    procedure DoSetUserState(const AIndex: Int64; const Value: string); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

{ TtgRouteUserStateManagerRAM }

constructor TtgRouteUserStateManagerRAM.Create;
begin

end;

destructor TtgRouteUserStateManagerRAM.Destroy;
begin

  inherited;
end;

function TtgRouteUserStateManagerRAM.DoGetUserState(const AUserID: Int64): string;
begin

end;

procedure TtgRouteUserStateManagerRAM.DoSetUserState(const AIndex: Int64; const Value: string);
begin
  inherited;

end;

end.
