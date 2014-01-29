-module(echo_server).
-export([start/0, print/1, stop/0, loop/0]).

start()->
    Pid=spawn(echo_server, loop,[]),
    register(sub1, Pid),
    {ok, Pid}. %%after start, whereis(sub1) can be used to compare Pids to check whether sub process is waiting or starting.


loop()->
    receive {print, A}->
            io:format("~p.~n", [A]), loop(); %print var and continue
            stop ->true end. %%stop

print(A)->
    sub1 ! {print, A}, ok. %% inter massage define
stop()->
    sub1 ! stop,ok.
    
%%http://hideto.iteye.com/blog/246373
