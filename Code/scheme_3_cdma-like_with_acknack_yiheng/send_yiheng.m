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

% Dynamic run-time initializations at first function call
if isempty(data)
    % Initialize constants
    cnst = constants();
    % Calculate amplitude based on cnst.bit_interval and total bits to send
    % total energy = cnst.bit_interval * cnst.num_bits_to_send * amplitude^2
    amplitude = sqrt(cnst.safety_margin*cnst.initial_e_tra / ...
        (cnst.bit_interval*cnst.num_bits_to_send));
    
    % Trunacte the msg bitstring to however many we are intend to send
    msg = msg(1:cnst.num_bits_to_send);

    % Initialize scratchpad
    % data = [send_or_silent, silent_time_countdown, carrier_interval_countdown, amplitude, ...
    %         bits_left_in_packet, packets_sent];
    data = [0, 0, cnst.bit_interval, amplitude, ...
            cnst.bitstream_packet_size, 0];
    
    % Check if parameters make sense and print warning messages
    check_parameters();

    % Print initialization parameters
    fprintf("Sender hyperparameters--------------\n");
    fprintf("Amplitude: %.2f\nTotal bits to send: %d\nbit interval: %d\nnumber of packets: %d\n",...
    amplitude, cnst.num_bits_to_send, cnst.bit_interval, cnst.bitstream_packet_size);
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
        % If bits_left_in_packet is positive (we have more bits to send in the currnet packet.
        if data(1,5) > 0
            signal_point = data(1,4)*modulation_scheme(t(1,n), msg(1,1)+1, 0);
            % If carrier_interval_countdown is positive, keep sending
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            % If we have just finished modulating the current bit
            else
                if length(msg) >= 2                 % Pop this msg out of the queue
                    msg = msg(1,2:end);
                else
                    data(1) = 1;                    % Finished sending all bits, msg is not empty. Remain silent forever.
                end
                % Control loops updates
                data(1,3) = cnst.bit_interval; % After a carrier interval (cnst.bit_interval), start next bit_interval immediately.
                data(1,5) = data(1,5)-1;            % Decrement the number of bits left in this packet
            end
        % We have sent all the bits in the current packet
        else
            data(1,6) = data(1,6)+1;    % Increment the total number of packets sent
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


function check_parameters()
cnst = constants();
if (2*cnst.bit_interval*cnst.num_bits_to_send) > cnst.loop_max
    fprintf("[WARNING] Bit interval %d is too long, will not finish sending %d bits in %d seconds",...
            cnst.bit_interval, cnst.num_bits_to_send, cnst.Fs);
end
end