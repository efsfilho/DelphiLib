unit uSql;

interface
  uses FireDAC.Stan.Error, System.SysUtils;

  function MySqlErro(erro: EFDDBEngineException): string;
implementation

function MySqlErro(erro: EFDDBEngineException): string;
var
  Pos1, Pos2: Integer;
  eMsg: string;
begin
  eMsg := '-';
  case erro.ErrorCode of
    1054: // Error: 1054 Unknown column '%s' in '%s'
    begin
//      Pos1     := AnsiPos('select', erro.SQL);
      eMsg := erro.Message;
      Pos1 := AnsiPos('column ', eMsg) + 7;
      Pos2 := AnsiPos(' in'    , eMsg) - Pos1;
      eMsg := Copy(eMsg, Pos1, Pos2);
      if erro.SQL.Contains('select') or erro.SQL.Contains('SELECT') then
      begin
        eMsg := 'Select: Campo desconhecido '+eMsg;
      end;
      if erro.SQL.Contains('insert') or erro.SQL.Contains('INSERT') then
      begin
        eMsg := 'Insert: Campo desconhecido '+eMsg;
      end;
    end;
    1064: // Message: %s near '%s' at line %d
    begin
      eMsg := 'Erro de sintaxe dsdfsdg';
    end;
  end;
  Result := eMsg;
end;
end.
