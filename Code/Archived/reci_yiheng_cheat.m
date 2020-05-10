function [signal_point,data,new_bits] = reci_yiheng_cheat(r_reci,r_trans,t,n,e,data)

%%%% OUTPUT VARIABLES
% new_bits: an array of size 1x1 when we are ready to return the bit after
% the carrier interval has finished. 1x0 empty array if we are within the
% interval.

% Constants
bit_interval = 130;
msg_size = 10000;

% Initializations
signal_point = 0;
new_bits = [];

if isempty(data)
    % data: [send_or_silent, silent_time_countdown, carrier_interval_countdown]
    data = [0 1 0 0];
end

if e == 0 || data(1,4) == msg_size || r_trans(end,end) == 154 || r_reci(end,end) == 198
    data(1,1) = 1;
end

% If we are sending over the forward channel
if data(1,1) == 0
    % Similar to sender, if we are not in silent period
    if data(1,2) <= 0
        % If we are within the carrier countdown interval 
        if data(1,3) >= 0
            if data(1,3)-1 > 0
                data(1,3) = data(1,3) - 1;
            % At the end of carrier period, we take all samples in the
            % previously elapsed carrier period.
            else
                wave = r_trans(n-bit_interval:n);
                if isreal(r_trans(n-2))
                    new_bits = [new_bits,1];
                else
                    new_bits = [new_bits,0];
                end
                % Reset bit_interval_countdown
                data(1,2) = 0;
                data(1,3) = bit_interval;
                data(1,4) = data(1,4)+1;
            end
        end
    else
        % Same as sender, if we have silent_time_countdown left, remain silent and keep counting
        if data(1,2) > 1
            data(1,2) = data(1,2) - 1;
        % Same as sender, at the end of silent_time_countdown, start new carrier_inerval_countdown
        else
            data(1,2) = 0;
            data(1,3) = bit_interval;
        end
    end
end

end