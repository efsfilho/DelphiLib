unit uCopier;

interface
uses
  Windows, Messages, SysUtils,Variants,System.RTLConsts, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  Winapi.ShellAPI, StrUtils, System.Generics.Collections;

  function FormatFileSize(Size: extended): string;
  function DirSize(Dir: string; subdir: Boolean): Longint;
  procedure CreateDirForce(Dir: String);
  procedure ListFilesFromDir(const ADirectory: String; var AFileList: TStringList; out ATotalSize: Int64);
  function AddThread: TThread ;

  procedure CopyFilesT(fromD, toD:String);
  procedure CopyFiles(fromD, toD: String); overload
  procedure CopyFiles(fromD, toD:String; Stp:Integer); overload;
  procedure CopyFiles(fromD, toD:string; var bar: TProgressBar); overload;
  procedure CopyFiles(fromD, toD:String; var bar: TProgressBar; Stp: Int64); overload;
//  procedure AddProcedure(const proc: Tproc);
//  procedure ExecuteQueue(const qProc: Tproc);
//  procedure StartProcedures(Interval: Integer);
//  procedure WatchThread(tId:Thandle);
//  procedure StopProcedures;
implementation

uses
  Unit1;

var
  ThreadAbort : Boolean=FALSE;
  ThreadStack  : array of THandle;
  iThread, maximo, tCount : Integer;
  ponteiro: Pointer;
  ThreadInit   : Boolean=False; // (True = Thread rodando)

function FormatFileSize(Size: extended): string;
{Credit P0ke}
begin
  if Size = 0 then
    begin
      Result := '0 B';
    end
  else
  begin
    if Size < 1000 then
      begin
        Result := FormatFloat('0', Size) + ' B';
      end
    else
    begin
      Size := Size / 1024;
      if (Size < 1000) then
        begin
          Result := FormatFloat('0.0', Size) + ' KB';
        end
      else
      begin
        Size := Size / 1024;
        if (Size < 1000) then
          begin
            Result := FormatFloat('0.00', Size) + ' MB';
          end
        else
        begin
          Size := Size / 1024;
          if (Size < 1000) then
            begin
              Result := FormatFloat('0.00', Size) + ' GB';
            end
          else
          begin
            Size := Size / 1024;
            if (Size < 1024) then
            begin
              Result := FormatFloat('0.00', Size) + ' TB';
            end
          end
        end
      end
    end;
  end;
end;

function DirSize(dir: string; subdir: Boolean): Longint;
var
  SR  : TSearchRec;
  found: Integer;
begin
   //GetDirSize('c:/local',true)
   // true=recursivo / false=nãorecursivo
  Result := 0;
  if dir[Length(dir)] <> '\' then
  begin
    dir := dir + '\'
  end;

  found := FindFirst(dir + '*.*', faAnyFile, SR);

  while found = 0 do
  begin
    Inc(Result, SR.Size);
    if (SR.Attr and faDirectory > 0) and (SR.Name[1] <> '.') and (subdir = True) then
    begin
      Inc(Result, DirSize(dir + SR.Name, True));
    end;
    found := FindNext(SR);
  end;
  FindClose(SR);
end;

procedure CreateDirForce(Dir: String);
begin
  if not DirectoryExists(Dir) then
  begin
    if not CreateDir(Dir) then
    begin
      if not ForceDirectories(Dir) then
      begin
        MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
        Exit;
      end;
    end;
  end
end;

procedure ListFilesFromDir(const ADirectory: String;
  var AFileList: TStringList; out ATotalSize: Int64);
var
  SR: TSearchRec;
