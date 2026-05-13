unit View.Pedido.Venda;

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
  Vcl.ExtCtrls,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.StdCtrls,
  Vcl.Buttons,
  View.Clientes,
  View.Produtos,
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
  Controller.Pedido,
  Controller.Produto,
  Model.Pedido,
  Model.Produto,
  Util.Validador,
  Util.Numero;

type
  TViewPedidoVenda = class(TForm)
    pPedido: TPanel;
    pItemPedido: TPanel;
    pPedidoTotal: TPanel;
    dbg: TDBGrid;
    btnGravar: TButton;
    btnSair: TButton;
    lbTotal: TLabel;
    lbCliente: TLabel;
    edtCliente: TEdit;
    btnBuscarCliente: TSpeedButton;
    lbProduto: TLabel;
    edtProduto: TEdit;
    btnBuscarProduto: TSpeedButton;
    edtValorUnitario: TEdit;
    lbVlrUnitario: TLabel;
    lbQtde: TLabel;
    edtQuantidade: TEdit;
    edtValorTotal: TEdit;
    lbTotalQuantidade: TLabel;
    btnAddItem: TSpeedButton;
    lbUnd: TLabel;
    edtUnidade: TEdit;
    DataSource: TDataSource;
    FDQueryPedido: TFDMemTable;
    FDQueryPedidopedido_id: TIntegerField;
    FDQueryPedidoproduto_id: TIntegerField;
    FDQueryPedidoquantidade: TCurrencyField;
    FDQueryPedidovalor_unitario: TCurrencyField;
    FDQueryPedidodescricao_item: TStringField;
    procedure btnBuscarClienteClick(Sender: TObject);
    procedure btnBuscarProdutoClick(Sender: TObject);
    procedure btnAddItemClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtQuantidadeExit(Sender: TObject);
    procedure edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
    procedure dbgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FIdCliente: Integer;
    FIdProduto: Integer;
    FPedidoController: TPedidoController;
    FProdutoController: TProdutoController;
    procedure CalcularTotal;
    procedure CalcularTotalPedido;
    procedure LimparSelecaoProduto;
    procedure LimparTudo;
    procedure AbrirMemTable;
  public
    { Public declarations }
  end;

var
  ViewPedidoVenda: TViewPedidoVenda;

implementation

{$R *.dfm}

procedure TViewPedidoVenda.FormCreate(Sender: TObject);
begin
  FPedidoController  := TPedidoController.Create;
  FProdutoController := TProdutoController.Create;

  AbrirMemTable;
  LimparTudo;
end;

procedure TViewPedidoVenda.FormDestroy(Sender: TObject);
begin
  FPedidoController.Free;
  FProdutoController.Free;
end;

procedure TViewPedidoVenda.AbrirMemTable;
begin
  if not FDQueryPedido.Active then
    FDQueryPedido.Open;
end;

procedure TViewPedidoVenda.btnBuscarClienteClick(Sender: TObject);
begin
  ViewClientes := TViewClientes.Create(Application);
  ViewClientes.FShowMenu := False;

  if ViewClientes.ShowModal = mrOk then
  begin
    FIdCliente      := ViewClientes.FDQueryid.AsInteger;
    edtCliente.Text := ViewClientes.FDQuerydescricao.AsString;
  end
  else
  begin
    FIdCliente := 0;
    edtCliente.Clear;
  end;
  FreeAndNil(ViewClientes);
end;

procedure TViewPedidoVenda.btnBuscarProdutoClick(Sender: TObject);
begin
  ViewProdutos := TViewProdutos.Create(Application);
  ViewProdutos.FShowMenu := False;

  if ViewProdutos.ShowModal = mrOk then
  begin
    FIdProduto            := ViewProdutos.FDQueryid.AsInteger;
    edtProduto.Text       := ViewProdutos.FDQuerydescricao.AsString;
    edtUnidade.Text       := ViewProdutos.FDQueryunidade.AsString;
    edtValorUnitario.Text := FormatFloat('#,##0.00',ViewProdutos.FDQuerypreco_venda.AsCurrency);
    edtQuantidade.Text    := '1';
    CalcularTotal;
    edtQuantidade.SetFocus;
    edtQuantidade.SelectAll;
  end
  else
  begin
    FIdProduto := 0;
    edtProduto.Clear;
    edtUnidade.Clear;
    edtValorUnitario.Clear;
  end;
  FreeAndNil(ViewProdutos);
end;

procedure TViewPedidoVenda.CalcularTotal;
var
  VlrUnitario: Currency;
  Quantidade: Currency;
begin
  VlrUnitario := ParseValor(edtValorUnitario.Text);
  Quantidade  := StrToFloatDef(edtQuantidade.Text, 0);
  edtValorTotal.Text := FormatFloat('#,##0.00', VlrUnitario * Quantidade);
end;

procedure TViewPedidoVenda.CalcularTotalPedido;
var
  Total: Currency;
  Bookmark: TBookmark;
