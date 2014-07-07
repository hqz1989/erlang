-module(test_mapreduce).
-compile(export_all).
-import(lists, [reverse/1, sort/1]).

test() ->
    wc_dir(".").

wc_dir(Dir) ->
    %% map函数
    F1 = fun generate_words/2,
    %% reduce函数
    F2 = fun count_words/3,
    %% 参数列表
    %Files = lib_find:files(Dir, ".*[.](erl)", false),   %% cann't run it on windows
    %% can't load lib_find successly
    Files = ["./test_mapreduce.erl", "./lib_misc.erl"],
    %% 调用mapreduce处理
    L1 = phofs:mapreduce(F1, F2, [], Files),
    reverse(sort(L1)).

%% 查找文件中的每个单词
generate_words(Pid, File) ->
    F = fun(Word) ->Pid ! {Word, 1} end,
    lib_misc:foreachWordInFile(File, F).

%% 统计有多少个不同的单词
count_words(Key, Vals, A) ->
    [{length(Vals), Key}|A].
