-module(udp_test).
-export([start_server/0
        ,server/1
        ,client/1
        ]).

start_server() ->
    spawn(fun() -> server(4000) end).

server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary]),
    io:format("server opend socket: ~p~n", [Socket]),
    loop(Socket).

loop(Socket) ->
    receive
        {udp, Socket, Host, Port, Bin} = Msg ->
            io:format("server received:~p~n", [Msg]),
            %BinReply = "ooooooooooooopppppppppppp",
            %gen_udp:send(Socket, Host, Port, BinReply),
            N = binary_to_term(Bin),
            Fac = fac(N),
            gen_udp:send(Socket, Host, Port, term_to_binary(Fac)),
            loop(Socket)
    end.
fac(0) -> 1;
fac(N) -> N*fac(N-1).

client(Request) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opend socket:~p~n", [Socket]),
    %ok = gen_udp:send(Socket, "localhost", 4000, Request),
    ok = gen_udp:send(Socket, "localhost", 4000, term_to_binary(Request)),
    Value = receive
                {udp, Socekt, _, _, Bin} = Msg ->
                    io:format("client revieced: ~p~n", [Msg]),
                    binary_to_term(Bin)
                    %{ok, Bin}
            after 2000->
                    %error
                    0
            end,
    gen_udp:close(Socket),
    Value.
