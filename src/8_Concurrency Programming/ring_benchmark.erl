-module(ring_benchmark).
-export([start/2]).

start(N, M) ->
    Pid = create_process(self(), N-1, M),
    time(fun() -> Pid ! start, loop(Pid, M) end).

time(Fun) ->
    statistics(wall_clock),
    Fun(),
    {_, Time} = statistics(wall_clock),
    io:format("Run: ~w s ~n", [Time/ 1000]).

create_process(Pid, 0, _) ->
    Pid;
create_process(Pid, N, M) -> create_process(spawn(fun() ->loop(Pid, M) end), N-1, M).

loop(_, 0) ->
    void;
loop(Next, M) ->
    receive
        Message ->
            Next ! Message,
            loop(Next, M -1)
    end.

