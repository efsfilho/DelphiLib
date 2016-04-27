program DelphiLib;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uCopier in 'uCopier.pas',
  uThread in 'uThread.pas',
  uSql in 'uSql.pas',
  uFiles in 'uFiles.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
