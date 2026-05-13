program SisVendas;

uses
  Vcl.Forms,
  View.Principal in 'View\View.Principal.pas' {fPrincipal},
  Model.Connection in 'Model\Model.Connection.pas',
  Model.BaseDAO in 'Model\Model.BaseDAO.pas',
  Model.Cliente in 'Model\Model.Cliente.pas',
  Model.Produto in 'Model\Model.Produto.pas',
  Model.ItemPedido in 'Model\Model.ItemPedido.pas',
  Model.Pedido in 'Model\Model.Pedido.pas',
  Controller.Cliente in 'Controller\Controller.Cliente.pas',
  Controller.Produto in 'Controller\Controller.Produto.pas',
  Controller.Pedido in 'Controller\Controller.Pedido.pas',
  ufPadrao in 'Padrao\ufPadrao.pas' {fPadrao},
  View.Clientes in 'View\View.Clientes.pas' {ViewClientes},
  View.Produtos in 'View\View.Produtos.pas' {ViewProdutos},
  View.Pedido.Venda in 'View\View.Pedido.Venda.pas' {ViewPedidoVenda},
  Util.Validador in 'Util\Util.Validador.pas',
  Util.Numero in 'Util\Util.Numero.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := true; // reportar memortleack
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
