unit Controller.Produto;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Model.Produto;

type
  TProdutoController = class
  public
    function Salvar(const AProduto: TProduto): string;
    procedure Excluir(AId: Integer);
    function BuscarPorId(AId: Integer): TProduto;
    function Listar: TObjectList<TProduto>;
  end;

implementation

function TProdutoController.Salvar(const AProduto: TProduto): string;
begin
  Result := '';
  if AProduto.Id = 0 then
    TProdutoDAO.Inserir(AProduto)
  else
    TProdutoDAO.Atualizar(AProduto);
end;

procedure TProdutoController.Excluir(AId: Integer);
begin
  TProdutoDAO.Excluir(AId);
end;

function TProdutoController.BuscarPorId(AId: Integer): TProduto;
begin
  Result := TProdutoDAO.BuscarPorId(AId);
end;

function TProdutoController.Listar: TObjectList<TProduto>;
begin
  Result := TProdutoDAO.Listar('descricao');
end;

end.
