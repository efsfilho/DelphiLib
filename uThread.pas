unit uThread;

interface
uses
  Dialogs, SysUtils, Collection, System.Generics.Collections, Windows,
  Classes,
   Controls, Forms,  StdCtrls, ExtCtrls, ComCtrls,
  Winapi.ShellAPI, StrUtils;

type
  proced = procedure of object; //tprocedure;
  Thread = class
    private
    protected
    public
      procedure AddProcedure(const proc: TProc); overload;
      procedure ExecuteQueue(const qProc: TProc);
      procedure StartProcedures(Interval: Integer);
      procedure WatchThread(tId: THandle);
      procedure StopProcedures;
  end;

implementation
var
  ThreadInit : Boolean=False;
  Queue      : TQueue<TProc>;

procedure Thread.AddProcedure(const proc: TProc);
begin
  if ThreadInit then
    begin
      Queue.Enqueue(proc);
    end
  else
  begin
    ThreadInit := True;
    Queue := TQueue<Tproc>.Create;
    Queue.Enqueue(proc);
  end;
end;

procedure Thread.ExecuteQueue(const qProc: Tproc);
var MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(qProc);
  MyThread.FreeOnTerminate := True;
  MyThread.Start;
  WatchThread(MyThread.Handle);
  WaitForSingleObject(MyThread.Handle, INFINITE);
end;

procedure Thread.StartProcedures(Interval:Integer);
var
  MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(
  procedure
  begin
    if not(Queue = nil) then
    begin
      try
        while Queue.Count > 0 do
        begin
          ExecuteQueue(Queue.Peek());
          Sleep(Interval);
          Queue.Extract;
          Queue.TrimExcess;
        end;
      finally
        Queue.Free;
        ThreadInit := False;
      end;
    end
  end);
  MyThread.FreeOnTerminate := True;
  MyThread.Start;
  WatchThread(MyThread.Handle);
end;

procedure Thread.WatchThread(tId:Thandle);
var wThread : TThread;
begin
  wThread := TThread.CreateAnonymousThread(
  procedure
  var target : TThread;
  begin
    while ThreadInit do
    begin
    end;
    TerminateThread(tId, 0);
  end);
  wThread.Start;
end;

procedure Thread.StopProcedures;
begin
  ThreadInit := False;
end;

end.
