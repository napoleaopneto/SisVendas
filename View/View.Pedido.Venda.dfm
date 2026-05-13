object ViewPedidoVenda: TViewPedidoVenda
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Pedido de Venda'
  ClientHeight = 595
  ClientWidth = 845
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object pPedido: TPanel
    Left = 0
    Top = 0
    Width = 845
    Height = 105
    Align = alTop
    BevelEdges = [beLeft, beTop, beRight]
    BevelKind = bkTile
    TabOrder = 0
    object lbCliente: TLabel
      Left = 5
      Top = 6
      Width = 37
      Height = 15
      Caption = 'Cliente'
    end
    object btnBuscarCliente: TSpeedButton
      Left = 5
      Top = 25
      Width = 23
      Height = 22
      Hint = 'Buscar Cliente'
      Caption = 'B'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnBuscarClienteClick
    end
    object lbProduto: TLabel
      Left = 5
      Top = 52
      Width = 43
      Height = 15
      Caption = 'Produto'
    end
    object btnBuscarProduto: TSpeedButton
      Left = 5
      Top = 71
      Width = 23
      Height = 22
      Hint = 'Buscar Produto'
      Caption = 'B'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnBuscarProdutoClick
    end
    object lbVlrUnitario: TLabel
      Left = 439
      Top = 52
      Width = 62
      Height = 15
      Caption = 'Vlr. Unit'#225'rio'
    end
    object lbQtde: TLabel
      Left = 526
      Top = 52
      Width = 62
      Height = 15
      Caption = 'Quantidade'
    end
    object lbTotalQuantidade: TLabel
      Left = 613
      Top = 52
      Width = 26
      Height = 15
      Caption = 'Total'
    end
    object btnAddItem: TSpeedButton
      Left = 698
      Top = 71
      Width = 23
      Height = 22
      Hint = 'Adicione Item'
      Caption = '+'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAddItemClick
    end
    object lbUnd: TLabel
      Left = 382
      Top = 52
      Width = 44
      Height = 15
      Caption = 'Unidade'
    end
    object btnGravar: TButton
      Left = 684
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnSair: TButton
      Left = 760
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Sair'
      TabOrder = 1
      OnClick = btnSairClick
    end
    object edtCliente: TEdit
      Left = 30
      Top = 24
      Width = 348
      Height = 23
      Color = clMenu
      ReadOnly = True
      TabOrder = 2
    end
    object edtProduto: TEdit
      Left = 30
      Top = 70
      Width = 348
      Height = 23
      Color = clMenu
      ReadOnly = True
      TabOrder = 3
    end
    object edtValorUnitario: TEdit
      Left = 439
      Top = 70
      Width = 83
      Height = 23
      Color = clMenu
      ReadOnly = True
      TabOrder = 5
    end
    object edtQuantidade: TEdit
      Left = 526
      Top = 70
      Width = 83
      Height = 23
      TabOrder = 6
      OnExit = edtQuantidadeExit
      OnKeyPress = edtQuantidadeKeyPress
    end
    object edtValorTotal: TEdit
      Left = 613
      Top = 70
      Width = 83
      Height = 23
      Color = clMenu
      ReadOnly = True
      TabOrder = 7
    end
    object edtUnidade: TEdit
      Left = 382
      Top = 70
      Width = 52
      Height = 23
      Color = clMenu
      ParentShowHint = False
      ReadOnly = True
      ShowHint = False
      TabOrder = 4
    end
  end
  object pItemPedido: TPanel
    Left = 0
    Top = 105
    Width = 845
    Height = 447
    Align = alClient
    BevelEdges = [beLeft, beRight]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 1
    object dbg: TDBGrid
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 835
      Height = 441
      Align = alClient
      Color = clMenu
      DataSource = DataSource
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'pedido_id'
          Title.Caption = 'ID PEDIDO'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'produto_id'
          Title.Caption = 'ID PRODUTO'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'descricao_item'
          Title.Caption = 'DESCRI'#199#195'O PRODUTO'
          Width = 479
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'quantidade'
          Title.Caption = 'QUANTIDADE'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'valor_unitario'
          Title.Caption = 'VALOR UNIT'#193'RIO'
          Width = 114
          Visible = True
        end>
    end
  end
  object pPedidoTotal: TPanel
    Left = 0
    Top = 552
    Width = 845
    Height = 43
    Align = alBottom
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 2
    object lbTotal: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 246
      Height = 33
      Align = alLeft
      AutoSize = False
      Caption = 'Total: 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 30
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
  end
  object DataSource: TDataSource
    AutoEdit = False
    DataSet = FDQueryPedido
    Left = 520
    Top = 8
  end
  object FDQueryPedido: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 552
    Top = 9
    object FDQueryPedidopedido_id: TIntegerField
      FieldName = 'pedido_id'
    end
    object FDQueryPedidoproduto_id: TIntegerField
      FieldName = 'produto_id'
    end
    object FDQueryPedidodescricao_item: TStringField
      FieldName = 'descricao_item'
    end
    object FDQueryPedidoquantidade: TCurrencyField
      FieldName = 'quantidade'
      currency = False
    end
    object FDQueryPedidovalor_unitario: TCurrencyField
      FieldName = 'valor_unitario'
      DisplayFormat = ',0.00'
      currency = False
    end
  end
end
