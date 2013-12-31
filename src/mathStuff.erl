-module(mathStuff).
-export([factorial/1,area/1]).
factorial(0)->1;
factorial(N) when N>0->N*factorial(N-1).
%计算正方形面积，参数元组的第一个匹配square    
area({square, Side}) ->
    Side * Side;
%计算圆的面积，匹配circle  
area({circle, Radius}) ->
   % almost :-)
   3 * Radius * Radius;
%计算三角形的面积，利用海伦公式，匹配triangle 
area({triangle, A, B, C}) ->
   S = (A + B + C)/2,
math:sqrt(S*(S-A)*(S-B)*(S-C));
%其他
area(Other) ->
   {invalid_object, Other}.
