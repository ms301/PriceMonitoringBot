unit PMB.Orm.Model;

interface

uses
  mormot.Orm.core, mormot.core.base, mormot.Orm.base;

const
  HttpPort = '11111';

type
  TOrmSample = class(TOrm)
  private
    FName: RawUTF8;
    FQuestion: RawUTF8;
    FTime: TModTime;
  published
    property Name: RawUTF8 read FName write FName;
    property Question: RawUTF8 read FQuestion write FQuestion;
    property Time: TModTime read FTime write FTime;
  end;

  TOrmLocation = class(TOrm)
  private
    FUserID: Int64;
    // [JsonName('longitude')]
    FLongitude: Double;
    // [JsonName('latitude')]
    FLatitude: Double;
    FTime: TModTime;
  published
    property UserID: Int64 read FUserID write FUserID;
    /// <summary>Longitude as defined by sender</summary>
    property Longitude: Double read FLongitude write FLongitude;
    /// <summary>
    /// Latitude as defined by sender
    /// </summary>
    property Latitude: Double read FLatitude write FLatitude;
    property Time: TModTime read FTime write FTime;
  end;

  TOrmTag = class(TOrm)
  private
    FName: RawUTF8;
    FUserID: Int64;
    FTime: TModTime;
  published
    property Name: RawUTF8 read FName write FName;
    property UserID: Int64 read FUserID write FUserID;
    property Time: TModTime read FTime write FTime;
  end;

function CreateSampleModel: TOrmModel;

implementation

function CreateSampleModel: TOrmModel;
begin
  result := TOrmModel.Create([TOrmSample, TOrmLocation, TOrmTag]);
end;

end.
