unit PwCtrls;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics, Windows;

type
  TNumericEdit = class(TCustomEdit)
  protected
    function ValidateChar(var Key: Char): Boolean; virtual; abstract;
    function GetIsNull: Boolean;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoEnter; override;

  public
    property IsNull: Boolean read GetIsNull;

  published
    property MaxLength;
    property AutoSelect;
    property AutoSize;
    property Anchors;
    property BorderStyle;
    property CharCase;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property OEMConvert;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

  TIntegerEdit = class(TNumericEdit)
  private
    function GetIntegerNumber: Integer;
    procedure SetIntegerNumber(Value: Integer);

  protected
    function ValidateChar(var Key: Char): Boolean; override;
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(Owner: TComponent); override;

  published
    property IntegerNumber: Integer read GetIntegerNumber write SetIntegerNumber;

  end;

  TFloatEdit = class(TNumericEdit)
  private
    FDecimals : Byte;
    FDigits   : Byte;
    FDecimalOk: Boolean;

    procedure SetFloatNumber(Value: Double); virtual;
    function GetFloatNumber: Double;
    procedure SetDecimals(Value: Byte);
    function GetDecimals: Byte;

    function TiraZerosaEsquerda(Valor:String):String;

  protected
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(Owner: TComponent); override;

    property IsNull: Boolean read GetIsNull;

  published
    property Decimals: Byte read GetDecimals write SetDecimals;
    property FloatNumber: Double read GetFloatNumber write SetFloatNumber;
  end;

procedure Register;

implementation

//O nome deste procedure não pode mudar
procedure Register;
begin
  //Cria a palleta Proway com o compoente TIntegerEdit e TFloatEdit
  RegisterComponents('Proway', [TIntegerEdit]);
  RegisterComponents('Proway', [TFloatEdit]);
end;

{ TNumericEdit }

procedure TNumericEdit.CreateParams(var Params: TCreateParams);
begin
  //Faz texto do edit ficar alinhado a direita.
  inherited;
  Params.Style := Params.Style or ES_RIGHT or ES_MULTILINE;
end;

procedure TNumericEdit.DoEnter;
begin
  //Ao posicionar o cursor no edit, seleciona todo o texto do edit.
  inherited DoEnter;
  SelStart := 0;
  SelLength := Length(Text);
end;

function TNumericEdit.GetIsNull: Boolean;
begin
  //Propriedade para verificar se foi digitado algum valor
  Result := (Text = '');
end;

{ TIntegerEdit }

constructor TIntegerEdit.Create(Owner: TComponent);
begin
  inherited;
  //Sempre inicia o edit com valor 0 (zero)
  Text := '0';
end;

