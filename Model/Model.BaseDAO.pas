unit Model.BaseDAO;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Connection;

type
  TEntidade = class
  protected
    FId: Integer;
  public
    property Id: Integer read FId write FId;
    procedure DoDataset(Q: TFDQuery); virtual; abstract;
    procedure ParaParams(Q: TFDQuery); virtual; abstract;
    class function NomeTabela: string; virtual; abstract;
    class function CamposInsert: string; virtual; abstract;
    class function CamposUpdate: string; virtual; abstract;
  end;

  TEntidadeClass = class of TEntidade;

  TBaseDAO<T: TEntidade, constructor> = class
  public
    class procedure Inserir(const AEntidade: T);
    class procedure Atualizar(const AEntidade: T);
    class procedure Excluir(AId: Integer);
    class function BuscarPorId(AId: Integer): T;
    class function Listar(const AOrderBy: string = ''): TObjectList<T>;
  end;

implementation

class procedure TBaseDAO<T>.Inserir(const AEntidade: T);
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := Format('INSERT INTO %s %s',
      [TEntidadeClass(T).NomeTabela, TEntidadeClass(T).CamposInsert]);
    TEntidade(AEntidade).ParaParams(Q);
    Q.ExecSQL;

    Q.SQL.Text := 'SELECT last_insert_rowid() AS id';
    Q.Open;
    AEntidade.Id := Q.FieldByName('id').AsInteger;
  finally
    Q.Free;
  end;
end;

class procedure TBaseDAO<T>.Atualizar(const AEntidade: T);
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := Format('UPDATE %s SET %s WHERE id = :id',
      [TEntidadeClass(T).NomeTabela, TEntidadeClass(T).CamposUpdate]);
    TEntidade(AEntidade).ParaParams(Q);
    Q.ParamByName('id').AsInteger := AEntidade.Id;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TBaseDAO<T>.Excluir(AId: Integer);
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := Format('DELETE FROM %s WHERE id = :id',
      [TEntidadeClass(T).NomeTabela]);
    Q.ParamByName('id').AsInteger := AId;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class function TBaseDAO<T>.BuscarPorId(AId: Integer): T;
var Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    Q.SQL.Text := Format('SELECT * FROM %s WHERE id = :id',
      [TEntidadeClass(T).NomeTabela]);
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    if not Q.Eof then
    begin
      Result := T.Create;
      Result.Id := Q.FieldByName('id').AsInteger;
      TEntidade(Result).DoDataset(Q);
    end;
  finally
    Q.Free;
  end;
end;

class function TBaseDAO<T>.Listar(const AOrderBy: string): TObjectList<T>;
var Q: TFDQuery;
    Entidade: T;
    SQL: string;
begin
  Result := TObjectList<T>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TConnection.Get;
    SQL := Format('SELECT * FROM %s', [TEntidadeClass(T).NomeTabela]);
    if AOrderBy <> '' then
      SQL := SQL + ' ORDER BY ' + AOrderBy;
    Q.SQL.Text := SQL;
    Q.Open;
    while not Q.Eof do
    begin
      Entidade := T.Create;
      Entidade.Id := Q.FieldByName('id').AsInteger;
      TEntidade(Entidade).DoDataset(Q);
      Result.Add(Entidade);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
