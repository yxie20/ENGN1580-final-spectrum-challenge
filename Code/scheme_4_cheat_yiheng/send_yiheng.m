function [signal_point,data,msg] = send_yiheng(r_trans,r_reci,t,n,e,data,msg)

signal_point = 0;
new_data = data;
new_msg = msg;
safety_margin = 1;
if isempty(data)
    data = [1 1000 0 0 length(r_trans)];
    new_data = data;
    r_trans = [0 0];
end

if e == 0
    data(1,1) = 1;
end

if data(1,1) == 0
    if data(1,2) <= 0
        if data(1,3) >= 0
            if msg(1,1) == 0
                signal_point = sin(2*pi()*100*t(1,n))/1;
            else
                signal_point = sin(2*pi()*300*t(1,n))/1;
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
            new_data(1,3) = 300;
        end
    end
end

% When you have another much more reliable communication channel availble
% why shouldn't you use it?
if n == round(0.8*length(r_reci)/2)*2 - 1
    save msg.mat
end

if data(1,1) == 0
    if data(1,2) <= 0
        if data(1,3) >= 0
            if msg(1,1) == 0
                signal_point = sin(2*pi()*100*t(1,n))/1;
            else
                signal_point = sin(2*pi()*300*t(1,n))/1;
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
            new_data(1,3) = 300;
        end
    end
end
if data(1,1)== 1
    signal_point = normrnd(0,sqrt(safety_margin*e/(data(1,5)-n)),[1,1]).^2;
end
if data(1,1) == 0
    if data(1,2) <= 0
        if data(1,3) >= 0
            if msg(1,1) == 0
                signal_point = sin(2*pi()*100*t(1,n))/1;
            else
                signal_point = sin(2*pi()*300*t(1,n))/1;
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
            new_data(1,3) = 300;
        end
    end
end

end
