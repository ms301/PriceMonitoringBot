unit PMB.Integration.Intfc;

interface

type
  IpmbMarket = interface
    ['{0FF90101-DD4C-4391-96ED-E0BFD5D10F16}']
    function AvaibleInCity(const ACityName: string): Boolean;
    function ToString: string;
  end;

implementation

end.
