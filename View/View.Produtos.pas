unit View.Produtos;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  ufPadrao,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.WinXPanels,
  Controller.produto,
  Model.produto,
  Util.Validador,
  Util.Numero;

type
  TViewProdutos = class(TfPadrao)
    lbPrecoVenda: TLabel;
    edtPrecoVenda: TEdit;
    lbUnidade: TLabel;
    edtUnidade: TEdit;
    FDQueryid: TIntegerField;
    FDQuerydescricao: TStringField;
    FDQueryunidade: TStringField;
    FDQuerypreco_venda: TBCDField;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgCellClick(Column: TColumn);
    procedure edtPrecoVendaKeyPress(Sender: TObject; var Key: Char);
    procedure edtPrecoVendaExit(Sender: TObject);
    procedure dbgDblClick(Sender: TObject);
  private
    { Private declarations }
    FController: TProdutoController;
    function SQLListagem: string;
    procedure ListarProdutos();
    function SalvarRegistro(AId: Integer): string;
    procedure LimparCamposEdicao();
    procedure RegistroParaEdicao(AId: Integer);
  public
    { Public declarations }
  end;

var
  ViewProdutos: TViewProdutos;

implementation

{$R *.dfm}

{ TViewProdutos }

procedure TViewProdutos.btnEditarClick(Sender: TObject);
begin
  inherited;
  if btnEditar.caption = 'Editar' then
    RegistroParaEdicao(FDQueryid.asinteger)
  else
  begin
    if not TValidador.Novo
      .Quando(Trim(edtDescricao.Text) = '',  'Descrição obrigatório')
      .FocarEm(edtDescricao)
      .Quando(Trim(edtPrecoVenda.Text) = '', 'Preço de venda obrigatório')
      .FocarEm(edtPrecoVenda)
      .Quando(ParseValor(edtPrecoVenda.Text) <= 0, 'Preço de venda deve ser maior que zero')
      .FocarEm(edtPrecoVenda)
      .Quando(Trim(edtUnidade.Text) = '',    'Unidade obrigatório')
      .FocarEm(edtUnidade)
      .Valido then
    Exit;

    if edtCodigo.Text = '' then
      SalvarRegistro(0)
    else
      SalvarRegistro(StrToInt(edtCodigo.Text));

    CardPanel.ActiveCard := plista;
    btnNovo.Enabled := true;
    btnEditar.Enabled := false;
    btnExcluir.Enabled := false;
    btnCancelar.Enabled := false;
    btnsair.Enabled := true;
  end;
end;

procedure TViewProdutos.btnExcluirClick(Sender: TObject);
begin
  inherited;
  if FDQuery.IsEmpty then
    Exit;
  if MessageDlg('Confirma a exclusão do registro?',mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
  begin
    btnExcluir.enabled := false;
    Exit;
  end;
  try
    FController.Excluir(FDQueryid.AsInteger);
    ListarProdutos;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir: ' + E.Message);
  end;
end;

procedure TViewProdutos.btnNovoClick(Sender: TObject);
begin
  inherited;
  LimparCamposEdicao();
end;

procedure TViewProdutos.dbgCellClick(Column: TColumn);
begin
  inherited;
  btnExcluir.enabled := true;
  btnEditar.enabled := true;
end;

procedure TViewProdutos.dbgDblClick(Sender: TObject);
begin
  inherited;
  if Not FShowMenu then
    ModalResult := mrOk;
end;

procedure TViewProdutos.edtPrecoVendaExit(Sender: TObject);
var Valor: Currency;
begin
  if Trim(edtPrecoVenda.Text) = '' then
    Exit;
  Valor := StrToCurrDef(edtPrecoVenda.Text, 0);
  edtPrecoVenda.Text := FormatFloat('#,##0.00', Valor);
end;

procedure TViewProdutos.edtPrecoVendaKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if not (CharInSet(Key, ['0'..'9', ',', #8])) then
  begin
    Key := #0;
    Exit;
  end;
  if (Key = ',') and (Pos(',', edtPrecoVenda.Text) > 0) then
    Key := #0;
end;

procedure TViewProdutos.FormCreate(Sender: TObject);
begin
  inherited;
  FController := TProdutoController.Create;
end;

procedure TViewProdutos.FormDestroy(Sender: TObject);
begin
  inherited;
  FController.Free;
end;

procedure TViewProdutos.FormShow(Sender: TObject);
begin
  inherited;
  ListarProdutos
end;

procedure TViewProdutos.LimparCamposEdicao;
begin
  edtcodigo.clear;
  edtDescricao.Clear;
  edtPrecoVenda.Clear;
  edtUnidade.Clear;
end;

procedure TViewProdutos.ListarProdutos;
begin
  FDQuery.SQL.Text := SQLListagem;
  FDQuery.open;
  lbTotal.caption := 'Total: ' + FDQuery.recordcount.tostring;
end;

procedure TViewProdutos.RegistroParaEdicao(AId: Integer);
var Produto: TProduto;
begin
  Produto := FController.BuscarPorId(AId);
  if not Assigned(Produto) then Exit;
  try
    edtCodigo.Text     := Produto.id.ToString;
    edtDescricao.Text  := Produto.Descricao;
    edtPrecoVenda.Text := FormatFloat('#,##0.00', Produto.PrecoVenda);
    edtUnidade.Text    := Produto.Unidade;
    CardPanel.activecard := pcadastro;
    btnEditar.caption := 'Gravar';
    btnNovo.enabled := false;
    btnEditar.enabled := true;
    btnexcluir.enabled := false;
    btnCancelar.enabled := true;
    btnSair.enabled := false;
  finally
    Produto.Free;
  end;
end;

function TViewProdutos.SalvarRegistro(AId: Integer): string;
var Produto: TProduto;
begin
  Produto := TProduto.Create
    .ComId(AId)
    .ComDescricao(edtDescricao.Text)
    .ComPreco(ParseValor(edtPrecoVenda.Text))
    .ComUnidade(edtUnidade.Text);
  try
    Result := FController.Salvar(Produto);
  finally
    Produto.Free;
    LimparCamposEdicao;
    ListarProdutos;
    btnEditar.caption := 'Editar';
    btnSair.enabled := true;
  end;
end;

function TViewProdutos.SQLListagem: string;
begin
 Result := 'SELECT id, descricao, preco_venda, unidade ' +
            'FROM produtos ORDER BY id';
end;

end.
