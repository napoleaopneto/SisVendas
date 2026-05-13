object fPrincipal: TfPrincipal
  Left = 0
  Top = 0
  Caption = 'SisVendas'
  ClientHeight = 760
  ClientWidth = 1034
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1034
    Height = 73
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 0
    object btnVendas: TButton
      AlignWithMargins = True
      Left = 165
      Top = 3
      Width = 75
      Height = 65
      Align = alLeft
      Caption = 'Vendas'
      TabOrder = 2
      OnClick = btnVendasClick
    end
    object btnProdutos: TButton
      AlignWithMargins = True
      Left = 84
      Top = 3
      Width = 75
      Height = 65
      Align = alLeft
      Caption = 'Produtos'
      TabOrder = 1
      OnClick = btnProdutosClick
    end
    object btnClientes: TButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 75
      Height = 65
      Align = alLeft
      Caption = 'Clientes'
      TabOrder = 0
      OnClick = btnClientesClick
    end
  end
  object pCentral: TPanel
    Left = 0
    Top = 73
    Width = 1034
    Height = 687
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 74
  end
end
