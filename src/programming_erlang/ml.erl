-module(ml).
-export([start/0]).

-ifdef(debug). %% c(ml, {d, debug}).
-define(TRACE(X), io:format("TRACE ~p:~p ~p~n", [?MODULE, ?LINE, X])).
-else.
-define(TRACE(X), void).
-endif.
start() -> loop(5).

loop(0) ->
    void;
loop(N) ->
    ?TRACE(N),
    loop(N-1).
    
