-module(edemo1).
-export([start/2]).

start(Bool, M) ->
    A = spawn(fun() -> a() end),
    B = spawn(fun() -> b(A, Bool) end),
    C = spawn(fun() -> c(B, M) end),
    sleep(1000),
    status(b, B),
    status(c, C).

a() ->
    process_flag(trap_exit, true),   % if secend parameter is true, when link process exit, it will not exit.
    wait(a).

b(A, Bool) ->
    process_flag(trap_exit, Bool),
    link(A),
    wait(b).

c(B, M) ->
    link(B),
    case M of
        {die, Reason} ->
            exit(Reason);
        {divide, N} ->
            1/N,
            wait(c);
        normal ->
            io:format("test test test~n").
            true
    end.

wait(Prog) ->
    receive
        Any ->
            io:format("Process ~p received ~p~n", [Prog, Any]),
            wait(Prog)
    end.


sleep(T) ->
    receive
        after T -> true
    end.

status(Name, Pid) ->
    case erlang:is_process_alive(Pid) of
        true ->
            io:format("process ~p (~p) is alive~n", [Name, Pid]);
        false ->
            io:format("process ~p (~p) id dead~n", [Name, Pid])
    end.


%% edemo1:start(false, {die, abd}).   %% b, c will exit
%% edemo1:start(false, {die, normal}).%% noly c will exit, because mseeage is normal
%% edemo1:start(false, {divide, 0}).  %% error, b, c will exit
%% edemo1:start(false, {die, kill}).  %% b, c will exit
%% edemo1:start(true, {die, kill}).  %% only c will exit
%% in process_flag(trap_exit, Bool), if Bool is false, process will not handl exit message of other process by myself.
