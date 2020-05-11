classdef constants
    properties (Constant)
        num_bits_to_send = 10000;   % Total number of bits we intend to send
        Fs = 25*10^(3);             % Sampling rate
        t_max = 120;                % Competition time
        loop_max = 120*25*10^3;     % Number of iterations
        % Energies
        initial_e_tra = 1000000;    % Energy budget
        safety_margin = 0.99;       % Safety threshold for energy use
        % Hyperparameters
        bit_interval = 2;         % Carrier period T
    end
end