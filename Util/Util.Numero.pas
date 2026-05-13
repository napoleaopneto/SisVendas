unit Util.Numero;

interface

function ParseValor(const ATexto: string): Currency;
function FormatarValor(AValor: Currency): string;

implementation

uses
  System.SysUtils;

function ParseValor(const ATexto: string): Currency;
var
  Limpo: string;
begin
  Limpo := StringReplace(ATexto, '.', '', [rfReplaceAll]);
  Limpo := StringReplace(Limpo, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToCurrDef(Limpo, 0);
end;

function FormatarValor(AValor: Currency): string;
begin
  Result := FormatFloat('#,##0.00', AValor);
end;

end.
