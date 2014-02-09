-module(lib_misc).
-export([qsort/1, pythag/1, perms/1, max/2, odds_and_evens_acc/1]).

%quick sort
qsort([]) -> [];
qsort([Pivot | T]) -> 
        qsort([X || X <- T, X < Pivot])
        ++[Pivot]++
        qsort([X || X <- T, X >= Pivot]).   %% X ++ Y ++ Z : [X, Y, Z]

pythag(N) ->
    [{A, B, C} ||
        A <- lists:seq(1, N),
        B <- lists:seq(1, N),
        C <- lists:seq(1, N),
        A + B + C =< N,
        A*A+B*B =:=C*C
    ].

perms([]) -> [[]];
perms(L) ->  [[H | T] || H <- L, T <- perms(L -- [H])].  %%  X--Y : remove Y from X

max(X, Y) when X > Y -> X;  %% and : G1, G2, G3 -> X,,,or : G1; G2; G3 -> X
max(X, Y) -> Y.

odds_and_evens(L) ->
    Odds = [X || X <- L, (X rem 2) =:= 1],
    Evens = [X || X <- L, (X rem 2) =:= 0],
    {Odds, Evens}.

odds_and_evens_acc(L) ->
    odds_and_evens_acc(L, [], []).
odds_and_evens_acc([H|T], Odds, Evens) ->
    case (H rem 2) of
        1 -> odds_and_evens_acc(T, [H|Odds], Evens);
        0 -> odds_and_evens_acc(T, Odds, [H | Evens])
    end;
odds_and_evens_acc([], Odds, Evens) ->
    {lists:reverse(Odds), lists:reverse(Evens)}.

