unit uFiles;

interface
uses SysUtils;
  procedure WriteInFile(tx, dir: string);

implementation

procedure WriteInFile(tx, dir: string);
var
  F:textfile;
begin
  Assignfile(F,dir);
  if not FileExists(dir) Then
    begin
      Rewrite(f);
    end
  else
  begin
    Append(F);
  end;
  Writeln(F,tx);
  Closefile(F);
end;

end.
