-module(out).
-export([outer/1]).
outer(C) ->
    Inner = fun(A, B) ->
                    A + B + C end,
    Inner(2, 3).
