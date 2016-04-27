object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 392
  ClientWidth = 709
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 544
    Top = 72
    Width = 16
    Height = 13
    Caption = 'lbl1'
  end
  object Label1: TLabel
    Left = 104
    Top = 88
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 256
    Top = 88
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object Button1: TButton
    Left = 56
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 56
    Top = 16
    Width = 249
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
    OnClick = Edit1Click
  end
  object Edit2: TEdit
    Left = 56
    Top = 43
    Width = 249
    Height = 21
    TabOrder = 2
    Text = 'Edit2'
    OnClick = Edit2Click
  end
  object pb1: TProgressBar
    Left = 56
    Top = 107
    Width = 504
    Height = 17
    TabOrder = 3
  end
  object Button2: TButton
    Left = 511
    Top = 144
    Width = 49
    Height = 25
    Caption = 'Form2'
    TabOrder = 4
    OnClick = Button2Click
  end
  object WebBrowser1: TWebBrowser
    Left = 184
    Top = 176
    Width = 300
    Height = 150
    TabOrder = 5
    ControlData = {
      4C000000021F0000810F00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object OpenDialog1: TOpenDialog
    Left = 352
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 400
    Top = 8
  end
end
