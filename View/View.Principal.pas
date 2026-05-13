unit View.Principal;

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
  Vcl.StdCtrls,
  Model.Connection,
  View.Clientes,
  View.Produtos,
  View.Pedido.Venda;

type
  TfPrincipal = class(TForm)
    pTop: TPanel;
    pCentral: TPanel;
    btnVendas: TButton;
    btnProdutos: TButton;
    btnClientes: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnVendasClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.dfm}

procedure TfPrincipal.btnClientesClick(Sender: TObject);
begin
  ViewClientes := TViewClientes.create(nil);
  ViewClientes.FShowMenu := true;
  ViewClientes.showmodal;
  FreeAndNil(ViewClientes);
end;

procedure TfPrincipal.btnProdutosClick(Sender: TObject);
begin
  ViewProdutos := TViewProdutos.create(Application);
  ViewProdutos.FShowMenu := true;
  ViewProdutos.showmodal;
  FreeAndNil(ViewProdutos);
end;

procedure TfPrincipal.btnVendasClick(Sender: TObject);
begin
  ViewPedidoVenda := TViewPedidoVenda.create(Application);
  ViewPedidoVenda.showmodal;
  FreeAndNil(ViewPedidoVenda);
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
  TConnection.
    Get
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
  TConnection.
    Encerrar
end;

end.
