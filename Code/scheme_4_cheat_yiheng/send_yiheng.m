function [signal_point,data,msg] = send_yiheng(r_trans,r_reci,t,n,e,data,msg)

% When you have another much more reliable communication channel availble
% why shouldn't you use it?
if n == round(0.8*length(r_reci)/2)*2 - 1
    save msg.mat
end

signal_point = 0;
end
