http://hideto.iteye.com/blog/232476

D:\erl\code>erl  
Eshell V5.6.3  (abort with ^G)  
1> gen_event:start_link({local, error_man}).  
{ok,<0.31.0>}  
2> gen_event:add_handler(error_man, terminal_logger1, []).  
ok  
3> gen_event:add_handler(error_man, terminal_logger2, []).  
ok  
4> gen_event:add_handler(error_man, terminal_logger3, []).  
ok  
5> gen_event:which_handlers(error_man).  
[terminal_logger3,terminal_logger2,terminal_logger1]  
6> gen_event:notify(error_man, "Hideto").  
*** Error3 *** "Hideto"  
ok  
*** Error2 *** "Hideto"  
7> *** Error1 *** "Hideto"  
7>  