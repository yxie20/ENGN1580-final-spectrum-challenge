% testing_ground_4_chris_yiheng('test', 1,'group1',@send_yiheng,@reci_yiheng,'group2',@send_2,@reci_2)
function [result] = testing_ground_4_chris_yiheng(game_mode,same_msg,name_group_1,name_tra_1,name_rec_1,name_group_2,name_tra_2,name_rec_2)

clf('reset')

%% Initial Conditions:

% Checking for optional variables (player 2):
if ~exist('name_group_2','var')
    name_group_2 = 'NA';
    name_tra_2 = 'NA';
    name_rec_2 = 'NA';
end

% Assigning names through inputs:
name_1 = join([name_group_1,' (red)']);
tra_1 = name_tra_1;
rec_1 = name_rec_1;

name_2 = join([name_group_2,' (black)']);
tra_2 = name_tra_2;
rec_2 = name_rec_2;

% Time:
Fs = 25*10^(3);
% t_max = 120; % HAS TO BE MULTIPLE OF 20!!!!
t_max = 60; % HAS TO BE MULTIPLE OF 20!!!!  %%%
loop_max = Fs*t_max;
plot_every_n = 10000;
loop_max_out = loop_max/plot_every_n;
loop_max_in = plot_every_n;
t = linspace(0,t_max,loop_max+1);

% Transcript:
r_tra = zeros(1,loop_max+1);
r_rec = zeros(1,loop_max+1);
c_tra = zeros(1,loop_max+1);
c_rec = zeros(1,loop_max+1);

% Message:
msg_size = 10000;
% msg_size = 1000;   %%%
b_1 = randi([0 1],1,msg_size);
if same_msg == 1
    b_2 = b_1;
else
    b_2 = randi([0 1],1,msg_size);
end
my_msg_1 = b_1;
my_msg_2 = b_2;
new_bits_1 = zeros(1,msg_size);
new_bits_2 = zeros(1,msg_size);
for i = 1:msg_size
    if b_1(i) == 0
        new_bits_1(i) = 1;
    else
        new_bits_1(i) = 0;
    end
    if b_2(i) == 0
        new_bits_2(i) = 1;
    else
        new_bits_2(i) = 0;
    end
end
how_many_1 = 0;
how_many_2 = 0;

% Scratchpad:
scratchpad_tra_1 = [];
scratchpad_rec_1 = [];
scratchpad_tra_2 = [];
scratchpad_rec_2 = [];

% energy:
initial_e_tra = 1000000;
initial_e_rec = 1000000;
e_tra_1 = initial_e_tra;
e_tra_2 = initial_e_tra;
e_rec_1 = initial_e_rec;
e_rec_2 = initial_e_rec;

% Noise:
sig = 10;
noise = normrnd(0,sig,[1,loop_max+1]);

% Animated line:
subplot(2,2,1);
hold on
if strcmp(game_mode,'test')
    title(name_1)
else
    title(join([name_1,' VS ',name_2]))
end
axis([0 t_max 0 msg_size])
h_1 = animatedline('Color','r');
h_2 = animatedline;

subplot(2,2,2);
hold on
title('Energy Left')
axis([0 t_max 0 initial_e_tra])
k_1_1 = animatedline('Color','r','LineStyle', '-');
k_1_2 = animatedline('Color','r','LineStyle', ':');
k_2_1 = animatedline('LineStyle', '-');
k_2_2 = animatedline('LineStyle', ':');

% Plots:
dF = Fs/2000;
f = -Fs/4:dF:Fs/4-dF;

% Scores:
scr_1 = zeros(1,loop_max+1);
scr_2 = zeros(1,loop_max+1);

%% Challenge:

