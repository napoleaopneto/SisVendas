unit Model.Pedido;

interface

uses
  System.SysUtils, System.Generics.Collections,
  FireDAC.Comp.Client,
  Model.BaseDAO, Model.ItemPedido, Model.Connection;

type
  TPedido = class(TEntidade)
  private
    FDataEmissao: TDateTime;
    FClienteId: Integer;
    FNomeCliente: string;
    FItens: TObjectList<TItemPedido>;
    function GetTotal: Currency;
  public
    constructor Create;
    destructor Destroy; override;

    // Fluent
    function ParaCliente(AClienteId: Integer): TPedido;
    function ComNomeCliente(const ANome: string): TPedido;
    function EmitidoEm(ADataEmissao: TDateTime): TPedido;
    function ComItem(AProdutoId: Integer;
                     AQuantidade: Double;
                     AValorUnitario: Currency): TPedido;
    function ComId(AId: Integer): TPedido;

    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property ClienteId: Integer read FClienteId write FClienteId;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property Itens: TObjectList<TItemPedido> read FItens;
    property Total: Currency read GetTotal;

    procedure DoDataset(Q: TFDQuery); override;
    procedure ParaParams(Q: TFDQuery); override;
    class function NomeTabela: string; override;
    class function CamposInsert: string; override;
    class function CamposUpdate: string; override;
  end;

  TPedidoDAO = class(TBaseDAO<TPedido>)
  public
    class procedure Salvar(const APedido: TPedido);
    class function CarregarCompleto(AId: Integer): TPedido;
    class function ListarComCliente: TObjectList<TPedido>;
  end;

implementation

{ TPedido }

constructor TPedido.Create;
begin
  inherited;
  FItens := TObjectList<TItemPedido>.Create(True);
  FDataEmissao := Now;
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  inherited;
end;

function TPedido.GetTotal: Currency;
var
  Item: TItemPedido;
begin
  Result := 0;
  for Item in FItens do
    Result := Result + Item.Subtotal;
end;

function TPedido.ParaCliente(AClienteId: Integer): TPedido;
begin
  FClienteId := AClienteId;
  Result     := Self;
end;

function TPedido.ComNomeCliente(const ANome: string): TPedido;
begin
  FNomeCliente := ANome;
  Result       := Self;
end;

function TPedido.EmitidoEm(ADataEmissao: TDateTime): TPedido;
begin
  FDataEmissao := ADataEmissao;
  Result       := Self;
end;

function TPedido.ComItem(AProdutoId: Integer;
                         AQuantidade: Double;
                         AValorUnitario: Currency): TPedido;
var
  Item: TItemPedido;
begin
  Item := TItemPedido.Create;
  Item
    .DoProduto(AProdutoId)
    .ComQuantidade(AQuantidade)
    .ComValorUnitario(AValorUnitario);
  FItens.Add(Item);
  Result := Self;
end;

function TPedido.ComId(AId: Integer): TPedido;
begin
  FId    := AId;
  Result := Self;
end;

class function TPedido.NomeTabela: string;
begin
  Result := 'pedidos';
end;

class function TPedido.CamposInsert: string;
begin
  Result := '(data_emissao, cliente_id, total) ' +
            'VALUES (:data, :cliente_id, :total)';
end;

class function TPedido.CamposUpdate: string;
begin
  Result := 'data_emissao = :data, cliente_id = :cliente_id, total = :total';
end;

procedure TPedido.DoDataset(Q: TFDQuery);
begin
  FDataEmissao := Q.FieldByName('data_emissao').AsDateTime;
  FClienteId   := Q.FieldByName('cliente_id').AsInteger;
end;

procedure TPedido.ParaParams(Q: TFDQuery);
begin
  Q.ParamByName('data').AsDateTime      := FDataEmissao;
  Q.ParamByName('cliente_id').AsInteger := FClienteId;
  Q.ParamByName('total').AsCurrency     := GetTotal;
end;

{ TPedidoDAO }

class procedure TPedidoDAO.Salvar(const APedido: TPedido);
var
  Conn: TFDConnection;
  Item: TItemPedido;
  Q: TFDQuery;
begin
  if APedido.Itens.Count = 0 then
    raise Exception.Create('Pedido deve ter pelo menos um item');

  Conn := TConnection.Get;
  Conn.StartTransaction;
  try
    if APedido.Id = 0 then
      Inserir(APedido)
    else
      Atualizar(APedido);

    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'DELETE FROM pedido_itens WHERE pedido_id = :id';
      Q.ParamByName('id').AsInteger := APedido.Id;
      Q.ExecSQL;
    finally
      Q.Free;
    end;

    for Item in APedido.Itens do
    begin
      Item.NoPedido(APedido.Id);
      TBaseDAO<TItemPedido>.Inserir(Item);
    end;

    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

class function TPedidoDAO.CarregarCompleto(AId: Integer): TPedido;
var
  Q: TFDQuery;
  Item: TItemPedido;
begin
  Result := BuscarPorId(AId);
  if not Assigned(Result) then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := 'SELECT nome FROM clientes WHERE id = :id';
    Q.ParamByName('id').AsInteger := Result.ClienteId;
    Q.Open;
    if not Q.Eof then
      Result.NomeCliente := Q.FieldByName('nome').AsString;

    Q.SQL.Text :=
      'SELECT i.*, p.descricao AS desc_prod ' +
      'FROM pedido_itens i ' +
      'JOIN produtos p ON p.id = i.produto_id ' +
      'WHERE i.pedido_id = :id';
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    while not Q.Eof do
    begin
      Item := TItemPedido.Create;
      Item
        .NoPedido(Q.FieldByName('pedido_id').AsInteger)
        .DoProduto(Q.FieldByName('produto_id').AsInteger)
        .ComQuantidade(Q.FieldByName('quantidade').AsFloat)
        .ComValorUnitario(Q.FieldByName('valor_unitario').AsCurrency)
        .ComDescricaoProduto(Q.FieldByName('desc_prod').AsString);
      Item.Id := Q.FieldByName('id').AsInteger;
      Result.Itens.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

class function TPedidoDAO.ListarComCliente: TObjectList<TPedido>;
var
  Q: TFDQuery;
  Pedido: TPedido;
begin
  Result := TObjectList<TPedido>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text :=
      'SELECT p.*, c.nome AS nome_cliente ' +
      'FROM pedidos p ' +
      'JOIN clientes c ON c.id = p.cliente_id ' +
      'ORDER BY p.id DESC';
    Q.Open;
    while not Q.Eof do
    begin
      Pedido := TPedido.Create;
      Pedido
        .ComId(Q.FieldByName('id').AsInteger)
        .ParaCliente(Q.FieldByName('cliente_id').AsInteger)
        .ComNomeCliente(Q.FieldByName('nome_cliente').AsString)
        .EmitidoEm(Q.FieldByName('data_emissao').AsDateTime);
      Result.Add(Pedido);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
