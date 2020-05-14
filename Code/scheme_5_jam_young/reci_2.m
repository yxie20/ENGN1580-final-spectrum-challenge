function [signal_point,new_data,new_bits] = reci_2(r_reci,r_trans,t,n,e,data)

signal_point = 0;
new_data = data;
new_bits = [];

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
            if data(1,3)-1 > 0
                new_data(1,3) = data(1,3) - 1;
            else
                new_data(1,3) = 0;
                new_data(1,2) = 3;
                wave = r_trans(n-300:n);
                ax_1 = sin(2*pi()*100*t(1,n-300:n));
                ax_2 = sin(2*pi()*300*t(1,n-300:n));
                t_1 = dot(wave,ax_1);
                t_2 = dot(wave,ax_2);
                if t_1 > t_2
                    new_bits = [new_bits,0];
                else
                    new_bits = [new_bits,1];
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