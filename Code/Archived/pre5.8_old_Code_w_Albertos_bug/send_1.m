function [signal_point,new_data,new_msg] = send_1(r_trans,r_reci,t,n,e,data,msg)

signal_point = 0;
new_data = data;
new_msg = msg;

if isempty(data)
    data = [0 1000 0];
    new_data = data;
    r_trans = [0 0];
end

if e == 0 || r_trans(end,end) == 154 || r_reci(end,end) == 198
    data(1,1) = 1;
end

if data(1,1) == 0
    if data(1,2) <= 0
        if data(1,3) >= 0
            if msg(1,1) == 0
                signal_point = sin(2*pi()*10*t(1,n))/1.5;
            else
                signal_point = sin(2*pi()*1000*t(1,n))/1.5;
            end
            if data(1,3)-1 > 0
                new_data(1,3) = data(1,3) - 1;
            else
                new_data(1,3) = 0;
                new_data(1,2) = 3;
                if length(new_msg) >= 2
                    new_msg = msg(1,2:end);
                else
                    new_data(1) = 1;
                end
            end
        end
    else
        if data(1,2)-1 > 0
            new_data(1,2) = data(1,2) - 1;
        else
            new_data(1,2) = 0;
            new_data(1,3) = 450;
        end
    end
end
end