begin
  if FindFirst(ADirectory + '\*.*', faDirectory, sr) = 0 then
  begin
    repeat
      if ((SR.Attr and faDirectory) = SR.Attr) and (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        ListFilesFromDir(ADirectory + '\' + Sr.Name, AFileList, ATotalSize);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  if FindFirst(ADirectory + '\*.*', 0, SR) = 0 then
  begin
    repeat
      AFileList.Add(ADirectory + '\' + SR.Name);
      Inc(ATotalSize, SR.Size);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function AddThread: TThread ;
var MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(
    procedure
    var
      i :Integer;
    begin
      Inc(iThread);
      SetLength(ThreadStack,iThread);
      for i := 0 to 2 do
      begin
        if ThreadStack[i] = 0 then
        begin
//          Inc(iThread);
          ThreadStack[i] := MyThread.Handle;
          if i > 0 then
            begin
              //Espera Trhead anterior
              WaitForSingleObject(ThreadStack[i-1], INFINITE);
              if ThreadAbort then
                begin
                  Abort;
                end
              else
              begin
                break;
              end;
            end
          else
          begin
            Break;
          end;
        end;
      end;
      // Code <<--
      Inc(maximo);
      form1.Label1.Caption := IntToStr(maximo);
      form1.pb1.Position := 0;
      with form1.pb1 do
      begin
        MIN := 0; MAX := 1000000;
        while MAX > POSITION do
        begin
          if ThreadAbort then
          begin
            //Cancelamento da Thread
            Abort;
          end;
          POSITION := POSITION + 1;
        end;
      end;
      sleep(500);
      if iThread = 1 then
      begin
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            //Executado após o fim da ultima thread
          end
        );
      end;

      for i := 0 to 2 do
      begin
        if ThreadStack[i] = MyThread.Handle then
        begin
          ThreadStack[i] := 0;
        end;
      end;
      Dec(iThread);
    end
  );
  MyThread.Start;
end;

procedure CopyFilesT(fromD, toD:String);
// Atualiza a barra toda
var
  IDt : Integer;
  MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(
    procedure
    var
      FlTo, FlFrom         : TStringList;
      TotalSize,FileLength, foo : Int64;
      Buffer: array[0..4096] of char;
      IFile,NumRead        : Integer;
      FromF, ToF           : file of byte;
      SR                   : TSearchRec;
    begin

      TotalSize    := 0;
      FlFrom       := TStringList.Create;
      FlTo         := TStringList.Create;
      try
        ListFilesFromDir(fromD, FlFrom, TotalSize);
      except
        MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
        Exit;
      end;

      FlTo.Text := AnsiReplaceStr(FlFrom.Text, fromD, toD);

      for IFile := 0 to FlFrom.Count-1  do
      begin
        CreateDirForce(ExtractFilePath(FlTo[IFile]));

        AssignFile(FromF, FlFrom[IFile]);
        reset(FromF);
        AssignFile(ToF, FlTo[IFile]);
        rewrite(ToF);

        FindFirst(FlFrom[IFile], faAnyFile, SR);
        FileLength := (SR.FindData.nFileSizeHigh * MAXDWORD) + SR.FindData.nFileSizeLow;
        Foo := TotalSize;

        with form1.pb1 do
        begin
          Min := 0;
          Max := TotalSize; //FileLength;

          while FileLength > 0 do
          begin
            BlockRead(FromF, Buffer[0], SizeOf(Buffer), NumRead);
            FileLength := FileLength - (NumRead);
            BlockWrite(ToF, Buffer[0], NumRead);
            Position   := Position + (NumRead);
          end;
          CloseFile(FromF);
          CloseFile(ToF);
        end;
      end;
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          form1.Label1.Visible := True;
          Form1.Label2.Visible := True;
          form1.Label1.Caption := 'sdkjghkhgfk';
          Form1.Label2.Caption := 'sdfçkslgh';
        end
      );
    end
  );
  MyThread.Start;
end;

procedure CopyFiles(fromD, toD:String);
var
  IDt : Integer;
  FlTo, FlFrom         : TStringList;
  TotalSize,FileLength, foo : Int64;
  Buffer: array[0..4096] of char;
  IFile,NumRead,i      : Integer;
  FromF, ToF           : file of byte;
  SR                   : TSearchRec;
begin
  TotalSize    := 0;
  FlFrom       := TStringList.Create;
  FlTo         := TStringList.Create;
  try
    ListFilesFromDir(fromD, FlFrom, TotalSize);
  except
    MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
    Exit;
  end;
  FlTo.Text := AnsiReplaceStr(FlFrom.Text, fromD, toD);
  for IFile := 0 to FlFrom.Count-1  do
  begin
    CreateDirForce(ExtractFilePath(FlTo[IFile]));
    AssignFile(FromF, FlFrom[IFile]);
    reset(FromF);
    AssignFile(ToF, FlTo[IFile]);
    rewrite(ToF);
    FindFirst(FlFrom[IFile], faAnyFile, SR);
    FileLength := (SR.FindData.nFileSizeHigh * MAXDWORD) + SR.FindData.nFileSizeLow;
    Foo := TotalSize;
    with Form1.pb1 do
    begin
      Min := 0;
      Max := TotalSize; //FileLength;
      while FileLength > 0 do
      begin
        BlockRead(FromF, Buffer[0], SizeOf(Buffer), NumRead);
        FileLength := FileLength - (NumRead);
        BlockWrite(ToF, Buffer[0], NumRead);
        Position   := Position + (NumRead);
      end;
      CloseFile(FromF);
      CloseFile(ToF);
    end;
  end;
end;

procedure CopyFiles(fromD, toD:String; Stp: Integer);
// Atualiza parte da barra
var
  IDt : Integer;
  MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(
    procedure
    var
      FlTo, FlFrom         : TStringList;
      TotalSize,FileLength, foo : Int64;
      Buffer: array[0..4096] of char;
      IFile,NumRead,i      : Integer;
      FromF, ToF           : file of byte;
      SR                   : TSearchRec;
    begin
      TotalSize    := 0;
      FlFrom       := TStringList.Create;
      FlTo         := TStringList.Create;
      try
        ListFilesFromDir(fromD, FlFrom, TotalSize);
      except
        MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
        Exit;
      end;

      FlTo.Text := AnsiReplaceStr(FlFrom.Text, fromD, toD);

      for IFile := 0 to FlFrom.Count-1  do
      begin
        CreateDirForce(ExtractFilePath(FlTo[IFile]));
        AssignFile(FromF, FlFrom[IFile]);
        reset(FromF);
        AssignFile(ToF, FlTo[IFile]);
        rewrite(ToF);

        FindFirst(FlFrom[IFile], faAnyFile, SR);
        FileLength := (SR.FindData.nFileSizeHigh * MAXDWORD) + SR.FindData.nFileSizeLow;
        Foo := Round(TotalSize/Stp);

        with form1.pb1 do
        begin
          while FileLength > 0 do
          begin
            BlockRead(FromF, Buffer[0], SizeOf(Buffer), NumRead);
            FileLength := FileLength - (NumRead);
            BlockWrite(ToF, Buffer[0], NumRead);
            i := i + NumRead;
            if i >= foo  then
            begin
              if Position < Stp then
              begin
                StepIt;
              end;
              foo := foo + Round(TotalSize/Stp)
            end;
          end;

          CloseFile(FromF);
          CloseFile(ToF);
        end;
      end;
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          form1.Label1.Visible := True;
          Form1.Label2.Visible := True;
          form1.Label1.Caption := 'sdkjghkhgfk';
          Form1.Label2.Caption := 'sdfçkslgh';
        end
      );
    end
  );
  MyThread.Start;
