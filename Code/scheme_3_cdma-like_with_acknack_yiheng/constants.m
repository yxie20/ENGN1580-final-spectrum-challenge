classdef constants
    %%%
    % Assumptions on Prof. Rose's global variables. The following MUST be 
    %  updated if they are changed in the arena code:
    %  Fs, t_max, loop_max, noise_std, initial_e_tra, msg_size
    %  As long as they are set accordingly, our program will run smoothly.
    % 
    % [Dynamic]: Variables that depend on the arena setup, set during runtime
    % [Tunable param]: Tunable parameter, tuned to maximize score
    % [UNLABELLED]: parameters calculated based on [Dynamic] and [Tunable param]
    %%%
    properties
        % Global variables from Prof. Rose--------------------
        Fs = 25*10^(3);             % Sampling rate
        t_max = 120;                % Competition time
        loop_max;                   % Number of iterations
        noise_mean;                 % [Dynamic] 
        noise_std;                  % [Dynamic] Spectral height of Gaussian Noise
        initial_e_tra;              % [Dynamic] Energy budget for sender
        msg_size;                   % [Dynamic] Total bits available to send
        % Energies--------------------------------------------
        safety_margin = 0.95;       % [Tunable param] Safety threshold for energy use
        amplitude;                  % Amplitude scalar for carriers
        bits_sent_ratio;            % Fraction of bits sent
        energy_usage_ratio;         % Fraction of energy budget used
        % Hyperparameters-------------------------------------
        num_bits_to_send = 80000;   % [Tunable param] Total number of bits we intend to send
        bit_interval = 1;           % Carrier period T (minimum 1)
        % For time hopping and silent intervals---------------
        % This is random seed for silent time offset. We support sending 
        %  the entire bitstream in 100 "packets". 1x100 array range(-.5,0.5)
        silent_interval_offset = [-0.0438135345262580,-0.148829599221747,-0.202663428131696,-0.300607535770285,0.0276506782377569,-0.356336843187468,0.100274478734666,-0.267693739464320,0.212779774184266,-0.447157821908358,0.216046163406427,-0.376102918172107,0.145642187790661,0.221290068379167,-0.433732205370294,-0.224276131619455,0.123148465853195,0.391884567075949,0.331618846456591,-0.351121312554462,0.403195911922918,-0.296477141114719,0.237074462952851,-0.259943319240061,-0.0504900385373306,0.302734315468343,0.191132674466306,0.163412523060404,0.0386277123294072,0.466832746699551];
        % Set to 1 if you want to send everything within the first few itreations.
        %  Otherwise we have a stair looking graph for correct bits sent.
        total_num_packets = 8;      % [Tunable param] How many packets we divide the total bitstream into.
        bitstream_packet_size;      % Number of bit in each packet.
        silent_interval;     % Average length of each silence interval
        % For Ack/Nack----------------------------------------
        P_resend = 0.35;            % [Tunable param] The probability of resending a bit.
        expected_total_bits_to_send;% The total bits we expect to send (counting the repetition of bad ones)
        resend_thresh;              % Threshold distance away from signal point (in signal space) that will trigger bit resend (i.e. Nack threshold)
        resend_interval;            % Besed on the Threshold, the interval in which we resend 
        max_resend = 3;             % [Tunable param] How many resends we allow in total
    end
    
    methods(Static)
        function this=constants()
            %%%
            % Class constructor method. All static variables but require
            % calcualtions are initialized below.
            %%%            
            % Global Variables--------------------------------------
            load msg_size.mat msg_size
            load initial_e_tra.mat initial_e_tra
            this.msg_size = msg_size;
            this.initial_e_tra = initial_e_tra;
            this.loop_max = this.Fs*this.t_max;
            % For time hopping and silent intervals-----------------
            this.silent_interval = round(this.loop_max / (2*this.total_num_packets));
            this.bitstream_packet_size = round(this.num_bits_to_send / this.total_num_packets);
            % For Ack/Nack and energy calculations------------------
            % The expected total bits to send is the num_bits_to_send times
            %  the expectation Geometric random variable with p = P_resend
            this.expected_total_bits_to_send = this.num_bits_to_send*(1/(1-this.P_resend));
            % Calculate amplitude by energy balance: total energy = cnst.bit_interval * cnst.num_bits_to_send * amplitude^2
            this.amplitude = sqrt(this.safety_margin*this.initial_e_tra / ...
                (this.bit_interval*this.expected_total_bits_to_send));
        end
    end
    methods
        function this = dynamic_initialization(this, r_trans, num_packets_sent, silent_interval_start, silent_interval_end)
            %%%
            % Dynamic initializations at the end of each silent interval.
            %  The variables loaded from disk belos must be set correctly 
            %  before calling constructors.
            %
            % Inputs:
            %  r_trans, the same array in sender and receiver (transcript)
            %  num_packets_sent, int
            %  silent_interval_start, int, value of n at the start of silent interval
            %  silent_interval_end, int, value of n at the end of silent interval
            % 
            % Goal: Given the noise by itself, analyze it and dynamically
            %  calculate for the resend threshold so that our actual 
            %  probabiltiy of resending a bit match P_resend set.
            %%%            
            % Step 1: model the noise, get mean and std
            silence_wave = r_trans(r_trans(silent_interval_start:silent_interval_end)~=0);
            this.noise_mean = mean(silence_wave);
            if abs(this.noise_mean) < 0.2
                this.noise_mean = 0;            % Assume a zero-mean noise with 0.2 tolerance
            end
            this.noise_std = std(silence_wave);
            if abs(this.noise_std - 10) < 1
                this.noise_std = 10;            % Assume sigma was not changed
            end
            
            % Step 2: Scale amplitude to meet energy budget (only when transmitter calls this script)
            load e_tra.mat e_tra
            this.bits_sent_ratio = num_packets_sent / this.total_num_packets;
            this.energy_usage_ratio = 1 - min(1, e_tra / (this.safety_margin * this.initial_e_tra));
            this.amplitude = this.amplitude * (1-this.energy_usage_ratio)/(1-this.bits_sent_ratio);

            % Step 3: From P_resend calculate the resend_thresh 
            % iteratively, since an analytic equation for cdf is difficult to define.
            resend_thresh_guess = norminv(1-this.P_resend,0,this.noise_std);    % Always an underestimate of threshold
            P_resend_guess = normcdf(2*this.amplitude-resend_thresh_guess,0,this.noise_std) - normcdf(resend_thresh_guess,0,this.noise_std);
            diff = P_resend_guess - this.P_resend;
            while abs(diff) > 0.001
                resend_thresh_guess = resend_thresh_guess + diff*this.noise_std;
                P_resend_guess = normcdf(2*this.amplitude-resend_thresh_guess,0,this.noise_std) - normcdf(resend_thresh_guess,0,this.noise_std);
                diff = P_resend_guess - this.P_resend;
            end
            this.resend_thresh = resend_thresh_guess;
            this.resend_interval = this.amplitude - this.resend_thresh;

        end
    end
end