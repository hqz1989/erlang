-module(example1).
-export([start/1, stop/0]).
-export([twice/1, sum/2]).

start() ->
    spawn(fun() ->
                  register(example1, self()),
                  process_flag(trap_exit, true),
                  Port = opern_port({spawn, ".\example1"}, [{packet, 2}]),
                  loop(Port)
          end).
stop() ->
    example1 ! stop.
