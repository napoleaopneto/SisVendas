unit Model.Cliente;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  Model.BaseDAO,
  Model.Connection;

type
  TCliente = class(TEntidade)
  private
    FNome: string;
    FDocumento: string;
    FCidade: string;
  public
    function ComNome(const ANome: string): TCliente;
    function ComDocumento(const ADocumento: string): TCliente;
    function NaCidade(const ACidade: string): TCliente;
    function ComId(AId: Integer): TCliente;

    property Nome: string read FNome write FNome;
    property Documento: string read FDocumento write FDocumento;
    property Cidade: string read FCidade write FCidade;

    procedure DoDataset(Q: TFDQuery); override;
    procedure ParaParams(Q: TFDQuery); override;
    class function NomeTabela: string; override;
    class function CamposInsert: string; override;
    class function CamposUpdate: string; override;
  end;

  TClienteDAO = class(TBaseDAO<TCliente>)
  public
    class function BuscarPorDocumento(const ADocumento: string): TCliente;
  end;

implementation

{ TCliente }

function TCliente.ComNome(const ANome: string): TCliente;
begin
  FNome  := ANome;
  Result := Self;
end;

function TCliente.ComDocumento(const ADocumento: string): TCliente;
begin
  FDocumento := ADocumento;
  Result     := Self;
end;

function TCliente.NaCidade(const ACidade: string): TCliente;
begin
  FCidade := ACidade;
  Result  := Self;
end;

function TCliente.ComId(AId: Integer): TCliente;
begin
  FId    := AId;
  Result := Self;
end;

class function TCliente.NomeTabela: string;
begin
  Result := 'clientes';
end;

class function TCliente.CamposInsert: string;
begin
  Result := '(descricao, documento, cidade) VALUES (:descricao, :documento, :cidade)';
end;

class function TCliente.CamposUpdate: string;
begin
  Result := 'descricao = :descricao, documento = :documento, cidade = :cidade';
end;

procedure TCliente.DoDataset(Q: TFDQuery);
begin
  FNome      := Q.FieldByName('descricao').AsString;
  FDocumento := Q.FieldByName('documento').AsString;
  FCidade    := Q.FieldByName('cidade').AsString;
end;

procedure TCliente.ParaParams(Q: TFDQuery);
begin
  Q.ParamByName('descricao').AsString := FNome;
  Q.ParamByName('documento').AsString := FDocumento;
  Q.ParamByName('cidade').AsString    := FCidade;
end;

{ TClienteDAO }

class function TClienteDAO.BuscarPorDocumento(const ADocumento: string): TCliente;
var Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := 'SELECT * FROM clientes WHERE documento = :doc';
    Q.ParamByName('doc').AsString := ADocumento;
    Q.Open;
    if not Q.Eof then
    begin
      Result := TCliente.Create;
      Result.Id := Q.FieldByName('id').AsInteger;
      Result.DoDataset(Q);
    end;
  finally
    Q.Free;
  end;
end;

end.