end;

procedure CopyFiles(fromD, toD:String; var bar: TProgressBar);
var
  IDt : Integer;
  FlTo, FlFrom         : TStringList;
  TotalSize,FileLength, foo : Int64;
  Buffer: array[0..4096] of char;
  IFile,NumRead,i      : Integer;
  FromF, ToF           : file of byte;
  SR                   : TSearchRec;
begin
  TotalSize    := 0;
  FlFrom       := TStringList.Create;
  FlTo         := TStringList.Create;
  try
    ListFilesFromDir(fromD, FlFrom, TotalSize);
  except
    MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
    Exit;
  end;
  FlTo.Text := AnsiReplaceStr(FlFrom.Text, fromD, toD);
  for IFile := 0 to FlFrom.Count-1  do
  begin
    CreateDirForce(ExtractFilePath(FlTo[IFile]));
    AssignFile(FromF, FlFrom[IFile]);
    reset(FromF);
    AssignFile(ToF, FlTo[IFile]);
    rewrite(ToF);
    FindFirst(FlFrom[IFile], faAnyFile, SR);
    FileLength := (SR.FindData.nFileSizeHigh * MAXDWORD) + SR.FindData.nFileSizeLow;
    Foo := TotalSize;
    with bar do
    begin
      Min := 0;
      Max := TotalSize; //FileLength;
      while FileLength > 0 do
      begin
        BlockRead(FromF, Buffer[0], SizeOf(Buffer), NumRead);
        FileLength := FileLength - (NumRead);
        BlockWrite(ToF, Buffer[0], NumRead);
        Position   := Position + (NumRead);
      end;
      CloseFile(FromF);
      CloseFile(ToF);
    end;
  end;
