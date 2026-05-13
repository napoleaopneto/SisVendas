unit Controller.Cliente;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Model.Cliente;

type
  TClienteController = class
  public
    function Salvar(const ACliente: TCliente): string;
    procedure Excluir(AId: Integer);
    function BuscarPorId(AId: Integer): TCliente;
    function Listar: TObjectList<TCliente>;
  end;

implementation

function TClienteController.Salvar(const ACliente: TCliente): string;
var
  Existente: TCliente;
begin
  Result := '';
  Existente := TClienteDAO.BuscarPorDocumento(ACliente.Documento);
  try
    if Assigned(Existente) and (Existente.Id <> ACliente.Id) then
      Exit('Já existe cliente com este documento');
  finally
    Existente.Free;
  end;

  if ACliente.Id = 0 then
    TClienteDAO.Inserir(ACliente)
  else
    TClienteDAO.Atualizar(ACliente);
end;

procedure TClienteController.Excluir(AId: Integer);
begin
  TClienteDAO.Excluir(AId);
end;

function TClienteController.BuscarPorId(AId: Integer): TCliente;
begin
  Result := TClienteDAO.BuscarPorId(AId);
end;

function TClienteController.Listar: TObjectList<TCliente>;
begin
  Result := TClienteDAO.Listar('descricao');
end;

end.
