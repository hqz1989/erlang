-module(phofs).
-export([mapreduce/4]).
-import(lists, [foreach/2]).

%%F1 (Pid, X) -> sends {Key, Val} messages to Pid
%%F2 (Key, [Val], AccIn) -> AccOut

mapreduce(F1, F2, Acc0, L) ->
    S = self(),
    %% 启动新的进程运行reduce函数 
    Pid = spawn(fun() -> reduce(S, F1, F2, Acc0, L) end),
    receive
        {Pid, Result} ->
            Result
    end.

reduce(Parent, F1, F2, Acc0, L) ->
    process_flag(trap_exit, true),
    ReducePid = self(),

    %% map过程的实现
    %% 对于列表中的每个值都启动一个进程在do_job中调用F1进行处理 
    foreach(fun(X) ->
            spawn_link(fun() ->do_job(ReducePid, F1, X) end)
        end, L),
    N = length(L),
    %% 用字典存储键值
    Dict0 = dict:new(),
    %% 等待map过程完成
    Dict1 = collect_replies(N, Dict0),
    %% 调用F2按相同键值进行合并 
    Acc = dict:fold(F2, Acc0, Dict1),
    %% 向MapReduce进程通知运行结果
    Parent ! {self(), Acc}.

%% 按键值进行合并的过程
collect_replies(0, Dict) ->
    Dict;
collect_replies(N, Dict) ->
    receive
        %% 对键-值的处理
        %% 存在Key则将Val相加, 否则插入到字典
        {Key, Val} ->
            case dict:is_key(Key, Dict) of
                true ->
                    Dict1 = dict:append(Key, Val, Dict),
                    collect_replies(N, Dict1);
                false ->
                    Dict1 = dict:store(Key,[Val], Dict),
                    collect_replies(N, Dict1)
            end;
        {'EXIT', _,  _Why} ->
            collect_replies(N-1, Dict)
    end.

%% 执行指定的map函数
do_job(ReducePid, F, X) ->
    F(ReducePid, X).
