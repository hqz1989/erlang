-module(my_server).  
start(Port) ->  
  connection_handler:start(my_server, Port, businees_logic).  
  
business_logic(Socket) ->  
  % Read data from the network socket and do our thang!  
%%http://hideto.iteye.com/blog/246373
