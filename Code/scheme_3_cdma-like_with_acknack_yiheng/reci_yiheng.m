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
if isempty(data)
    % Initialize constants
    cnst = constants();
    % data: [send_or_silent, silent_time_countdown, carrier_interval_countdown
    % num_predictions_returned, bits_left_in_packet, packets_received];]
    data = [0, 0, cnst.bit_interval, ...
            0, cnst.bitstream_packet_size, 0];
    % Print initialization parameters
    fprintf("Receiver hyperparameters--------------\n");
    fprintf("Total bits to send: %d\nbit interval: %d\nnumber of packets: %d\n",...
    cnst.num_bits_to_send, cnst.bit_interval, cnst.bitstream_packet_size);
end

% If no energy left OR we have made all predictions OR 
%  we have received all packets
if e == 0 || data(1,4) == cnst.num_bits_to_send || ...
        data(1,6) == cnst.total_num_packets
    data(1,1) = 1;
end

% If we are sending over the forward channel
if data(1,1) == 0
    % Similar to sender, if we are not in silent period
    if data(1,2) <= 0
        % If bits_left_in_packet is positive (we have more bits to send in the currnet packet.
        if data(1,5) > 0
            % If we are within the carrier countdown interval 
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            % At the end of carrier period, we take all samples in the
            % previously elapsed carrier period.
            else
                % Correlator receiver
                wave = r_trans(n-cnst.bit_interval:n);
                carriers = modulation_scheme(t(1,n-cnst.bit_interval:n), 0, 1);
                corr_receiver_out = carriers * wave';
                % Distance-based decoding
                [~, max_ind] = max(corr_receiver_out);
                new_bits = [max_ind-1];
                % Control loops updates
                data(1,3) = cnst.bit_interval; % Reset cnst.bit_interval_countdown
                data(1,4) = data(1,4)+1;            % Increment num_predictions_returned
                data(1,5) = data(1,5)-1;            % Decrement bits_left_in_packet
            end
        % We have sent all the bits in the current packet
        else
            data(1,6) = data(1,6)+1;    % Increment the total number of packets received
            data(1,3) = 0;              % Reset carrier_interval_countdown to 0
            data(1,2) = round(cnst.silent_interval_length*(1+cnst.silent_interval_offset(data(1,6))));  % Stay silent for cnst.silent_interval_length + offset
        end
    else
        data(1,2) = data(1,2) - 1;                  % Decrement countdown
        % At the end of silent_time_countdown
        if data(1,2) == 0
            data(1,3) = cnst.bit_interval;             % start new carrier_inerval_countdown
            data(1,5) = cnst.bitstream_packet_size;    % reset bits_left_in_packet to cnst.bitstream_packet_size
        end
    end
end
end

