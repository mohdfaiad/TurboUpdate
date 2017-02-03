{******************************************************************************}
{                           ErrorSoft TurboUpdate                              }
{                          ErrorSoft(c)  2016-2017                             }
{                                                                              }
{                     More beautiful things: errorsoft.org                     }
{                                                                              }
{           errorsoft@mail.ru | vk.com/errorsoft | github.com/errorcalc        }
{              errorsoft@protonmail.ch | habrahabr.ru/user/error1024           }
{                                                                              }
{             Open this on github: github.com/errorcalc/TurboUpdate            }
{                                                                              }
{ You can order developing vcl/fmx components, please submit requests to mail. }
{ �� ������ �������� ���������� VCL/FMX ���������� �� �����.                   }
{******************************************************************************}
unit TurboUpdate.FormUpdate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ES.Indicators, ES.Layouts, ES.BaseControls, ES.Images, Vcl.StdCtrls,
  Vcl.ExtCtrls, TurboUpdate.Types, Vcl.Imaging.pngimage;

type
  TFormUpdate = class(TForm, IUpdateView)
    Image: TEsImageControl;
    LayoutFotter: TEsLayout;
    ProgressBar: TEsActivityBar;
    ButtonCancel: TButton;
    LabelStatus: TLabel;
    LayoutMain: TEsLayout;
    LabelDescription: TLabel;
    LayoutProgress: TEsLayout;
    LayoutFotterSeparator: TEsLayout;
    LabelVersion: TLabel;
    LinkLabelTurboUpdate: TLinkLabel;
    procedure ButtonCancelClick(Sender: TObject);
    procedure LinkLabelTurboUpdateLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Model: IUpdateModel;
  public
    { IUpdateView }
    procedure SetVersion(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetPngRes(const Value: string);
    procedure SetModel(Model: IUpdateModel);
    procedure SetStatus(const Value: string);
    procedure SetUpdateState(Value: TUpdateState);
    procedure ShowMessage(Message: string);
    function ShowErrorMessage(Message: string): Boolean;
    procedure IUpdateView.Close = ViewClose;
      procedure ViewClose;
    procedure IUpdateView.Show = ViewShow;
      procedure ViewShow;
    procedure Progress(Progress, Length: Integer);
  end;

implementation

{$R *.dfm}

uses
  Winapi.ShellApi, System.UITypes;

{ TFormUpdate }

procedure TFormUpdate.ButtonCancelClick(Sender: TObject);
begin
  Model.Cancel;
end;

procedure TFormUpdate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Model.Cancel;
  Action := caNone;
end;

procedure TFormUpdate.LinkLabelTurboUpdateLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(0, 'Open', PChar(Link), nil, nil, 0);
end;

procedure TFormUpdate.Progress(Progress, Length: Integer);
begin
  ProgressBar.AnimationType := TActivityAnimationType.Progress;
  ProgressBar.Max := Length;
  ProgressBar.Position := Progress;
end;

procedure TFormUpdate.SetDescription(const Value: string);
begin
  LabelDescription.Caption := Value;
end;

procedure TFormUpdate.SetModel(Model: IUpdateModel);
begin
  Self.Model := Model;
end;

procedure TFormUpdate.SetPngRes(const Value: string);
var
  Png: TPngImage;
begin
  Png := TPngImage.Create;
  try
    Png.LoadFromResourceName(hInstance, PChar(Value));
    Image.Picture.Assign(Png);
  finally
    Png.Free;
  end;
end;

procedure TFormUpdate.SetStatus(const Value: string);
begin
  LabelStatus.Caption := Value;
end;

procedure TFormUpdate.SetUpdateState(Value: TUpdateState);
begin
  case Value of
    TUpdateState.Waiting:
      begin
        ProgressBar.Activate;
        ProgressBar.AnimationType := TActivityAnimationType.WindowsX;
        ButtonCancel.Enabled := False;
      end;

    TUpdateState.Downloading:
      begin
        ProgressBar.AnimationType := TActivityAnimationType.Progress;
        ButtonCancel.Enabled := True;
      end;

    TUpdateState.Unpacking:
      begin
        ButtonCancel.Enabled := False;
        ProgressBar.AnimationType := TActivityAnimationType.Progress;
      end;

    TUpdateState.Done:
      begin
        ProgressBar.Deactivate;
      end;
  end;
end;

procedure TFormUpdate.SetVersion(const Value: string);
begin
  LabelVersion.Caption := Value;
end;

procedure TFormUpdate.ViewShow;
begin
  if Application.MainForm <> Self then
  begin
    Self.FormStyle := fsStayOnTop;
  end;

  inherited Show;
end;

function TFormUpdate.ShowErrorMessage(Message: string): Boolean;
begin
  Result := MessageDlg(Message, mtError, [mbYes, mbNo], 0) = mrYes;
end;

procedure TFormUpdate.ShowMessage(Message: string);
begin
  MessageDlg(Message, mtInformation, [mbOk], 0);
end;

procedure TFormUpdate.ViewClose;
begin
  OnClose := nil;
  inherited Close;
end;

end.