function TIntegerEdit.ValidateChar(var Key: Char): Boolean;
begin
  //Permite os caracteres válidos para um integer, backspace e sinal.
  //Permite número de até 10 digitos, para não "estoura" o tamanho do tipo integer.
  Result :=     CharInSet(Key, [#8])
            or (CharInSet(Key, ['0'..'9', '-']) and (length(Text) < 10));
  if not Result then
    Key := #0;
end;

function TIntegerEdit.GetIntegerNumber: Integer;
begin
  //Retorna o valor do edit como integer, se não conseguir converter, retorna 0.
  Result := StrToIntDef(Text, 0);
end;

procedure TIntegerEdit.SetIntegerNumber(Value: Integer);
begin
  //Quando atribui valor a propriedade IntegerNumber, atualiza o texto do edit.
  Text := IntToStr(Value);  
end;

procedure TIntegerEdit.KeyPress(var Key: Char);
begin
  if (Key = #13)
  and Assigned(onKeyPress) then
    onKeyPress(Self, Key);

  if not ValidateChar(Key) then
    MessageBeep(0);

  inherited KeyPress(Key);
end;

{ TFloatEdit }

constructor TFloatEdit.Create(Owner: TComponent);
begin
  //Inicialise
  inherited Create(Owner);
  FDecimals := 2;
  FDigits := 14;
  FloatNumber := 0;
end;

function TFloatEdit.GetDecimals: Byte;
begin
  Result := FDecimals;
end;

procedure TFloatEdit.KeyPress(var Key: Char);
var
  Bias: Byte;
  AuxText: String;
  S: Integer;
begin
  //Permite os caracteres válidos para um integer, backspace e sinal.
  if (Key = #13)
  and Assigned(onKeyPress) then
    onKeyPress(Self, Key);

  if not ReadOnly then
     begin
       if FDecimals > 0 then
         Bias := 1
       else
         Bias := 0;

       if CharInSet(Key, [#8, FormatSettings.DecimalSeparator, '0'..'9', '-']) then
         begin
           if SelLength = Length(Text) then
             SetDecimals(FDecimals);

           FDecimalOk := (FDecimals > 0) and (SelStart >= (Length(Text) - FDecimals));
           if FDecimalOk then
             begin
               if (Key = #8) then
                 begin
                  if (Text[SelStart] <> FormatSettings.DecimalSeparator) then
                    begin
                      AuxText := Text;
                      S := SelStart;
                      delete(AuxText, S, 1);
                      AuxText := AuxText + '0';
                      Text := AuxText;
                      SelStart := S - 1;
                      SelLength := 0;
                    end
                  else
                    begin
                      SelStart := SelStart - 1;
                      SelLength := 0;
                    end;
                 end
               else
                 begin
                   AuxText := Text;
                   S := SelStart;
                   if S < Length(AuxText) then
                      AuxText[S + 1] := Key;
                   Text := AuxText;
                   SelStart := S + 1;
                   SelLength := 0;
                 end;
             end
           else
             begin
               if (Key = FormatSettings.DecimalSeparator) then
                 begin
                    SelStart := pos(FormatSettings.DecimalSeparator, Text);
                    SelLength := 0;
                 end
               else
                 if (Key <> #8)
                 and (length(Text) - (FDecimals + Bias) < FDigits) then
                   begin
                     AuxText := Text;
                     if (FDecimals > 0) then
                       begin
                         Insert(Key, AuxText, length(AuxText) - FDecimals);
                         AuxText := TiraZerosaEsquerda(AuxText);
                         Text := AuxText;
                         SelStart := pos(FormatSettings.DecimalSeparator, AuxText) - 1;
                         SelLength := 0;
                       end
                     else
                       begin
                         if SelStart < Length(AuxText) then
                           begin
                              Insert(Key, AuxText, SelStart + 1);
                              S := SelStart;
                              Text := AuxText;
                              SelStart := S;
                           end
                         else
                           begin
                              AuxText := AuxText + Key;
                              Text := AuxText;
                              SelStart := length(AuxText);
                           end;
                         SelLength := 0;
                       end;
                   end
                 else
                   if (Key = #8) then
                     begin
                       AuxText := Text;
                       S := SelStart;
                       delete(AuxText, S, 1);
                       if  (Length(AuxText) > 0) and (AuxText[1] <> FormatSettings.DecimalSeparator) then
                           begin
                             Text := AuxText;
                             SelStart := S - 1;
                           end
                       else
                           begin
                             if (FDecimals > 0) then
                                Insert('0', AuxText, 1);
                             Text := AuxText;
                           end;
                     end
                   else
                     if (SelLength = 1) then
                       begin
                         AuxText := Text;
                         S := SelStart;
                         delete(AuxText, S+1, 1);
                         Insert(Key, AuxText, s+1);
                         Text := AuxText;
                       end
                     else
                       if (SelLength+SelStart = 0) then
                          begin
                            AuxText := Text;
                            delete(AuxText, SelStart+1, 1);
                            Insert(Key, AuxText, SelStart+1);
                            Text := AuxText;
                          end;
                end;
       end;
  end;
  Key := #0;
end;

procedure TFloatEdit.SetDecimals(Value: Byte);
begin
  //Define a quantidade de decimais e já atualiza o texto do edit com esta nova formatação.
  FDecimals := Value;
  if (FDecimals > 0) then
     Text := FormatFloat(StringOfChar('#', FDigits) + '0.' + StringOfChar('0', FDecimals), 0)
  else
     Clear;
end;

function TFloatEdit.GetFloatNumber: Double;
var
  Aux: String;
begin
  //Primeiro retira todos os separadores de milhar, porque a funcão StrToFloatDef não aceita.
  Aux := Text;
  while (Pos(FormatSettings.ThousandSeparator, Aux) <> 0) do
    delete(Aux, Pos(FormatSettings.ThousandSeparator, Aux), 1);

  //Tentar conver o texto sem separador de milhar para Double, se não conseguir, retorna zero.
  Result := StrToFloatDef(Aux, 0);
end;

procedure TFloatEdit.SetFloatNumber(Value: Double);
begin
  //Formata o texto do edit de acordo com o valor Double atribuido e a quantidade de decimais definida para o componente.
  Text := FormatFloat(StringOfChar('#', FDigits) + '0.' + StringOfChar('0', FDecimals), Value);
end;

function TFloatEdit.TiraZerosaEsquerda(Valor: String): String;
begin
  //Retorna o texto enviado por parametro sem zeros a esquedar.
  Result := Valor;
  while (   (Result[1] = '0')
         or (Result[1] = FormatSettings.ThousandSeparator))
    and (Length(Result) > FDecimals+2) do
    Delete(Result, 1, 1);
end;

end.
