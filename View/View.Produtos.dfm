inherited ViewProdutos: TViewProdutos
  Caption = 'Produtos'
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
            Width = 196
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'preco_venda'
            Title.Caption = 'PRE'#199'O VENDA'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'unidade'
            Title.Caption = 'UNIDADE'
            Visible = True
          end>
      end
    end
    inherited pCadastro: TCard
      object lbPrecoVenda: TLabel [2]
        Left = 6
        Top = 101
        Width = 66
        Height = 15
        Caption = 'Pre'#231'o Venda'
      end
      object lbUnidade: TLabel [3]
        Left = 130
        Top = 101
        Width = 44
        Height = 15
        Caption = 'Unidade'
      end
      inherited edtDescricao: TEdit
        CharCase = ecUpperCase
      end
      object edtPrecoVenda: TEdit
        Left = 6
        Top = 120
        Width = 121
        Height = 23
        TabOrder = 2
        OnExit = edtPrecoVendaExit
        OnKeyPress = edtPrecoVendaKeyPress
      end
      object edtUnidade: TEdit
        Left = 130
        Top = 120
        Width = 55
        Height = 23
        CharCase = ecUpperCase
        MaxLength = 2
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
      Size = 200
    end
    object FDQueryunidade: TStringField
      FieldName = 'unidade'
      Size = 2
    end
    object FDQuerypreco_venda: TBCDField
      FieldName = 'preco_venda'
      DisplayFormat = '#,##0.00'
      Precision = 15
      Size = 2
    end
  end
end
