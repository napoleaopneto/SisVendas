unit Model.Produto;

interface

uses
  FireDAC.Comp.Client,
  Model.BaseDAO;

type
  TProduto = class(TEntidade)
  private
    FDescricao: string;
    FPrecoVenda: Currency;
    FUnidade: string;
  public
    function ComDescricao(const ADescricao: string): TProduto;
    function ComPreco(APreco: Currency): TProduto;
    function ComUnidade(const AUnidade: string): TProduto;
    function ComId(AId: Integer): TProduto;

    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    property Unidade: string read FUnidade write FUnidade;

    procedure DoDataset(Q: TFDQuery); override;
    procedure ParaParams(Q: TFDQuery); override;
    class function NomeTabela: string; override;
    class function CamposInsert: string; override;
    class function CamposUpdate: string; override;
  end;

  TProdutoDAO = class(TBaseDAO<TProduto>);

implementation

{ TProduto }

function TProduto.ComDescricao(const ADescricao: string): TProduto;
begin
  FDescricao := ADescricao;
  Result     := Self;
end;

function TProduto.ComPreco(APreco: Currency): TProduto;
begin
  FPrecoVenda := APreco;
  Result      := Self;
end;

function TProduto.ComUnidade(const AUnidade: string): TProduto;
begin
  FUnidade := AUnidade;
  Result   := Self;
end;

function TProduto.ComId(AId: Integer): TProduto;
begin
  FId    := AId;
  Result := Self;
end;

class function TProduto.NomeTabela: string;
begin
  Result := 'produtos';
end;

class function TProduto.CamposInsert: string;
begin
  Result := '(descricao, preco_venda, unidade) VALUES (:descricao, :preco, :unidade)';
end;

class function TProduto.CamposUpdate: string;
begin
  Result := 'descricao = :descricao, preco_venda = :preco, unidade = :unidade';
end;

procedure TProduto.DoDataset(Q: TFDQuery);
begin
  FDescricao  := Q.FieldByName('descricao').AsString;
  FPrecoVenda := Q.FieldByName('preco_venda').AsCurrency;
  FUnidade    := Q.FieldByName('unidade').AsString;
end;

procedure TProduto.ParaParams(Q: TFDQuery);
begin
  Q.ParamByName('descricao').AsString := FDescricao;
  Q.ParamByName('preco').AsCurrency   := FPrecoVenda;
  Q.ParamByName('unidade').AsString   := FUnidade;
end;

end.
