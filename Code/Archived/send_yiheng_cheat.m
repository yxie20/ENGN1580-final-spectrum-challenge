function [signal_point,data,msg] = send_yiheng_cheat(r_trans,r_reci,t,n,e,data,msg)

%%%% GLOBAL VARIABLES
% Fs = 25*10^(3);
% t_max = 120;
% loop_max = Fs*t_max+1 = 3000001;

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

% Special initialization at first iteration
if isempty(data)
    % data: [send_or_silent, silent_time_countdown, carrier_interval_countdown]
    data = [0 1 0];
end

% Constants
bit_interval = 130;         % Carrier period
amplitude = 1.2;              % Scaler on how much energy to use

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
            % Modulation for bit 1
            if msg(1,1) == 0    
                signal_point = cos(2*pi()*1000*t(1,n))*amplitude + 1i;
            % Modulation for bit 0
            else
                signal_point = sin(2*pi()*1000*t(1,n))*amplitude;
            end
            if data(1,3) > 1
                data(1,3) = data(1,3) - 1;
            else
                % After a carrier interval (bit_interval), stay silent for 3 samples
                data(1,2) = 0;
                data(1,3) = bit_interval;
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
            data(1,3) = bit_interval;
        end
    end
end

% signal_point
% data
% msg(1:6)
end