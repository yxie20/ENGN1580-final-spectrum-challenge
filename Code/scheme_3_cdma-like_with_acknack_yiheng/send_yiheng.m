function [signal_point,data,msg] = send_yiheng(r_trans,r_reci,t,n,e,data,msg)

%%%% INPUT VARIABLES
% r_trans transcript of everything sent so far over the TRANSMITTER channel.
% r_trans = 1xloop_max vector = 1x3000001 vector w/ only EVEN entries
% r_reci transcript of everything sent so far over the RECEIVER channel.
% r_reci = 1xloop_max vector = 1x3000001 vector w/ only ODD entries
% Time vector
% t = [0   13.3333   26.6667   40.0000   53.3333   66.6667   80.0000   93.3333  106.6667  120.0000]
% n time vector index of current time
% n = 1; n = 3; n = 5 ... (at each function call)
% e energy left for the transmitter
% e = 1000000
% data: scratchpad
% data is empty upon first pass, data is passed in as data at next iteration
% msg: the payload (bitstring to encode zeros and ones)
% msg = 1x1000 vector

%%%% OUTPUT VARIABLES
% msg: updated bitstring paylond, decreases in size by 1 when bit sent
% msg = 1x1000 vector; msg = 1x999 vector; ...
% signal_point: next point in the transmitted waveform.
% signal_point = a real number (i.e. a sample of 
% data: updated scratchpad
% fprintf("trans")
% n
% r_trans(1:6)
% r_reci(1:6)
persistent cnst 

% Dynamic run-time initializations at first function call
if isempty(data)
    % Initialize constants
    cnst = constants();
    
    % Trunacte the msg bitstring to however many we are intend to send
    msg = msg(1:cnst.num_bits_to_send);

    % Initialize scratchpad
    % data(1,1) = send_or_stop;             % boolean flag for stopping forever
    % data(1,2) = silent_time_countdown;    % int
    % data(1,3) = carrier_interval_countdown;   % int
    % data(1,4) = amplitude;                % same as cnst.amplitude
    % data(1,5) = bits_in_packet_countdown; % int
    % data(1,6) = total_packets_sent;       % int
    % data(1,7) = total_bits_sent;          % int
    % data(1,8) = is_first_bit_of_packet;   % boolean flag
    data = [0, 0, cnst.bit_interval, cnst.amplitude, ...
            cnst.bitstream_packet_size, 0, 0, 1];
    
    % Check if parameters make sense and print warning messages
    check_parameters();

    % Print initialization parameters
    fprintf("Sender hyperparameters--------------\n");
    fprintf("Amplitude: %.2f\nTotal bits to send: %d\nbit interval: %d\nnumber of packets: %d\nResend Prob.: %.2f\nMin. Resend Prob.: %.2f\n",...
    cnst.amplitude, cnst.num_bits_to_send, cnst.bit_interval, cnst.total_num_packets, cnst.P_resend, cnst.min_P_resend);
end

% Initializations
signal_point = 0;

% If no energy left OR we have sent everything, stop sending forever
if e == 0 || data(1,6) == cnst.total_num_packets
    data(1,1) = 1;
end

% If we are sending over the forward channel
if data(1,1) == 0
    % If silent_time_countdown is non-positive
    if data(1,2) <= 0            
        %%%
        % ACK/NACK
        %%%
        if (data(1,3) == cnst.bit_interval) && (~data(1,8))
            % Correlator receiver
            wave = r_trans(n-cnst.bit_interval:n);
            carriers = modulation_scheme(t(1,n-cnst.bit_interval:n), 0, 1); % Here we assume a centered and symmetric signal constellation of 2 signal points
            corr_receiver_out = carriers * wave';
            % Check for ACK/NACK. If ACK, we are done with this bit. Else, resend the bit.
            %  The if statement checks if correlator output is more than
            %  const.resend_thresh away from BOTH signal points in signal space.
            if sum((corr_receiver_out-cnst.amplitude)>cnst.resend_thresh) < 2
                data(1,5) = data(1,5)-1;    % Decrement the number of bits left in this packet
                msg = msg(1,2:end);         % Pop this msg out of the queue
                if isempty(msg)
                    data(1) = 1;            % Finished sending all bits, msg is now empty. Remain silent forever.
                end
            end
        end
        
        %%%
        % Send Bit
        %%%
        % If bits_left_in_packet is positive (we have more bits to send in the currnet packet.
        if data(1,5) > 0
            signal_point = cnst.amplitude*modulation_scheme(t(1,n), msg(1,1)+1, 0);
            % If carrier_interval_countdown is positive, keep sending
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            % If we have just finished modulating the current bit
            else
                % After a carrier interval (cnst.bit_interval), start next bit_interval immediately.
                data(1,3) = cnst.bit_interval;
                data(1,7) = data(1,7) + 1;
                data(1,8) = 0;
            end
        % We have sent all the bits in the current packet
        else
            data(1,6) = data(1,6)+1;    % Increment the total number of packets sent
            data(1,3) = 0;              % Reset carrier_interval_countdown to 0
            data(1,2) = round(cnst.silent_interval_length*(1+cnst.silent_interval_offset(data(1,6))));  % Stay silent for cnst.silent_interval_length + offset
        end
        
    %%%
    % Silent interval countdown
    %%%
    else
        data(1,2) = data(1,2) - 1;                  % Decrement countdown
        % At the end of silent_time_countdown
        if data(1,2) == 0
            data(1,3) = cnst.bit_interval;          % start new carrier_inerval_countdown
            data(1,5) = cnst.bitstream_packet_size; % reset bits_left_in_packet to cnst.bitstream_packet_size
            data(1,8) = 1;                          % flag next bit as the first bit in packet
        end
    end
end
%%%
if n > (cnst.loop_max - 2)
    msg
    data
end
end


function check_parameters()
cnst = constants();
if (2*cnst.bit_interval*cnst.num_bits_to_send) > cnst.loop_max
    fprintf("[WARNING] Bit interval %d is too long, will not finish sending %d bits in %d seconds",...
            cnst.bit_interval, cnst.num_bits_to_send, cnst.Fs);
end
end