classdef constants
    %%%
    % Assumptions on Prof. Rose's global variables. The following MUST be 
    %  updated if they are changed in the arena code:
    %  Fs, t_max, loop_max, sigma, initial_e_tra, msg_size
    %  As long as they are set accordingly, our program will run smoothly.
    %%%
    properties
        % Global variables from Prof. Rose--------------------
        Fs = 25*10^(3);             % Sampling rate
        t_max = 120;                % Competition time
        loop_max;                   % Number of iterations
        sigma = 10;                 % [Assumption] Spectral height of Gaussian Noise
        initial_e_tra = 1000000;    % [Assumption] Energy budget
        msg_size = 10000            % [Assumption] Total bits available to send
        % Energies--------------------------------------------
        safety_margin = 0.95;       % [Tunable param] Safety threshold for energy use
        amplitude;                  % Amplitude scalar for carriers
        % Hyperparameters-------------------------------------
        num_bits_to_send = 8000;    % [Tunable param] Total number of bits we intend to send
        bit_interval = 1;           % Carrier period T (minimum 1)
        % For time hopping and silent intervals---------------
        % This is random seed for silent time offset. We support sending 
        %  the entire bitstream in 100 "packets". 1x100 array range(-.5,0.5)
        silent_interval_offset = [-0.0438135345262580,-0.0148829599221747,0.202663428131696,-0.300607535770285,0.0276506782377569,-0.356336843187468,0.140274478734666,-0.267693739464320,0.312779774184266,-0.447157821908358,0.416046163406427,-0.276102918172107,0.445642187790661,0.221290068379167,-0.433732205370294,0.0242761316194552,0.123148465853195,0.391884567075949,0.331618846456591,-0.351121312554462,0.403195911922918,-0.296477141114719,0.237074462952851,-0.259943319240061,-0.0504900385373306,0.302734315468343,0.191132674466306,0.163412523060404,0.0386277123294072,0.466832746699551,0.234995517204692,-0.196680167109377,-0.467887732936889,0.127175071193463,-0.372225505142499,-0.351137964409569,-0.231114833151237,-0.0798634733932579,0.0804855883693257,0.267899146816279,0.213189808960666,0.357536685566954,0.346045527296878,0.402850472440455,0.342090673428003,0.452253703237540,-0.414031829714538,0.363832939761713,-0.157778559528406,-0.0455114412903066,0.113638582419906,-0.305146680066273,0.387605358734382,0.0223778504512511,0.414157634669542,-0.456871798328552,-0.108934473371293,0.138214661147598,0.463926138712559,0.000183789070529405,0.358086021191746,0.343692840532775,-0.0436696821238034,0.208326268971125,-0.461939694665117,0.237611768785465,-0.0783986939575632,0.456748353082202,-0.0547802205045993,0.00882174464650787,-0.497376812336200,0.0572115643866381,-0.0699376444805681,-0.178911121767768,0.415947247792085,-0.0705602465402205,0.400458124854212,-0.432142059379354,-0.0777103527760008,-0.279803840101586,-0.167895750397518,0.0279769815537296,-0.468657488965028,0.431522179051116,-0.140547429731142,0.342854741345920,0.0790024248122713,-0.0306764523988643,0.176824552216715,0.498241438009076,-0.166593841640918,-0.402488614166983,0.498558982833689,-0.474352530886873,0.373343379201915,0.0457085779852494,-0.191772574090077,-0.00768111266702221,0.390907471932666,0.490485192432720];
        % Set to 1 if you want to send everything within the first few itreations.
        %  Otherwise we have a stair looking graph for correct bits sent.
        total_num_packets = 8;      % [Tunable param] How many packets we divide the total bitstream into.
        bitstream_packet_size;      % Number of bit in each packet.
        silent_interval_length;     % Average length of each silence interval
        % For Ack/Nack----------------------------------------
        P_resend = 0.2;             % [Tunable param] The probability of resending a bit.
        expected_total_bits_to_send;% The total bits we expect to send (counting the repetition of bad ones)
        resend_thresh;              % Threshold distance away from signal point (in signal space) that will trigger bit resend (i.e. Nack threshold)
        resend_interval;            % Besed on the Threshold, the interval in which we resend 
        max_resend = 20;             % [Tunable param] How many resends we allow in total
    end
    
    methods(Static)
        function this=constants()
            %%%
            % Class constructor method. All dynamic initializations (those 
            % that require calculations are below.
            %%%            
            % Global Variables--------------------------------------
            this.loop_max = this.Fs*this.t_max;
            % For time hopping and silent intervals-----------------
            this.silent_interval_length = round(this.loop_max / (2*this.total_num_packets));
            this.bitstream_packet_size = round(this.num_bits_to_send / this.total_num_packets);
            % For Ack/Nack and energy calculations------------------
            % The expected total bits to send is the num_bits_to_send times
            %  the expectation Geometric random variable with p = P_resend
            this.expected_total_bits_to_send = this.num_bits_to_send*(1/(1-this.P_resend));
            % Calculate amplitude by energy balance: total energy = cnst.bit_interval * cnst.num_bits_to_send * amplitude^2
            this.amplitude = sqrt(this.safety_margin*this.initial_e_tra / ...
                (this.bit_interval*this.expected_total_bits_to_send));
            % From P_resend calculate the resend_thresh (iteratively, since
            %  an analytic equation for cdf is difficult to define.
            resend_thresh_guess = norminv(1-this.P_resend,0,10);    % Always an underestimate of threshold
            P_resend_guess = normcdf(2*this.amplitude-resend_thresh_guess,0,this.sigma) - normcdf(resend_thresh_guess,0,this.sigma);
            diff = P_resend_guess - this.P_resend;
            while abs(diff) > 0.001
                resend_thresh_guess = resend_thresh_guess + diff*this.sigma;
                P_resend_guess = normcdf(2*this.amplitude-resend_thresh_guess,0,this.sigma) - normcdf(resend_thresh_guess,0,this.sigma);
                diff = P_resend_guess - this.P_resend;
            end
            this.resend_thresh = resend_thresh_guess;
            this.resend_interval = this.amplitude - this.resend_thresh;
        end
    end
end