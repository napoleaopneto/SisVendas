unit Controller.Pedido;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Model.Pedido;

type
  TPedidoController = class
  public
    function Salvar(const APedido: TPedido): string;
    procedure Excluir(AId: Integer);
    function CarregarCompleto(AId: Integer): TPedido;
    function Listar: TObjectList<TPedido>;
  end;

implementation

function TPedidoController.Salvar(const APedido: TPedido): string;
begin
  Result := '';
  try
    TPedidoDAO.Salvar(APedido);
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

procedure TPedidoController.Excluir(AId: Integer);
begin
  TPedidoDAO.Excluir(AId);
end;

function TPedidoController.CarregarCompleto(AId: Integer): TPedido;
begin
  Result := TPedidoDAO.CarregarCompleto(AId);
end;

function TPedidoController.Listar: TObjectList<TPedido>;
begin
  Result := TPedidoDAO.ListarComCliente;
end;

end.
