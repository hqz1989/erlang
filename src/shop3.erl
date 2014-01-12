%%%shop3.erl
-module(shop3).
-export([total/1]).
-import(shop, [cost/1]).

total(L) ->
    lists:sum([cost(A)*B|| {A, B} <- L]).
