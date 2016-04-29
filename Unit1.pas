unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,ShellAPI,
    COMObj, Winapi.MSXML, Vcl.Touch.Keyboard, Vcl.OleCtrls, SHDocVw; // XML

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    lbl1: TLabel;
    pb1: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    WebBrowser1: TWebBrowser;

    procedure Edit1Click(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ExibeTeste;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function Teste:Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uCopier, uThread, uFiles;

{$R *.dfm}


function TForm1.Teste:Boolean;
begin
  ShowMessage('Messa  ');
end;

procedure TForm1.ExibeTeste;
var i: Integer;
begin
  with pb1 do
  begin
    Position := 0;
    Min  := 0;
    Max  := 100;
    Step := 10;
    while Position < Max do
    begin
      StepIt;
//      Position := position + 1;
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  StopProcedures;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  ohttp: IXMLHTTPRequest;
  FResponseText, lUrl: string;
begin

  // Not Working
  ohttp := CreateOleObject('MSXML2.XMLHTTP.3.0') as IXMLHTTPRequest;
  lUrl := 'https://geo.query.yahoo.com/v1/public/yql?yhlVer=2&yhlClient=rapid&yhlS=1184300006&yhlCT=2&yhlBTMS=1461615725039&yhlClientVer=3.18.3&yhlRnd=3w7YuS3NFxNDpoo1&yhlCompressed=3';
  try
//    oXMLHTTP.open('OPEN', URL, False, FUserName, FPassword);
    ohttp.open('OPEN', lUrl, False, False, False);
    ohttp.setRequestHeader('Content-Type','text/xml');
    ohttp.send(EmptyParam);

//    // FResponseText contains the reply from your webdav server!!
    FResponseText := Trim(ohttp.ResponseText);
//    WriteInFile(Trim(ohttp.responseXML), 'C:/Users/Eduardo/Desktop/page.html');
  finally
    ohttp := nil;
  end;


//  foo.AddProcedure(ExibeTeste);
//  foo.AddProcedure(ExibeTeste);
//  foo.AddProcedure(ExibeTeste);
//  foo.StartProcedures(1000);
//  Label2.Caption := FormatFileSize(DirSize('C:/Users/Eduardo/Desktop/teste',False));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
//  ShowMessage(BoolToStr(flagB));

end;

procedure TForm1.Edit1Click(Sender: TObject);
var
  Path    : String;
  SR      : TSearchRec;
  DirList : TStrings;
begin
  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
  if not OpenDialog1.Execute then Exit;
  Edit1.Text := OpenDialog1.FileName;

end;

procedure TForm1.Edit2Click(Sender: TObject);
begin
  if not SaveDialog1.Execute then Exit;
  Edit2.Text := SaveDialog1.FileName;
end;

end.
