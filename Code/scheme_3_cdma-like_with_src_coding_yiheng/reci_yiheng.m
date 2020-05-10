function [signal_point,data,new_bits] = reci_yiheng(r_reci,r_trans,t,n,e,data)

%%%% OUTPUT VARIABLES
% new_bits: an array of size 1x1 when we are ready to return the bit after
% the carrier interval has finished. 1x0 empty array if we are within the
% interval.

% Constants
import constants.*

% Initializations
signal_point = 0;
new_bits = [];

if isempty(data)
    % data: [send_or_silent, silent_time_countdown, carrier_interval_countdown
    % num_predictions_returned]
    data = [0, 0, constants.bit_interval, 0];
    % Print initialization parameters
    fprintf("Receiver hyperparameters--------------\n");
    fprintf("Total bits to send: %d\nbit interval: %d\n",...
    constants.num_bits_to_send, constants.bit_interval);
end

if e == 0 || data(1,4) == constants.num_bits_to_send || ...
    r_trans(end,end) == 154 || r_reci(end,end) == 198
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
                % Correlator receiver
                wave = r_trans(n-constants.bit_interval:n);
                carriers = modulation_scheme(t(1,n-constants.bit_interval:n), 0, 1);
                corr_receiver_out = carriers * wave';
                % Distance-based decoding
                [~, max_ind] = max(corr_receiver_out);
                new_bits = [max_ind-1];
                % Reset constants.bit_interval_countdown
                data(1,2) = 0;
                data(1,3) = constants.bit_interval;
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
            data(1,3) = constants.bit_interval;
        end
    end
end

end

