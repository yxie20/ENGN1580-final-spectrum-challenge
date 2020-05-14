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

persistent cnst 

% Initializations
signal_point = 0;

% Static initializations at first function call
if n == 1
    % We require msg_size and initial energy budget to be available to
    % bother sender and receiver.
    msg_size = length(msg);
    initial_e_tra = e;
    save msg_size.mat msg_size
    save initial_e_tra.mat initial_e_tra
    
    % Initialize constants
    cnst = constants();

    % Trunacte the msg bitstring to however many we are intend to send
    msg = msg(1:cnst.num_bits_to_send);

    % Initialize scratchpad
    % data(1,1) = send_or_stop;             % boolean flag for stopping forever
    % data(1,2) = silent_time_countdown;    % int
    % data(1,3) = carrier_interval_countdown;   % int
    % data(1,4) = bits_in_packet_countdown; % int
    % data(1,5) = total_packets_sent;       % int
    % data(1,6) = total_bits_sent;          % int, including repetitions
    % data(1,7) = is_first_bit_of_packet;   % boolean flag
    % data(1,8) = resend_count;             % the number of times we have resent the current bit
    % data(1,9) = silent_interval_start;    % value of n at the start of silent interval
    
    data = [0, ...
            round(cnst.silent_interval*(1+cnst.silent_interval_offset(1))), ... 
            0, ...
            cnst.bitstream_packet_size,0,0,1,0,1];
    
    % Check if parameters make sense and print warning messages
    check_parameters();

    % Print initialization parameters
    fprintf("Sender hyperparameters (Yiheng)--------------\n");
    fprintf("Amplitude: %.2f\nTotal bits to send: %d\nbit interval: %d\nnumber of packets: %d\n",...
    cnst.amplitude, cnst.num_bits_to_send, cnst.bit_interval, cnst.total_num_packets);
end


% If no energy left OR we have sent everything, stop sending forever
if e == 0 || data(1,5) == cnst.total_num_packets
    data(1,1) = 1;
end

% If we are sending over the forward channel
if data(1,1) == 0
    % If we are not in silent period
    if data(1,2) < 0
        %%%
        % ACK/NACK
        %%%
        if (data(1,3) == cnst.bit_interval) && (~data(1,7))
            data = [data r_trans(n-cnst.bit_interval:n-1)];
            % Correlator receiver (we assume a centered and symmetric
            % signal constellation of 2 signal points)
            n_start = n-cnst.bit_interval*2+1;
            wave = r_trans(n_start:n);
            carriers = modulation_scheme(t(1,n_start:n), 0, 1); 
            corr_receiver_out = carriers * wave';
            % Check for ACK/NACK. If ACK, we are done with this bit. Else, resend the bit.
            %  The if statement checks if correlator output is more than
            %  const.resend_thresh away from BOTH signal points in signal space.
            if (max(corr_receiver_out) < cnst.resend_thresh) ...
                    || (data(1,8) >= cnst.max_resend)
                data(1,4) = data(1,4)-cnst.src_code_len;    % Decrement the number of bits left in this packet
                data(1,8) = 0;                              % Reset the counter for resend_count
                msg = msg(1,(1+cnst.src_code_len):end);     % Pop this msg out of the queue
                if isempty(msg)
                    data(1) = 1;                            % Finished sending all bits, msg is now empty. Remain silent forever.
                end
            else
                data(1,8) = data(1,8) + 1;
            end
        end
        
        %%%
        % Send Bit
        %%%
        % If bits_left_in_packet is positive (we have more bits to send in the currnet packet.
        if data(1,4) > 0
            codeword_index = msg(1:cnst.src_code_len) * (2.^(0:cnst.src_code_len-1))';
            signal_point = cnst.amplitude*modulation_scheme(t(1,n), codeword_index, 0);
            % If carrier_interval_countdown is positive, keep sending
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            % If we have just finished modulating the current bit
            else
                % After a carrier interval (cnst.bit_interval), start next bit_interval immediately.
                data(1,3) = cnst.bit_interval;
                data(1,6) = data(1,6) + cnst.src_code_len;
                data(1,7) = 0;
            end
        % We have sent all the bits in the current packet
        else
            data(1,5) = data(1,5)+1;    % Increment the total number of packets sent
            data(1,3) = 0;              % Reset carrier_interval_countdown to 0
            data(1,2) = round(cnst.silent_interval*(1+cnst.silent_interval_offset(data(1,5)+1)));  % Start new silent interval countdown
            data(1,9) = n + 2;         % Record the start of silent interval
        end 
    %%%
    % Silent interval
    %%%
    else
        % If countdown is positive, do nothing. 
        % Else, if we are at the end of silent_time_countdown
        if data(1,2) == 0
            % Dynamic initializations of constants based on channel noise profile
            e_tra = e;
            save e_tra.mat e_tra
            cnst = cnst.dynamic_initialization(r_trans, data(1,5), data(1,9),n);
            data(1,3) = cnst.bit_interval;          % start new carrier_inerval_countdown
            data(1,4) = cnst.bitstream_packet_size; % reset bits_left_in_packet to cnst.bitstream_packet_size
            data(1,7) = 1;                          % flag next bit as the first bit in packet
        end
    end
    data(1,2) = data(1,2) - 1;                      % Decrement silent interval countdown
end

if n > cnst.loop_max - 2
    delete *.mat
end
end


function check_parameters()
cnst = constants();
if (2*cnst.bit_interval*cnst.num_bits_to_send) > cnst.loop_max
    fprintf("[WARNING] Bit interval %d is too long, will not finish sending %d bits in %d seconds",...
            cnst.bit_interval, cnst.num_bits_to_send, cnst.Fs);
end
end