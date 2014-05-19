-module(socket_example).
-export([nano_get_url/0
        ,start_nano_server/0
        ,nano_client_eval/1
        ,start_seq_server/0
        ,start_parallel_server/0
        ,server/1%udp server
        ,client/1%udp client
        ,start_server/0
        ,error_test/0
        ]).

nano_get_url() ->
    nano_get_url("www.google.com").

nano_get_url(Host) ->
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, []).

receive_data(Socket, SoFar) ->
    receive
        {tcp, Socket, Bin} ->
            receive_data(Socket, [Bin|SoFar]);
        {tcp_closed, Socket} ->
            list_to_binary(lists:reverse(SoFar))
    end.

start_nano_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
                                 {reuseaddr, true},
                                  {active, true}]),%% 主动消息接收，（非阻塞客户端），异步服务器，可能是超出服务上限
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).
%% 被动消息接收
%% 如果用{active, false}则不需调用gen_tcp:recv(Socket, N)
%%loop(Socket) ->
%%case gen_tcp:recv(Socket, N) of
%%    {ok, B} ->
%%        %%数据处理
%%        loop(Socket);
%%    {error, closed} -> ...
%%end.
%% 混合型模式（半阻塞）, 单个消息被动接受，但必须调用inet:setopts 才能接受下一条
%% {active, false}
%%loop(Socket) ->
%%    receive
%%        {tcp, Socket, Data}  ->
%%            %% 数据处理
%%            inet:setopts(Socket, [{active, once}]),
%%            loop(Socket);
%%        {tcp_closed, Socket} ->
%%            ...
%%    end.
%%顺序服务器
start_seq_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
    seq_loop(Listen).
seq_loop(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    loop(Socket),
    seq_loop(Listen).
%%并行服务器
start_parallel_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
    spawn(fun() -> par_connect(Listen) end).

par_connect(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() ->par_connect(Listen) end),
    %{ok, {IP_Address, Port}} = inet:peername(Socket),
    %io:format("id address = ~p~n", [IP_Address]),
    case inet:peername(Socket) of   %% how to use it
        {ok, {IP_Address, Port}} ->
            io:format("id address = ~p~n", [IP_Address]),
            io:format("port = ~p~n", [Port])
    %    {error, Why} ->
    %        io:format("error(~p)~n", [Why])     
    end,
    loop(Socket).
    

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            Str = binary_to_term(Bin),
            io:format("Server (unpacked) ~p~n", [Str]),
            %Reply = lib_misc:string2value(Str),
            Reply = string2value(Str),
            io:format("Server replying = ~p~n", [Reply]),
            gen_tcp:send(Socket, term_to_binary(Reply)),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("Server socket closed~n")
    end.
%%客户端
nano_client_eval(Str) ->
    {ok, Socket} = 
        gen_tcp:connect("localhost", 2345, 
                        [binary, {packet, 4}]),
    ok = gen_tcp:send(Socket, term_to_binary(Str)),
    receive
        {tcp, Socket, Bin} ->
            io:format("Client received binary = ~p~n", [Bin]),
            Val = binary_to_term(Bin),
            io:format("Client result = ~p~n", [Val]),
            gen_tcp:close(Socket)
    end.

string2value(Str) ->
    {ok, Tokens, _} = erl_scan:string(Str ++ "."),
    %% generate
    {ok, Exprs} = erl_parse:parse_exprs(Tokens),
    Bindings = erl_eval:new_bindings(),
    {value, Value, _} = erl_eval:exprs(Exprs, Bindings),
    Value.


%%UDP
start_server() ->
    spawn(fun() -> server(40000) end).

server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary]),
    io:format("server opend socket:~p~n", [Socket]),
    loop_udp(Socket).

loop_udp(Socket) ->
    receive
        {udp, Socket, Host, Port, Bin} = Msg ->  %% ****** make a {} to a string message **********
            io:format("server received:~p~n", [Msg]),
            N = binary_to_term(Bin),
            Fac = fac(N),
            BinReply = "erlang world",
            gen_udp:send(Socket, Host, Port, term_to_binary(Fac)),
            %gen_udp:send(Socket, Host, Port, BinReply),
            loop(Socket)
    end.

fac(0) -> 1;
fac(N) -> N*fac(N-1).

client(Request) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opend socket = ~p~n", [Socket]),
    ok = gen_udp:send(Socket, "localhost", 40000, term_to_binary(Request)),
    Value = receive
                {udp, Socket, _, _, Bin} = Msg -> %{ok, Bin}
                    io:format("client received:~p~n", [Msg]),
                    binary_to_term(Bin)
                %%因为udp不可靠，所以加上超时
                after 2000 -> error
                end,
    gen_udp:close(Socket),
    Value.

clientEx(Request) ->%udp 数据会传两次，为了避免，可以使用make_ref 函数创建一个表示
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opend socket = ~p~n", [Socket]),
    Ref = make_ref(),
    B1 = term_to_binary(Ref, Request),
    ok = gen_udp:send(Socket, "localhost", 40000, B1),
    wait_for_ref(Socket, Ref).

wait_for_ref(Socket, Ref) ->
    receive
        {udp, Socket, _, _, Bin} ->
            case binary_to_term(Bin) of
                %% 在client中添加了标识,从{Ref, Val}这种格式提取出真正的请求
                {Ref, Val} -> Val;
                {_SomeOtherRef, _} ->
                    % 对于其他数据则不能处理
                    wait_for_ref(Socket, Ref)
            end
        after 1000 -> error
    end.
%%error test
error_test() ->
    spawn(fun() -> error_test_server() end),
    lib_misc:sleep(2000),
    {ok, Socket} = gen_tcp:connect("localhost", 4321, [binary, {packet, 2}]),
    io:format("connected to: ~p~n", [Socket]),
    gen_tcp:send(Socket, <<"123">>),
    receive
        Any ->
            io:format("Any~p~n", [Any])
    end.
error_test_server() ->
    {ok, Listen} = gen_tcp:listen(4321, [binary, {packet, 2}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    error_test_server_loop(Socket).

error_test_server_loop(Socket) ->
    receive
        {tcp, Socket, Data} ->
            io:format("received: ~p~n", [Data]),
            %atom_to_list(Data),
            error_test_server_loop(Socket)
    end.
