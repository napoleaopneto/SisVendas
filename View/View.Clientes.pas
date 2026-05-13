unit View.Clientes;

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
  Controller.Cliente,
  Model.Cliente,
  Util.Validador;

type
  TViewClientes = class(TfPadrao)
    FDQueryid: TIntegerField;
    FDQuerydocumento: TStringField;
    FDQuerycidade: TStringField;
    FDQuerydescricao: TStringField;
    lbDocumento: TLabel;
    edtDocumento: TEdit;
    lbCidade: TLabel;
    edtCidade: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure dbgCellClick(Column: TColumn);
    procedure btnNovoClick(Sender: TObject);
    procedure dbgDblClick(Sender: TObject);
  private
    { Private declarations }
    FController: TClienteController;
    function SQLListagem: string;
    procedure ListarClientes();
    function SalvarRegistro(AId: Integer): string;
    procedure LimparCamposEdicao();
    procedure RegistroParaEdicao(AId: Integer);
  public
    { Public declarations }
  end;

var
  ViewClientes: TViewClientes;

implementation

{$R *.dfm}

procedure TViewClientes.btnEditarClick(Sender: TObject);
begin
  inherited;
  if btnEditar.caption = 'Editar' then
    RegistroParaEdicao(FDQueryid.asinteger)
  else
  begin
    if not TValidador.Novo
      .Quando(Trim(edtDescricao.Text) = '', 'Descrição obrigatório')
        .FocarEm(edtDescricao)
      .Quando(Trim(edtDocumento.Text) = '', 'Documento obrigatório')
        .FocarEm(edtDocumento)
      .Quando(Trim(edtCidade.Text) = '',    'Cidade obrigatório')
        .FocarEm(edtCidade)
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

procedure TViewClientes.btnExcluirClick(Sender: TObject);
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
    ListarClientes;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir: ' + E.Message);
  end;
end;

procedure TViewClientes.btnNovoClick(Sender: TObject);
begin
  inherited;
  LimparCamposEdicao();
end;

procedure TViewClientes.RegistroParaEdicao(AId: Integer);
var Cliente: TCliente;
begin
  Cliente := FController.BuscarPorId(AId);
  if not Assigned(Cliente) then Exit;
  try
    edtCodigo.Text    := Cliente.id.ToString;
    edtDescricao.Text := Cliente.Nome;
    edtDocumento.Text := Cliente.Documento;
    edtCidade.Text    := Cliente.Cidade;
    CardPanel.activecard := pcadastro;
    btnEditar.caption := 'Gravar';
    btnNovo.enabled := false;
    btnEditar.enabled := true;
    btnexcluir.enabled := false;
    btnCancelar.enabled := true;
    btnSair.enabled := false;
  finally
    Cliente.Free;
  end;
end;

procedure TViewClientes.dbgCellClick(Column: TColumn);
begin
  inherited;
  btnExcluir.enabled := true;
  btnEditar.enabled := true;
end;

procedure TViewClientes.dbgDblClick(Sender: TObject);
begin
  inherited;
  if Not FShowMenu then
    ModalResult := mrOk;
end;

procedure TViewClientes.FormCreate(Sender: TObject);
begin
  inherited;
  FController := TClienteController.Create;
end;

procedure TViewClientes.FormDestroy(Sender: TObject);
begin
  FController.Free;
  inherited;
end;

procedure TViewClientes.FormShow(Sender: TObject);
begin
  inherited;
  ListarClientes;
end;

procedure TViewClientes.LimparCamposEdicao;
begin
  edtcodigo.clear;
  edtDescricao.Clear;
  edtDocumento.Clear;
  edtCidade.Clear;
end;

procedure TViewClientes.ListarClientes;
begin
  FDQuery.SQL.Text := SQLListagem;
  FDQuery.open;
  lbTotal.caption := 'Total: ' + FDQuery.recordcount.tostring;
end;

function TViewClientes.SalvarRegistro(AId: Integer): string;
var Cliente: TCliente;
begin
  Cliente := TCliente.Create
    .ComId(AId)
    .ComNome(edtDescricao.Text)
    .ComDocumento(edtDocumento.Text)
    .NaCidade(edtCidade.Text);
  try
    Result := FController.Salvar(Cliente);
  finally
    Cliente.Free;
    LimparCamposEdicao;
    ListarClientes;
    btnEditar.caption := 'Editar';
    btnSair.enabled := true;
  end;
end;

function TViewClientes.SQLListagem: string;
begin
  Result := 'SELECT id, descricao, documento, cidade ' +
            'FROM clientes ORDER BY id';
end;

end.
