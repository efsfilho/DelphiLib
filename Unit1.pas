unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,ShellAPI;

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
  flagB : Boolean = False;

implementation

uses
  uCopier, uThread;

type
  TCopyEx = packed record
    Source: String[255];
    Dest:   String[255];
    Handle: THandle;
  end;
  PCopyEx = ^TCopyEx;

const
  CEXM_CANCEL    =  WM_USER + 1;
  CEXM_CONTINUE  =  WM_USER + 2; // wParam: lopart, lParam: hipart
  CEXM_MAXBYTES  =  WM_USER + 3; // wParam: lopart; lParam: hipart

var
  abc : Integer;
  LThread : TThreadList;

{$R *.dfm}


function TForm1.Teste:Boolean;
begin
  ShowMessage('lsdkjhf');
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
begin

//  foo.AddProcedure(ExibeTeste);
//  foo.AddProcedure(ExibeTeste);
//  foo.AddProcedure(ExibeTeste);
//  foo.StartProcedures(1000);
//  Label2.Caption := IntToStr(foo.idade);

  Label2.Caption := FormatFileSize(DirSize('C:/Users/Eduardo/Desktop/teste',False));

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
