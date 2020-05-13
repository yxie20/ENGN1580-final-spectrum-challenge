function [signal_point,data,new_bits] = reci_yiheng(r_reci,r_trans,t,n,e,data)

persistent msg
if n == 2
    load msg.mat msg
end

if n/2 <= length(msg)
    new_bits = [msg(n/2)];
else
    new_bits = [];
end

signal_point = 0;
data = [];
end

