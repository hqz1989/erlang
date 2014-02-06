%% httpd.erl - MicroHttpd  
%% http://hideto.iteye.com/blog/235428
-module(httpd).  
-author("ninhenry@gmail.com").  
  
-export([start/0,start/1,start/2,process/2]).  
-import(regexp,[split/2]).  
  
-define(defPort,8888).  
-define(docRoot,"public").  
  
start() -> start(?defPort,?docRoot).  
start(Port) -> start(Port,?docRoot).    
start(Port,DocRoot) ->  
  case gen_tcp:listen(Port, [binary,{packet, 0},{active, false}]) of  
    {ok, LSock} -> server_loop(LSock,DocRoot);  
      {error, Reason}   -> exit({Port,Reason})  
  end.  
  
%% main server loop - wait for next connection, spawn child to process it  
server_loop(LSock,DocRoot) ->  
  case gen_tcp:accept(LSock) of  
    {ok, Sock} ->  
      spawn(?MODULE,process,[Sock,DocRoot]),  
      server_loop(LSock,DocRoot);  
    {error, Reason} ->  
      exit({accept,Reason})  
  end.  
  
%% process current connection  
process(Sock,DocRoot) ->  
  Req = do_recv(Sock),  
  {ok,[Cmd|[Name|[Vers|_]]]} = split(Req,"[ \r\n]"),  
  FileName = DocRoot ++ Name,  
  LogReq = Cmd ++ " " ++ Name ++ " " ++ Vers,  
  Resp = case file:read_file(FileName) of  
    {ok, Data} ->  
      io:format("~p ~p ok~n",[LogReq,FileName]),  
      Data;  
    {error, Reason} ->  
      io:format("~p ~p failed ~p~n",[LogReq,FileName,Reason]),  
      error_response(LogReq,file:format_error(Reason))  
    end,   
  do_send(Sock,Resp),  
  gen_tcp:close(Sock).  
  
%% construct HTML for failure message  
error_response(LogReq,Reason) ->  
  "<html><head><title>Request Failed</title></head><body>\n" ++  
  "<h1>Request Failed</h1>\n" ++ "Your request to " ++ LogReq ++  
  " failed due to: " ++ Reason ++ "\n</body></html>\n".  
  
%% send a line of text to the socket  
do_send(Sock,Msg) ->  
  case gen_tcp:send(Sock, Msg) of  
    ok -> ok;  
      {error, Reason} -> exit(Reason)  
  end.  
  
%% receive data from the socket  
do_recv(Sock) ->  
  case gen_tcp:recv(Sock, 0) of  
    {ok, Bin} -> binary_to_list(Bin);  
      {error, closed} -> exit(closed);  
      {error, Reason} -> exit(Reason)  
  end. 


%%运行时在httpd.erl本地建一个public目录，public目录里放一个index.html文件 
%%然后httpd:start()启动服务器，就可以访问http://localhost:8888/index.html了
