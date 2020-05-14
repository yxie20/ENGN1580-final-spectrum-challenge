function [signal_point,new_data,new_msg] = send_kaan(r_trans,r_reci,t,n,e,data,msg)

signal_point = 0;
new_data = data;
new_msg = msg;

if isempty(data)
    data = [0 1000 0 -5];
    new_data = data;
    r_trans = [0 0];
end

if e == 0 || r_trans(end,end) == 154 || r_reci(end,end) == 198
    data(1,1) = 1;
end

if data(1,1) == 0
    if data(1,2) <= 0
        if data(1,3) >= 0
          if data(1,4) < 5 && data(1,4) >= 0
              jammer = fft(r_trans);
              data(1,4) = data(1,4) + 1;
          end
          if data(1,4) < 0
              data(1,4) = data(1,4) + 1;
          end
          if data(1,4) == 5
              data(1,4) = data(1,4) - 10;
          end
            if msg(1,1) == 0
                if msg(1,2) == 0
                    signal_point = sin(2*pi()*2000*t(1,n))/1 + cos(2*pi()*2000*t(1,n))/1 + ...
                    sin(2*pi()*jammer(1,1)*t(1,n))/1 + cos(2*pi()*jammer(1,2)*t(1,n))/1;
                else
                    signal_point = sin(2*pi()*2000*t(1,n))/1 + -1 * cos(2*pi()*2000*t(1,n))/1 + ...
                        sin(2*pi()*jammer(1,1)*t(1,n))/1 + cos(2*pi()*jammer(1,2)*t(1,n))/1;
                end  
            else
                if msg(1,2) == 0
                    signal_point = -1 * sin(2*pi()*2000*t(1,n))/1 - cos(2*pi()*2000*t(1,n))/1 + ...
                        sin(2*pi()*jammer(1,1)*t(1,n))/1 + cos(2*pi()*jammer(1,2)*t(1,n))/1;
                else
                    signal_point = -1 * sin(2*pi()*2000*t(1,n))/1 + cos(2*pi()*2000*t(1,n))/1 + ...
                        sin(2*pi()*jammer(1,1)*t(1,n))/1 + cos(2*pi()*jammer(1,2)*t(1,n))/1;
                end
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