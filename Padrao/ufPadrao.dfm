object fPadrao: TfPadrao
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Form Padr'#227'o'
  ClientHeight = 416
  ClientWidth = 570
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
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object CardPanel: TCardPanel
    Left = 137
    Top = 0
    Width = 433
    Height = 416
    Align = alClient
    ActiveCard = pLista
    BevelOuter = bvNone
    Caption = 'CardPanel'
    TabOrder = 0
    object pLista: TCard
      Left = 0
      Top = 0
      Width = 433
      Height = 416
      Caption = 'Lista'
      CardIndex = 0
      TabOrder = 0
      object lbTotal: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 398
        Width = 427
        Height = 15
        Margins.Top = 0
        Align = alBottom
        Caption = 'lbTotal'
        ExplicitWidth = 37
      end
      object edtBusca: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 427
        Height = 23
        Align = alTop
        TabOrder = 0
        OnChange = edtBuscaChange
      end
      object dbg: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 32
        Width = 427
        Height = 363
        Align = alClient
        DataSource = DataSource
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnTitleClick = dbgTitleClick
      end
    end
    object pCadastro: TCard
      Left = 0
      Top = 0
      Width = 433
      Height = 416
      Caption = 'Cadastro'
      CardIndex = 1
      TabOrder = 1
      object lbCodigo: TLabel
        Left = 6
        Top = 9
        Width = 39
        Height = 15
        Caption = 'C'#243'digo'
      end
      object lbDescricao: TLabel
        Left = 6
        Top = 56
        Width = 51
        Height = 15
        Caption = 'Descri'#231#227'o'
      end
      object edtCodigo: TEdit
        Left = 6
        Top = 28
        Width = 121
        Height = 23
        ReadOnly = True
        TabOrder = 0
      end
      object edtDescricao: TEdit
        Left = 6
        Top = 75
        Width = 418
        Height = 23
        TabOrder = 1
      end
    end
  end
  object pBotoes: TPanel
    Left = 0
    Top = 0
    Width = 137
    Height = 416
    Align = alLeft
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 1
    object btnNovo: TButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 127
      Height = 41
      Align = alTop
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnEditar: TButton
      AlignWithMargins = True
      Left = 3
      Top = 50
      Width = 127
      Height = 41
      Align = alTop
      Caption = 'Editar'
      Enabled = False
      TabOrder = 1
      OnClick = btnEditarClick
    end
    object btnExcluir: TButton
      AlignWithMargins = True
      Left = 3
      Top = 97
      Width = 127
      Height = 41
      Align = alTop
      Caption = 'Excluir'
      Enabled = False
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnCancelar: TButton
      AlignWithMargins = True
      Left = 3
      Top = 144
      Width = 127
      Height = 41
      Align = alTop
      Caption = 'Cancelar'
      Enabled = False
      TabOrder = 3
      OnClick = btnCancelarClick
    end
    object btnSair: TButton
      AlignWithMargins = True
      Left = 3
      Top = 368
      Width = 127
      Height = 41
      Align = alBottom
      Caption = 'Sair'
      TabOrder = 4
      OnClick = btnSairClick
    end
  end
  object DataSource: TDataSource
    AutoEdit = False
    DataSet = FDQuery
    Left = 25
    Top = 248
  end
  object FDQuery: TFDQuery
    Left = 56
    Top = 248
  end
end
