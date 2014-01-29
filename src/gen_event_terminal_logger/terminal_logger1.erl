-module(terminal_logger1).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3, terminate/2]).

init(_Args) ->
    {ok, []}.

handle_event(ErrorMsg, State) ->
    io:format("*** Error1 *** ~p~n", [ErrorMsg]),
    {ok, State}.

handle_call(_Request, _State) ->
    {ok, [], []}.
handle_info(_Info, _State) ->
    {ok, []}.
code_change(_OlvVsn, _State, _Extra) ->
    ok.
terminate(_Args, _State) ->
    ok.


