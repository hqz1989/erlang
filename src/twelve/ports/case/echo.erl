%% echo.erl
-module(echo).
-export([start/0, stop/0, echo/1]).

start() -> 
    spawn(fun() -> 
            register(echo, self()),
            process_flag(trap_exit, true),
            Port = open_port({spawn, "./echo"}, [{packet, 1}]),
            loop(Port)
        end).

stop() -> 
    echo ! stop.

echo(Msg) -> 
    echo ! {call, self(), Msg},    %% Msg必须是一个List
    receive 
        Result -> Result
    after 1000 -> io:format("time out~n"), true
    end.

loop(Port) ->
    receive
        {call, Caller, Msg} -> 
            Port ! {self(), {command, Msg}},    %% Msg必须是一个List
            receive
                {Port, {data, Data}} ->     %% 返回的Data也是一个List
                    Caller ! Data
            end,
            loop(Port);
        stop -> 
            Port ! {self(), close}, 
            receive
                {Port, closed} -> exit(normal)
            end;
        {'EXIT', Port, Reason} -> 
            io:format("port terminated!~n"),
            exit({port_terminated, Reason})
    end.
