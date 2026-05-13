inherited ViewClientes: TViewClientes
  Caption = 'Clientes'
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  inherited CardPanel: TCardPanel
    inherited pLista: TCard
      inherited lbTotal: TLabel
        Width = 427
      end
      inherited dbg: TDBGrid
        OnCellClick = dbgCellClick
        OnDblClick = dbgDblClick
        Columns = <
          item
            Expanded = False
            FieldName = 'id'
            Title.Caption = 'ID'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'descricao'
            Title.Caption = 'DESCRI'#199#195'O'
            Width = 225
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'documento'
            Title.Caption = 'DOCUMENTO'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'cidade'
            Title.Caption = 'CIDADE'
            Visible = True
          end>
      end
    end
    inherited pCadastro: TCard
      object lbDocumento: TLabel [2]
        Left = 6
        Top = 102
        Width = 63
        Height = 15
        Caption = 'Documento'
      end
      object lbCidade: TLabel [3]
        Left = 156
        Top = 102
        Width = 37
        Height = 15
        Caption = 'Cidade'
      end
      inherited edtDescricao: TEdit
        CharCase = ecUpperCase
      end
      object edtDocumento: TEdit
        Left = 6
        Top = 121
        Width = 147
        Height = 23
        CharCase = ecUpperCase
        NumbersOnly = True
        TabOrder = 2
      end
      object edtCidade: TEdit
        Left = 156
        Top = 121
        Width = 268
        Height = 23
        CharCase = ecUpperCase
        TabOrder = 3
      end
    end
  end
  inherited FDQuery: TFDQuery
    object FDQueryid: TIntegerField
      FieldName = 'id'
    end
    object FDQuerydescricao: TStringField
      FieldName = 'descricao'
      Size = 150
    end
    object FDQuerydocumento: TStringField
      FieldName = 'documento'
    end
    object FDQuerycidade: TStringField
      FieldName = 'cidade'
      Size = 50
    end
  end
end
