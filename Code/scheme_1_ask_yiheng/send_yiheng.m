function [signal_point,data,msg] = send_yiheng(r_trans,r_reci,t,n,e,data,msg)

%%%% GLOBAL VARIABLES
% constants.Fs = 25*10^(3);
% constants.t_max = 120;
% loop_max = constants.Fs*constants.t_max+1 = 3000001;

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


% Constants
import constants.*

% Dynamic run-time initializations at first function call
if isempty(data)
    % Calculate amplitude based on constants.bit_interval and total bits to send
    % total energy = constants.bit_interval * constants.num_bits_to_send * amplitude
    amplitude = sqrt(constants.safety_margin*constants.initial_e_tra / ...
        (constants.bit_interval*constants.num_bits_to_send));
    % Trunacte the msg bitstring
    msg = msg(1:constants.num_bits_to_send);
    % Initialize scratchpad
    % data = [send_or_silent, silent_time_countdown, ...
    % carrier_interval_countdown, amplitude];
    data = [0,1,0, amplitude];

    % Check if parameters make sense and print warning messages
    check_parameters();
    % Print initialization parameters
    fprintf("Sender hyperparameters--------------\n");
    fprintf("Amplitude: %.2f\nTotal bits to send: %d\nbit interval: %d\n",...
    amplitude, constants.num_bits_to_send, constants.bit_interval);
end

% Initializations
signal_point = 0;



% If no energy left OR ?? OR ??: Stay silent
if e == 0 || r_trans(end,end) == 154 || r_reci(end,end) == 198
    data(1,1) = 1;
end


% If we are sending over the forward channel
if data(1,1) == 0               
    % If silent_time_countdown is non-positive
    if data(1,2) <= 0
        % If carrier_interval_countdown is positive
        if data(1,3) >= 0
            signal_point = data(1,4)*modulation_scheme(t(1,n), msg(1,1)+1, 0);
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            else
                % After a carrier interval (constants.bit_interval), start next
                % constants.bit_interval immediately
                data(1,2) = 0;
                data(1,3) = constants.bit_interval;
                if length(msg) >= 2
                    msg = msg(1,2:end);
                else            % Finished sending. Remain silent forever.
                    data(1) = 1;
                end
            end
        end
    else
        % If we have silent_time_countdown left, remain silent and keep counting
        if data(1,2) > 1
            data(1,2) = data(1,2) - 1;
        % At the end of silent_time_countdown, start new carrier_inerval_countdown
        else
            data(1,2) = 0;
            data(1,3) = constants.bit_interval;
        end
    end
end

end


function check_parameters()
import constants.*
if (2*constants.bit_interval*constants.num_bits_to_send) > constants.loop_max
    fprintf("[WARNING] Bit interval %d is too long, will not finish sending %d bits in %d seconds",...
            constants.bit_interval, constants.num_bits_to_send, constants.Fs);
end
end