if strcmp(game_mode,'test')
    for i = 0:loop_max_out-1
        for j = 1:loop_max_in
            if mod(j,2) 
                [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i*loop_max_in+j,e_tra_1,scratchpad_tra_1,my_msg_1);
                if e_tra_1-(signal_tra_1^(2)) > 0
                    c_tra(i*loop_max_in+j+1) = signal_tra_1;
                    e_tra_1 = e_tra_1-(signal_tra_1^(2));
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                else
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                end
		%% ADD PRECOMPUTED CHANNEL NOISE
                r_tra(i*loop_max_in+j+1) = c_tra(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
            else
                [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i*loop_max_in+j,e_rec_1,scratchpad_rec_1);
                if e_rec_1-(signal_rec_1^(2)) > 0
                    c_rec(i*loop_max_in+j+1) = signal_rec_1;
                    e_rec_1 = e_rec_1-(signal_rec_1^(2));
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                else
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                end
		%% ADD PRECOMPUTED CHANNEL NOISE
                r_rec(i*loop_max_in+j+1) = c_rec(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
		%% TALLY NEW BITS DECODED for Receiver 1
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
        end
	%% PLOT THE BITS CORRECT AND NOISELESS CHANNEL SPECTRA
        scr_1(i*loop_max_in+j) = sum(b_1(1:how_many_1)==new_bits_1(1:how_many_1));
        ti = t(i*loop_max_in+j);
        addpoints(h_1,ti,scr_1(i*loop_max_in+j));
        addpoints(k_1_1,ti,e_tra_1);
        addpoints(k_1_2,ti,e_rec_1);
        drawnow limitrate
        sub_3 = abs(fftshift(fft(c_tra((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        sub_4 = abs(fftshift(fft(c_rec((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
%%        sub_3 = abs(fftshift(fft(r_tra((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
%%        sub_4 = abs(fftshift(fft(r_rec((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        subplot(2,2,3), plot(f,sub_3), title('Forward Channel Spectrum'), axis([0 Fs/4-dF 0 0.25])
        subplot(2,2,4), plot(f,sub_4), title('Feedback Channel Spectrum'), axis([0 Fs/4-dF 0 0.25])
        clear global variable
    end
elseif strcmp(game_mode,'fight') || strcmp(game_mode,'co_op')
    for i = 0:loop_max_out-1
        for j = 1:loop_max_in
            if mod(j,2) 
                [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i*loop_max_in+j,e_tra_1,scratchpad_tra_1,my_msg_1);
                [signal_tra_2,new_scratchpad_tra_2,new_msg_2] = tra_2(r_tra,r_rec,t,i*loop_max_in+j,e_tra_2,scratchpad_tra_2,my_msg_2);
                if e_tra_1-(signal_tra_1^(2)) > 0
                    c_tra(i*loop_max_in+j+1) = signal_tra_1;
                    e_tra_1 = e_tra_1-(signal_tra_1^(2));
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                else
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                end
                if e_tra_2-(signal_tra_2^(2)) > 0
                    c_tra(i*loop_max_in+j+1) = c_tra(i*loop_max_in+j+1) + signal_tra_2;
                    e_tra_2 = e_tra_2-(signal_tra_2^(2));
                    scratchpad_tra_2 = new_scratchpad_tra_2;
                    my_msg_2 = new_msg_2;
                else
                    scratchpad_tra_2 = new_scratchpad_tra_2;
                    my_msg_2 = new_msg_2;
                end
		%% ADD PRECOMPUTED CHANNEL NOISE
                r_tra(i*loop_max_in+j+1) = c_tra(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
            else
                [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i*loop_max_in+j,e_rec_1,scratchpad_rec_1);
                [signal_rec_2,new_scratchpad_rec_2,new_bits_rec_2] = rec_2(r_rec,r_tra,t,i*loop_max_in+j,e_rec_2,scratchpad_rec_2);
                if e_rec_1-(signal_rec_1^(2)) > 0
                    c_rec(i*loop_max_in+j+1) = signal_rec_1;
                    e_rec_1 = e_rec_1-(signal_rec_1^(2));
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                else
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                end
                if e_rec_2-(signal_rec_2^(2)) > 0
                    c_rec(i*loop_max_in+j+1) = c_rec(i*loop_max_in+j+1) + signal_rec_2;
                    e_rec_2 = e_rec_2-(signal_rec_2^(2));
                    scratchpad_rec_2 = new_scratchpad_rec_2;
                else
                    scratchpad_rec_2 = new_scratchpad_rec_2;
                end
		%% ADD PRECOMPUTED CHANNEL NOISE
                r_rec(i*loop_max_in+j+1) = c_rec(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
		%% TALLY NEW BITS DECODED for Receiver 1
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
		% TALLY NEW BITS DECODED for Receiver 2
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(how_many_2+1:how_many_2+how_many_new_2) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            end
        end
	%% PLOT THE BITS CORRECT AND NOISELESS CHANNEL SPECTRA
	scr_1(i*loop_max_in+j) = sum(b_1(1:how_many_1)==new_bits_1(1:how_many_1));
        scr_2(i*loop_max_in+j) = sum(b_2(1:how_many_2)==new_bits_2(1:how_many_2));
        ti = t(i*loop_max_in+j);
        addpoints(h_1,ti,scr_1(i*loop_max_in+j));
        addpoints(h_2,ti,scr_2(i*loop_max_in+j));
        addpoints(k_1_1,ti,e_tra_1);
        addpoints(k_1_2,ti,e_rec_1);
        addpoints(k_2_1,ti,e_tra_2);
        addpoints(k_2_2,ti,e_rec_2);
        drawnow limitrate
        sub_3 = abs(fftshift(fft(c_tra((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        sub_4 = abs(fftshift(fft(c_rec((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
%        sub_3 = abs(fftshift(fft(r_tra((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
%        sub_4 = abs(fftshift(fft(r_rec((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        subplot(2,2,3), plot(f,sub_3), title('Forward Channel Spectrum'), axis([0 Fs/4-dF 0 0.25])
        subplot(2,2,4), plot(f,sub_4), title('Feedback Channel Spectrum'), axis([0 Fs/4-dF 0 0.25])
        clear global variable
    end
else
    error('incorrect game mode')
end



% NOW DO THE SCORING
%% s1 = max(scr_1);
%% s2 = max(scr_2);
%% CALCULATE BER
epsilon_1 = max(scr_1)/how_many_1;
epsilon_2 = max(scr_2)/how_many_2;
%% CALCULATE CAPACITY
C_1 = 1 + epsilon_1*log2(epsilon_1) + (1-epsilon_1)*log2(1-epsilon_1);
C_2 = 1 + epsilon_2*log2(epsilon_2) + (1-epsilon_2)*log2(1-epsilon_2);


%% CALCULATE GOODPUT
s1 = how_many_1*C_1;
s2 = how_many_2*C_2;

%% SET THE ENERGY PENALTY
e_rate = 1000;

%% SPIT OUT THE SCORE!!!!!
if strcmp(game_mode,'test')
    result = s1-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_rec_1))/(initial_e_tra+initial_e_rec));
elseif strcmp(game_mode,'fight')
    result = s1-s2-e_rate*((e_tra_1+e_rec_1-e_tra_2-e_rec_2)/(initial_e_tra+initial_e_rec));
else
    result = min(s1,s2)-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_rec_1+e_tra_2+e_rec_2))/(initial_e_tra+initial_e_rec));
end

end
        
                
