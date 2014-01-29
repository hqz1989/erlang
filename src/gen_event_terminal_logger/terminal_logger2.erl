-module(terminal_logger2).
-behaviour(gen_event).
-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3, terminate/2]).

init(_Args) ->
    {ok, []}.

handle_event(ErrorMsg, State) ->
    io:format("*** Error2*** ~p~n", [ErrorMsg]),
    {ok, State}.

handle_call(_Request, _State) ->
    {ok, [], []}.

handle_info(_Info, _State) ->
    {ok, []}.

code_change(_01vVsn, _State, _Extra) ->
    ok.

terminate(_Args, _State) ->
    ok.
