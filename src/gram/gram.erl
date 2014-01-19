%%%gram.erl
%%mryufeng.iteye.com/blog/472840
-module(gram).
-export([start/1]).

start([X]) ->
    %% bif
    X1 = list_to_integer(atom_to_list(X)),
    
    %%list
    W = [1,2,3],
    W1 = [4|W],
    K = [W1,9],
    
    %% constant fold
    A = 1+2,
    %% if
    B = 
        if X1 + A> 0 -> 5;
           true -> 4 
        end,
    
    %% case
    C = 
        case B of
            {X,T} -> T;
            5->a1;
            3->a2;
            2->1.0;
            other->2;
            true->3
        end,

    %% receive
    D = 
        receive
            a1 ->
                2 + 1.2;
            2->3;
            {tag, N} ->N;
            a2 -> 5;
            _ -> ok
        after A ->
              timeout
        end,
    
    %% anon fun
    E = fun(1) -> D;                
           (x) -> 2;
           (y) -> C;
           (<<"12">>) ->1;
           (_) -> error
        end,

    F = E(D),
    %%fun
    G = f(B),
    io:format("~p~p~p~p~n",[F,G,W,K]),
    done.

f(1) -> 1;
f(2) -> 2;
f(3) -> 3;
f(4) -> 4;
f(5) -> 5;
f(x1) -> 1;
f(x2) -> 2;
f(x3) -> 3;
f(x4) -> 4;
f(x5) -> 5;
f({x,1}) -> 1;
f({x,2}) -> 2;
f({x,3}) -> 3;
f({x,4}) -> 4;
f({x,5}) -> 5;
f(<<1:8,X:32, "xyz", F/float>>) -> {X,F};
f(_) -> err.
