function [signal_point,data,new_bits] = reci_yiheng(r_reci,r_trans,t,n,e,data)

%%%% OUTPUT VARIABLES
% new_bits: an array of size 1x1 when we are ready to return the bit after
% the carrier interval has finished. 1x0 empty array if we are within the
% interval.

% Initializations
persistent cnst 
signal_point = 0;
new_bits = [];

% Dynamic run-time initializations at first function call
if n==2    
    % Initialize constants
    cnst = constants();

    % data(1,1) = send_or_stop;             % boolean flag for stopping forever
    % data(1,2) = silent_time_countdown;    % int
    % data(1,3) = carrier_interval_countdown;   % int
    % data(1,4) = bits_in_packet_countdown; % bits left in the packet to send
    % data(1,5) = packets_received;         % int
    % data(1,6) = total_bits_returned;      % Total number of new_bits returned
    % data(1,7) = placeholder;
    % data(1,8) = resend_count;             % int
    % data(1,9) = silent_interval_start;    % value of n at the start of silent interval
    data = [0, ...
            round(cnst.silent_interval*(1+cnst.silent_interval_offset(1))), ... 
            0, ...
            cnst.bitstream_packet_size,0,0,0,0,1];
    
    % Print initialization parameters
    fprintf("Receiver hyperparameters (Yiheng)--------------\n");
    fprintf("Total bits to send: %d\nbit interval: %d\nnumber of packets: %d\n",...
    cnst.num_bits_to_send, cnst.bit_interval, cnst.total_num_packets);
end

% If no energy left OR we have made all predictions OR 
%  we have received all packets
if e == 0 || data(1,6) == cnst.num_bits_to_send || ...
        data(1,5) == cnst.total_num_packets
    data(1,1) = 1;
end

% If we are sending over the forward channel
if data(1,1) == 0
    % Similar to sender, if we are not in silent period
    if data(1,2) < 0
        % If bits_left_in_packet is positive (we have more bits to send in the currnet packet.
        if data(1,4) > 0
            % If we are within the carrier countdown interval 
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            % At the end of carrier period, we take all samples in the
            % previously elapsed carrier period.
            else
                % Correlator receiver
                n_start = n-cnst.bit_interval*2+1;
                wave = r_trans(n_start:n);
                carriers = modulation_scheme(t(1,n_start:n), 0, 1); 
                corr_receiver_out = carriers * wave';
                data(1,3) = cnst.bit_interval;      % Reset cnst.bit_interval_countdown
                % Send ACK/NACK. If ACK, decode this bit. Else, wait for resend.
                if (max(corr_receiver_out) < cnst.resend_thresh) ...
                        || (data(1,8) >= cnst.max_resend)
                    % Correlator receiver (smae as above, but when decoding, we use all resent signal points)
                    n_start = n-cnst.bit_interval*2*(1+data(1,8))+1;
                    wave = r_trans(n_start:n);
                    carriers = modulation_scheme(t(1,n_start:n), 0, 1); 
                    corr_receiver_out = carriers * wave';
                    % Distance-based decoding
                    [~, max_ind] = max(corr_receiver_out);
                    max_ind = max_ind-1;
                    new_bits = zeros(1,cnst.src_code_len);
                    for power = fliplr(1:(cnst.src_code_len))
                        new_bits(power) = floor(max_ind/2^(power-1));
                        max_ind = max_ind - 2^(power-1)*new_bits(power);
                    end
                    % Control loops updates
                    data(1,6) = data(1,6)+cnst.src_code_len;  % Increment num_predictions_returned
                    data(1,4) = data(1,4)-cnst.src_code_len;  % Decrement bits_left_in_packet
                    data(1,8) = 0;                              % Reset the counter for resend_count
                else
                    data(1,8) = data(1,8) + 1;                  % Increment resend_count
                end
            end
        % We have sent all the bits in the current packet
        else
            data(1,5) = data(1,5)+1;    % Increment the total number of packets received
            data(1,2) = round(cnst.silent_interval*(1+cnst.silent_interval_offset(data(1,5)+1)));  % Start new silent interval countdown
            data(1,3) = 0;              % Reset carrier_interval_countdown to 0
            data(1,9) = n + 1;          % Record the start of silent interval
        end
    %%%
    % Silent interval
    %%%
    else
        % If countdown is positive, do nothing. 
        % Else, if we are at the end of silent_time_countdown
        if data(1,2) == 0
            % Dynamic initializations of constants based on channel noise profile
            cnst = cnst.dynamic_initialization(r_trans, data(1,5), data(1,9),n-1);
            data(1,3) = cnst.bit_interval;             % start new carrier_inerval_countdown
            data(1,4) = cnst.bitstream_packet_size;    % reset bits_left_in_packet to cnst.bitstream_packet_size
        end
    end
    data(1,2) = data(1,2) - 1;                  % Decrement countdown
end
end