begin
  Total := 0;

  if FDQueryPedido.IsEmpty then
  begin
    lbTotal.Caption := 'Total: 0,00';
    Exit;
  end;

  Bookmark := FDQueryPedido.GetBookmark;
  FDQueryPedido.DisableControls;
  try
    FDQueryPedido.First;
    while not FDQueryPedido.Eof do
    begin
      Total := Total +
        (FDQueryPedidoquantidade.AsCurrency *
         FDQueryPedidovalor_unitario.AsCurrency);
      FDQueryPedido.Next;
    end;
  finally
    FDQueryPedido.GotoBookmark(Bookmark);
    FDQueryPedido.FreeBookmark(Bookmark);
    FDQueryPedido.EnableControls;
  end;

  lbTotal.Caption := 'Total: ' + FormatFloat('#,##0.00', Total);
end;

procedure TViewPedidoVenda.edtQuantidadeExit(Sender: TObject);
begin
  CalcularTotal;
end;

procedure TViewPedidoVenda.edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '.' then
    Key := ',';

  if not (CharInSet(Key, ['0'..'9', ',', #8])) then
    Key := #0;

  if (Key = ',') and (Pos(',', edtQuantidade.Text) > 0) then
    Key := #0;
end;

procedure TViewPedidoVenda.btnAddItemClick(Sender: TObject);
var
  Qtd: Double;
  VlrUnit: Currency;
begin
  Qtd := StrToFloatDef(edtQuantidade.Text, 0);

  if not TValidador.Novo
    .Quando(FIdCliente = 0, 'Atenção... Deve selecionar um cliente.')
      .Executar(procedure begin btnBuscarClienteClick(nil) end)
    .Quando(FIdProduto = 0, 'Atenção... Deve selecionar um produto.')
      .Executar(procedure begin btnBuscarProdutoClick(nil) end)
    .Quando(edtQuantidade.Text = '', 'Atenção... Informe a quantidade do produto.')
      .FocarEm(edtQuantidade)
    .Quando(Qtd <= 0, 'Atenção... Quantidade deve ser maior que zero.')
      .FocarEm(edtQuantidade)
  .Valido then
    Exit;

  VlrUnit := ParseValor(edtValorUnitario.Text);

  FDQueryPedido.Append;
  FDQueryPedidopedido_id.AsInteger      := 0;
  FDQueryPedidoproduto_id.AsInteger     := FIdProduto;
  FDQueryPedidodescricao_item.AsString  := edtProduto.Text;
  FDQueryPedidoquantidade.AsCurrency    := Qtd;
  FDQueryPedidovalor_unitario.AsCurrency := VlrUnit;
  FDQueryPedido.Post;

  CalcularTotalPedido;
  LimparSelecaoProduto;
  edtQuantidade.SetFocus;
end;

procedure TViewPedidoVenda.btnGravarClick(Sender: TObject);
var
  Pedido: TPedido;
  Erro: string;
begin
  if not TValidador.Novo
    .Quando(FIdCliente = 0, 'Selecione um cliente.')
      .Executar(procedure begin btnBuscarClienteClick(nil) end)
    .Quando(FDQueryPedido.IsEmpty, 'Adicione pelo menos um item.')
      .FocarEm(edtQuantidade)
  .Valido then
    Exit;

  Pedido := TPedido.Create
    .ParaCliente(FIdCliente)
    .EmitidoEm(Now);
  try
    FDQueryPedido.First;
    while not FDQueryPedido.Eof do
    begin
      Pedido.ComItem(
        FDQueryPedidoproduto_id.AsInteger,
        FDQueryPedidoquantidade.AsCurrency,
        FDQueryPedidovalor_unitario.AsCurrency);
      FDQueryPedido.Next;
    end;

    Erro := FPedidoController.Salvar(Pedido);
    if Erro <> '' then
    begin
      ShowMessage('Erro: ' + Erro);
      Exit;
    end;

    ShowMessage(Format('Pedido %d gravado com sucesso!', [Pedido.Id]));
    LimparTudo;
  finally
    Pedido.Free;
  end;
end;

procedure TViewPedidoVenda.btnSairClick(Sender: TObject);
begin
  close
end;

procedure TViewPedidoVenda.LimparSelecaoProduto;
begin
  FIdProduto := 0;
  edtProduto.Clear;
  edtUnidade.Clear;
  edtValorUnitario.Clear;
  edtQuantidade.Clear;
  edtValorTotal.Clear;
end;

procedure TViewPedidoVenda.LimparTudo;
begin
  FIdCliente := 0;
  edtCliente.Clear;
  LimparSelecaoProduto;
  FDQueryPedido.EmptyDataSet;
  CalcularTotalPedido;
end;

procedure TViewPedidoVenda.dbgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and not FDQueryPedido.IsEmpty then
  begin
    if MessageDlg('Remover este item?',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FDQueryPedido.Delete;
      CalcularTotalPedido;
    end;
  end;
end;

procedure TViewPedidoVenda.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    Screen.ActiveForm.Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

end.
