-module(geometry).
-export([area/1]).
area({rectangle, Width, Height}) -> Width*Height;
area({circle, R}) ->math:pi()*R*R;
area({square, X}) ->X*X.
