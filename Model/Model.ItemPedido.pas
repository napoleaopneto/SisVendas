unit Model.ItemPedido;

interface

uses
  FireDAC.Comp.Client,
  Model.BaseDAO;

type
  TItemPedido = class(TEntidade)
  private
    FPedidoId: Integer;
    FProdutoId: Integer;
    FQuantidade: Double;
    FValorUnitario: Currency;
    FDescricaoProduto: string;
  public
    function NoPedido(APedidoId: Integer): TItemPedido;
    function DoProduto(AProdutoId: Integer): TItemPedido;
    function ComQuantidade(AQtd: Double): TItemPedido;
    function ComValorUnitario(AValor: Currency): TItemPedido;
    function ComDescricaoProduto(const ADesc: string): TItemPedido;

    property PedidoId: Integer read FPedidoId write FPedidoId;
    property ProdutoId: Integer read FProdutoId write FProdutoId;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    function Subtotal: Currency;

    procedure DoDataset(Q: TFDQuery); override;
    procedure ParaParams(Q: TFDQuery); override;
    class function NomeTabela: string; override;
    class function CamposInsert: string; override;
    class function CamposUpdate: string; override;
  end;

implementation

{ TItemPedido }

function TItemPedido.NoPedido(APedidoId: Integer): TItemPedido;
begin
  FPedidoId := APedidoId;
  Result    := Self;
end;

function TItemPedido.DoProduto(AProdutoId: Integer): TItemPedido;
begin
  FProdutoId := AProdutoId;
  Result     := Self;
end;

function TItemPedido.ComQuantidade(AQtd: Double): TItemPedido;
begin
  FQuantidade := AQtd;
  Result      := Self;
end;

function TItemPedido.ComValorUnitario(AValor: Currency): TItemPedido;
begin
  FValorUnitario := AValor;
  Result         := Self;
end;

function TItemPedido.ComDescricaoProduto(const ADesc: string): TItemPedido;
begin
  FDescricaoProduto := ADesc;
  Result            := Self;
end;

function TItemPedido.Subtotal: Currency;
begin
  Result := FQuantidade * FValorUnitario;
end;

class function TItemPedido.NomeTabela: string;
begin
  Result := 'pedido_itens';
end;

class function TItemPedido.CamposInsert: string;
begin
  Result := '(pedido_id, produto_id, quantidade, valor_unitario) ' +
            'VALUES (:pedido_id, :produto_id, :qtd, :valor)';
end;

class function TItemPedido.CamposUpdate: string;
begin
  Result := 'pedido_id = :pedido_id, produto_id = :produto_id, ' +
            'quantidade = :qtd, valor_unitario = :valor';
end;

procedure TItemPedido.DoDataset(Q: TFDQuery);
begin
  FPedidoId      := Q.FieldByName('pedido_id').AsInteger;
  FProdutoId     := Q.FieldByName('produto_id').AsInteger;
  FQuantidade    := Q.FieldByName('quantidade').AsFloat;
  FValorUnitario := Q.FieldByName('valor_unitario').AsCurrency;
end;

procedure TItemPedido.ParaParams(Q: TFDQuery);
begin
  Q.ParamByName('pedido_id').AsInteger  := FPedidoId;
  Q.ParamByName('produto_id').AsInteger := FProdutoId;
  Q.ParamByName('qtd').AsFloat          := FQuantidade;
  Q.ParamByName('valor').AsCurrency     := FValorUnitario;
end;

end.
