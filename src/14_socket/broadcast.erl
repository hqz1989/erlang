-module(broadcast).
-compile(export_all).

send(IoList) ->
    %% 获取网卡en0的IP信息
    case inet:ifget("en0", [broadaddr]) of
        {ok, [{broadaddr, Ip}]} ->
            %%打开5010端口
            {ok, S} = gen_udp:open(5010, [{broadcast, true}]),
            %%向本地网络6000端口发送广播数据
            gen_udp:send(S, Ip, 6000, IoList),
            gen_udp:close(S);
        _ ->
            io:format("Bad interface name, or broadcastng not supported")
    end.

listen() ->
    %%监听6000端口的广播
    {ok, _} = gen_udp:open(6000),
    loop().

loop()->
    receive
        Any ->
            %%打印任何收到的数据
            io:format("receive:~p~n", [Any]),
            loop()
    end.
