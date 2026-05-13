unit ufPadrao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, math, strutils;

type
  TfPadrao = class(TForm)
    CardPanel: TCardPanel;
    pLista: TCard;
    pCadastro: TCard;
    pBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    edtBusca: TEdit;
    dbg: TDBGrid;
    DataSource: TDataSource;
    FDQuery: TFDQuery;
    edtCodigo: TEdit;
    lbCodigo: TLabel;
    lbDescricao: TLabel;
    edtDescricao: TEdit;
    btnSair: TButton;
    lbTotal: TLabel;
    procedure btnNovoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtBuscaChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure dbgTitleClick(Column: TColumn);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure Buscar();
  public
    { Public declarations }
    FShowMenu : boolean;
  end;

var
  fPadrao: TfPadrao;

implementation

{$R *.dfm}

uses Model.Connection;

procedure TfPadrao.btnCancelarClick(Sender: TObject);
begin
  CardPanel.ActiveCard := pLista;
  btnEditar.caption := 'Editar';
  btnNovo.Enabled := true;
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
  btnCancelar.Enabled := false;
  btnSair.Enabled := true;
end;

procedure TfPadrao.btnEditarClick(Sender: TObject);
begin
  CardPanel.ActiveCard := pCadastro;
  btnNovo.Enabled := false;
  btnEditar.Enabled := true;
  btnExcluir.Enabled := false;
  btnCancelar.Enabled := true;
  edtdescricao.SetFocus;
end;

procedure TfPadrao.btnExcluirClick(Sender: TObject);
begin
  btnNovo.Enabled := true;
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
  btnCancelar.Enabled := false;
  btnSair.Enabled := true;
end;

procedure TfPadrao.btnNovoClick(Sender: TObject);
begin
  CardPanel.ActiveCard := pCadastro;
  btnNovo.Enabled := false;
  btnEditar.Caption := 'Gravar';
  btnEditar.Enabled := true;
  btnExcluir.Enabled := false;
  btnCancelar.Enabled := true;
  edtdescricao.SetFocus;
end;

procedure TfPadrao.btnSairClick(Sender: TObject);
begin
  close
end;

procedure TfPadrao.Buscar;
var Busca: string;
    IdBusca: Integer;
begin
  FDQuery.Filtered := False;
  FDQuery.Filter   := '';
  Busca := Trim(edtBusca.Text);
  if Busca = '' then
  begin
    FDQuery.Filtered := False;
    lbTotal.Caption  := 'Total: ' + IntToStr(FDQuery.RecordCount);
    Exit;
  end;
  if TryStrToInt(Busca, IdBusca) then
    FDQuery.Filter := 'id = ' + IntToStr(IdBusca)
  else
    FDQuery.Filter := 'descricao like ' + QuotedStr('%' + Busca + '%');
  FDQuery.FilterOptions := [foCaseInsensitive];
  FDQuery.Filtered := True;
  lbTotal.Caption := 'Total: ' + IntToStr(FDQuery.RecordCount);
end;

procedure TfPadrao.dbgTitleClick(Column: TColumn);
var Query: TFDQuery;
    CampoAtual: string;
begin
  if not (Column.Field.DataSet is TFDQuery) then Exit;

  Query := TFDQuery(Column.Field.DataSet);
  CampoAtual := Query.IndexFieldNames;

  if CampoAtual = Column.FieldName then
    Query.IndexFieldNames := Column.FieldName + ':D'
  else
    Query.IndexFieldNames := Column.FieldName;

  Query.First;
end;

procedure TfPadrao.edtBuscaChange(Sender: TObject);
begin
  Buscar();
end;

procedure TfPadrao.FormCreate(Sender: TObject);
begin
  CardPanel.ActiveCard := pLista;
  lbTotal.Caption := 'Total: 0';
  FDQuery.Connection := TConnection.Get;
end;

procedure TfPadrao.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    Screen.ActiveForm.Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

procedure TfPadrao.FormShow(Sender: TObject);
begin
  pBotoes.Visible := FShowMenu;
  Buscar
end;

end.
