unit Util.Validador;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Dialogs;

type
  TAcaoSeFalhar = reference to procedure;

  IValidador = interface
    ['{1A2B3C4D-5E6F-7890-ABCD-EF1234567890}']
    function Quando(ACondicao: Boolean; const AMensagem: string): IValidador;
    function FocarEm(AControle: TWinControl): IValidador;
    function Executar(AAcao: TAcaoSeFalhar): IValidador;
    function Valido: Boolean;
    function PrimeiroErro: string;
  end;

  TValidador = class(TInterfacedObject, IValidador)
  private
    FFalhou: Boolean;
    FMensagem: string;
    FControleErro: TWinControl;
    FAcaoErro: TAcaoSeFalhar;
  public
    class function Novo: IValidador;
    function Quando(ACondicao: Boolean; const AMensagem: string): IValidador;
    function FocarEm(AControle: TWinControl): IValidador;
    function Executar(AAcao: TAcaoSeFalhar): IValidador;
    function Valido: Boolean;
    function PrimeiroErro: string;
  end;

implementation

class function TValidador.Novo: IValidador;
begin
  Result := TValidador.Create;
end;

function TValidador.Quando(ACondicao: Boolean; const AMensagem: string): IValidador;
begin
  if not FFalhou and ACondicao then
  begin
    FFalhou       := True;
    FMensagem     := AMensagem;
    FControleErro := nil;
    FAcaoErro     := nil;
  end;
  Result := Self;
end;

function TValidador.FocarEm(AControle: TWinControl): IValidador;
begin
  if FFalhou and (FControleErro = nil) and not Assigned(FAcaoErro) then
    FControleErro := AControle;
  Result := Self;
end;

function TValidador.Executar(AAcao: TAcaoSeFalhar): IValidador;
begin
  if FFalhou and (FControleErro = nil) and not Assigned(FAcaoErro) then
    FAcaoErro := AAcao;
  Result := Self;
end;

function TValidador.Valido: Boolean;
begin
  Result := not FFalhou;
  if FFalhou then
  begin
    ShowMessage(FMensagem);
    if Assigned(FControleErro) and FControleErro.CanFocus then
      FControleErro.SetFocus
    else if Assigned(FAcaoErro) then
      FAcaoErro();
  end;
end;

function TValidador.PrimeiroErro: string;
begin
  if FFalhou then Result := FMensagem else Result := '';
end;

end.
