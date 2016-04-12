unit uMySqlError;

interface
  uses FireDAC.Stan.Error, System.SysUtils;

  function Teste(erro: EFDDBEngineException): string;
implementation

function Teste(erro: EFDDBEngineException): string;
var
  Pos1, Pos2: Integer;
  eMessage: string;
begin
  eMessage := '-';
  case erro.ErrorCode of
    1054:
    begin
      eMessage := erro.Message;
      Pos1   := AnsiPos('column ', eMessage) + 7;
      Pos2   := AnsiPos(' in', eMessage) - Pos1;
      eMessage := Copy(eMessage, Pos1, Pos2);
      // Error: 1054 Unknown column '%s' in '%s'
      eMessage := 'Campo desconhecido '+eMessage;
    end;
    1064:
    begin
      eMessage := 'Erro de sintaxe';
    end;
  end;
  Result := eMessage;
end;
end.
