http://hideto.iteye.com/blog/226639

Eshell> chat_server:start(9999).  
$$ client1  
Eshell> chat_send_client:start("localhost", 9999).  
Eshell> chat_recv_client:start("localhost", 9999).  
$$ client2  
Eshell> chat_send_client:start("localhost", 9999).  
Eshell> chat_recv_client:start("localhost", 9999). 