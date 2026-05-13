unit Model.Connection;

interface

uses
  System.SysUtils,
  System.IOUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.ConsoleUI.Wait,
  fireDAC.VCLUI.Wait,
  FireDAC.Comp.UI;

type
  TConnection = class
  private
    class var FConn: TFDConnection;
    class procedure CriarSchema;
  public
    class function Get: TFDConnection;
    class procedure Encerrar;
  end;

implementation

class function TConnection.Get: TFDConnection;
var
  DbPath: string;
begin
  if not Assigned(FConn) then
  begin
    DbPath := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'pedidos.db');

    FConn := TFDConnection.Create(nil);
    FConn.DriverName := 'SQLite';
    FConn.Params.Add('DriverID=SQLite');
    FConn.Params.Add('Database=' + DbPath);
    FConn.Params.Add('ForeignKeys=True');
    FConn.Params.Add('lockingMode=Mormal');
    FConn.LoginPrompt := False;
    FConn.Connected := True;

    //Migration
    CriarSchema;
  end;
  Result := FConn;
end;

class procedure TConnection.CriarSchema;
begin
  FConn.ExecSQL(
    'CREATE TABLE IF NOT EXISTS clientes (' +
    '  id        INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  descricao varchar NOT NULL,' +
    '  documento varchar NOT NULL UNIQUE,' +
    '  cidade    varchar NOT NULL)');

  FConn.ExecSQL(
    'CREATE TABLE IF NOT EXISTS produtos (' +
    '  id          INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  descricao   varchar NOT NULL,' +
    '  preco_venda NUMERIC(15,2) NOT NULL,' +
    '  unidade     varchar NOT NULL)');

  FConn.ExecSQL(
    'CREATE TABLE IF NOT EXISTS pedidos (' +
    '  id           INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  data_emissao varchar NOT NULL,' +
    '  cliente_id   INTEGER NOT NULL,' +
    '  total        NUMERIC(15,2) NOT NULL DEFAULT 0,' +
    '  FOREIGN KEY (cliente_id) REFERENCES clientes(id))');

  FConn.ExecSQL(
    'CREATE TABLE IF NOT EXISTS pedido_itens (' +
    '  id             INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  pedido_id      INTEGER NOT NULL,' +
    '  produto_id     INTEGER NOT NULL,' +
    '  quantidade     NUMERIC(15,3) NOT NULL,' +
    '  valor_unitario NUMERIC(15,2) NOT NULL,' +
    '  FOREIGN KEY (pedido_id)  REFERENCES pedidos(id) ON DELETE CASCADE,' +
    '  FOREIGN KEY (produto_id) REFERENCES produtos(id))');
end;

class procedure TConnection.Encerrar;
begin
  if Assigned(FConn) then
  begin
    FConn.Connected := False;
    FConn.Free;
    FConn := nil;
  end;
end;

end.
