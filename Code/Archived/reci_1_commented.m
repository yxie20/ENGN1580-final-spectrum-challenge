function [signal_point,data,new_bits] = reci_1_commented(r_reci,r_trans,t,n,e,data)

%%%% OUTPUT VARIABLES
% new_bits: an array of size 1x1 when we are ready to return the bit after
% the carrier interval has finished. 1x0 empty array if we are within the
% interval.

signal_point = 0;
new_bits = [];

if isempty(data)
    % At the beginning of the competition, stay silent for 1000 samples
    % data: [send_or_silent, silent_time_countdown, carrier_interval_countdown]
    data = [0 1000 0];
end

if e == 0 || r_trans(end,end) == 154 || r_reci(end,end) == 198
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
                data(1,3) = 0;
                data(1,2) = 3;
                wave = r_trans(n-450:n);
                % Correlator receiver
                ax_1 = sin(2*pi()*10*t(1,n-450:n));
                ax_2 = sin(2*pi()*1000*t(1,n-450:n));
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
        % Same as sender, if we have silent_time_countdown left, remain silent and keep counting
        if data(1,2) > 1
            data(1,2) = data(1,2) - 1;
        % Same as sender, at the end of silent_time_countdown, start new carrier_inerval_countdown
        else
            data(1,2) = 0;
            data(1,3) = 450;
        end
    end
end
end