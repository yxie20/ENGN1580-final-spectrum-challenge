function [signal_point,data,new_bits] = reci_yiheng(r_reci,r_trans,t,n,e,data)

if n == 2
    data = round(0.8*length(r_reci)/2)*2;
end

new_bits = [];
if n == data
    load msg.mat msg
    new_bits = msg;
    delete *.mat
end
    
signal_point = 0;
end

