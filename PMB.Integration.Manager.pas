unit PMB.Integration.Manager;

interface

uses
  PMB.Integration.Intfc,
  System.Generics.Collections;

type
  TpmbMarketManager = class
  private
    FMarkets: TDictionary<string, IpmbMarket>;
  public
    procedure Add(AMarket: IpmbMarket);
    constructor Create;
    destructor Destroy; override;

  end;

implementation

{ TpmbMarketManager }

procedure TpmbMarketManager.Add(AMarket: IpmbMarket);
begin
  if FMarkets.ContainsKey(AMarket.ToString) then
    FMarkets.Remove(AMarket.ToString);
  FMarkets.Add(AMarket.ToString, AMarket);
end;

constructor TpmbMarketManager.Create;
begin
  FMarkets := TDictionary<string, IpmbMarket>.Create;
end;

destructor TpmbMarketManager.Destroy;
begin
  FMarkets.Free;
  inherited;
end;

end.