end;

procedure CopyFiles(fromD, toD:String; var bar: TProgressBar; Stp: Int64);
var
  IDt : Integer;
  FlTo, FlFrom         : TStringList;
  TotalSize,FileLength : Int64;
  Buffer: array[0..4096] of char;
//  Buffer: array[1..4095] of char;
  foo,i                : Double;
  IFile,NumRead        : Integer;
  FromF, ToF           : file of byte;
  SR                   : TSearchRec;
begin
  TotalSize    := 0;
  FlFrom       := TStringList.Create;
  FlTo         := TStringList.Create;
  try
    ListFilesFromDir(fromD, FlFrom, TotalSize);
  except
    MessageDlg('Houve um erro ao tentar copiar os arquivos necessários.', mtError, [mbOk], 0);
    Exit;
  end;
  i := 0;
  foo := round(TotalSize/Stp);
//  bar.Position := 1;

  FlTo.Text := AnsiReplaceStr(FlFrom.Text, fromD, toD);
  for IFile := 0 to FlFrom.Count-1  do
  begin
    CreateDirForce(ExtractFilePath(FlTo[IFile]));
    AssignFile(FromF, FlFrom[IFile]);
    reset(FromF);
    AssignFile(ToF, FlTo[IFile]);
    rewrite(ToF);
    FindFirst(FlFrom[IFile], faAnyFile, SR);
    FileLength := (SR.FindData.nFileSizeHigh * MAXDWORD) + SR.FindData.nFileSizeLow;

    with bar do
    begin
      while FileLength > 0 do
      begin
        BlockRead(FromF, Buffer[0], SizeOf(Buffer), NumRead);
        FileLength := FileLength - (NumRead);
        BlockWrite(ToF, Buffer[0], NumRead);
        i := i + NumRead;
        if i >= foo  then
        begin
          if Position <= Stp then
          begin
//            StepIt;
            Form1.lbl1.Caption := IntToStr(Position);
            Position := Position + 1;
//            foo := foo + foo;
          end;
          foo := foo + (TotalSize/Stp);
        end;
      end;

      CloseFile(FromF);
      CloseFile(ToF);
    end;
  end;
end;

//procedure AddProcedure(const proc: Tproc);
//begin
//  if ThreadInit then
//    begin
//      Queue.Enqueue(proc);
//    end
//  else
//  begin
//    ThreadInit := True;
//    Queue := TQueue<Tproc>.Create;
//    Queue.Enqueue(proc);
//  end;
//end;
//
//procedure ExecuteQueue(const qProc: Tproc);
//var MyThread, foo: TThread;
//begin
//  MyThread := TThread.CreateAnonymousThread(qProc);
//  MyThread.FreeOnTerminate := True;
//  MyThread.Start;
//  WatchThread(MyThread.Handle);
//
//  WaitForSingleObject(MyThread.Handle, INFINITE);
//end;
//
//procedure StartProcedures(Interval:Integer);
//var
//  MyThread: TThread;
//begin
//  MyThread := TThread.CreateAnonymousThread(
//  procedure
//  begin
//    tCount := 2;
//    if not(Queue = nil) then
//    begin
//      try
//        while Queue.Count > 0 do
//        begin
//          ExecuteQueue(Queue.Peek());
//          Sleep(Interval);
//          Queue.Extract;
//          Queue.TrimExcess;
//        end;
//      finally
//        Queue.Free;
//        ThreadInit := False;
//      end;
//    end
//  end);
//  MyThread.FreeOnTerminate := True;
//  MyThread.Start;
//  WatchThread(MyThread.Handle);
//end;
//
//procedure WatchThread(tId:Thandle);
//var wThread : TThread;
//begin
//  wThread := TThread.CreateAnonymousThread(
//  procedure
//  var target : TThread;
//  begin
//    while ThreadInit do
//    begin
//    end;
//    TerminateThread(tId, 0);
//  end);
//  wThread.Start;
//end;
//
//procedure StopProcedures;
//begin
//  ThreadInit := False;
//end;

end.
