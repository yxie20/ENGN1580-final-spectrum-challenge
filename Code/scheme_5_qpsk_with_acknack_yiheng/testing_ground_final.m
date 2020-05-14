function [result] = testing_ground_final(game_mode,same_msg,name_group_1,name_tra_1,name_rec_1,name_group_2,name_tra_2,name_rec_2)

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
t_max = 120; % HAS TO BE MULTIPLE OF 20!!!!
loop_max = Fs*t_max;
plot_every_n = 5000; % the plot is going to be updated every n
loop_max_out = loop_max/plot_every_n;
loop_max_in = plot_every_n;
t = linspace(0,t_max,loop_max+1);

% Transcript:
r_tra = zeros(1,loop_max+1);
r_rec = zeros(1,loop_max+1);
c_tra = zeros(1,loop_max+1);
c_rec = zeros(1,loop_max+1);

% Message:
msg_size = 100000;
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
h_1 = animatedline('Color','r');
h_2 = animatedline;

subplot(2,2,2);
hold on
title('Energy Left')
axis([0 t_max 0 initial_e_tra])
k_1_1 = animatedline('Color','r');
k_1_2 = animatedline('Color','r');
k_2_1 = animatedline;
k_2_2 = animatedline;

% Plots:
dF = Fs/2000;
f = -Fs/4:dF:Fs/4-dF;

% Scores:
scr_1 = zeros(1,loop_max+1);
scr_2 = zeros(1,loop_max+1);

%% Challenge:

if strcmp(game_mode,'test')
    for i = 0:loop_max_out-1
%     for i = 0:0
        for j = 1:loop_max_in
%         for j = 1:10
            if mod(j,2)
                % Calling transmitter:
                [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i*loop_max_in+j,e_tra_1,scratchpad_tra_1,my_msg_1);
                % Check energy:
                if e_tra_1-(signal_tra_1^(2)) > 0
                    c_tra(i*loop_max_in+j+1) = signal_tra_1;
                    e_tra_1 = e_tra_1-(signal_tra_1^(2));
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                else
                    scratchpad_tra_1 = new_scratchpad_tra_1;
                    my_msg_1 = new_msg_1;
                end
                % Add noise:
                r_tra(i*loop_max_in+j+1) = c_tra(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
            else
                % Calling receiver:
                [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i*loop_max_in+j,e_rec_1,scratchpad_rec_1);
                % Check energy:
                if e_rec_1-(signal_rec_1^(2)) > 0
                    c_rec(i*loop_max_in+j+1) = signal_rec_1;
                    e_rec_1 = e_rec_1-(signal_rec_1^(2));
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                else
                    scratchpad_rec_1 = new_scratchpad_rec_1;
                end
                % Add noise:
                r_rec(i*loop_max_in+j+1) = c_rec(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
        end
        if how_many_1 > msg_size
            warning(join([name_group_1,' tried to send more bits than there are in the message!']))
        end
        % Updating score and plotting:
        scr_1(i*loop_max_in+j) = sum(b_1(1:msg_size)==new_bits_1(1:msg_size));
        ti = t(i*loop_max_in+j);
        addpoints(h_1,ti,scr_1(i*loop_max_in+j));
        addpoints(k_1_1,ti,e_tra_1);
        addpoints(k_1_2,ti,e_rec_1);
        drawnow limitrate
        sub_3 = abs(fftshift(fft(c_tra((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        sub_4 = abs(fftshift(fft(c_rec((i+1)*loop_max_in-999:(i+1)*loop_max_in))))/1000;
        subplot(2,2,3), plot(f,sub_3), title('Spectrum of Transmitters'), axis([0 Fs/4-dF 0 0.25])
        subplot(2,2,4), plot(f,sub_4), title('Spectrum of Receivers'), axis([0 Fs/4-dF 0 0.25])
        clear global variable
    end
elseif strcmp(game_mode,'fight') || strcmp(game_mode,'co_op')
    for i = 0:loop_max_out-1
        for j = 1:loop_max_in
            if mod(j,2)
                % Calling transformers:
                [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i*loop_max_in+j,e_tra_1,scratchpad_tra_1,my_msg_1);
                [signal_tra_2,new_scratchpad_tra_2,new_msg_2] = tra_2(r_tra,r_rec,t,i*loop_max_in+j,e_tra_2,scratchpad_tra_2,my_msg_2);
                % Checking energy:
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
                % Adding noise:
                r_tra(i*loop_max_in+j+1) = c_tra(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
            else
                % Calling recievers:
                [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i*loop_max_in+j,e_rec_1,scratchpad_rec_1);
                [signal_rec_2,new_scratchpad_rec_2,new_bits_rec_2] = rec_2(r_rec,r_tra,t,i*loop_max_in+j,e_rec_2,scratchpad_rec_2);
                % Checking energy:
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
                % Adding noise:
                r_rec(i*loop_max_in+j+1) = c_rec(i*loop_max_in+j+1) + noise(i*loop_max_in+j+1);
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(how_many_2+1:how_many_2+how_many_new_2) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            end
        end
        if how_many_1 > msg_size
            warning(join([name_group_1,' tried to send more bits than there are in the message!']))
        end
        if how_many_2 > msg_size
            warning(join([name_group_2,' tried to send more bits than there are in the message!']))
        end
        % Updating scores and plotting:
        scr_1(i*loop_max_in+j) = sum(b_1(1:msg_size)==new_bits_1(1:msg_size));
        scr_2(i*loop_max_in+j) = sum(b_2(1:msg_size)==new_bits_2(1:msg_size));
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
        subplot(2,2,3), plot(f,sub_3), title('Spectrum of Transmitters'), axis([0 Fs/4-dF 0 0.25])
        subplot(2,2,4), plot(f,sub_4), title('Spectrum of Receivers'), axis([0 Fs/4-dF 0 0.25])
        clear global variable
    end
else
    error('incorrect game mode')
end

% Saving audio file:
%{
if strcmp(game_mode,'test')
    audiowrite(join([name_group_1,'_tra_test.wav']),c_tra/(max(max(abs(c_tra),1)+0.01)),Fs);
    audiowrite(join([name_group_1,'_rec_test.wav']),c_rec/(max(max(abs(c_rec),1)+0.01)),Fs);
elseif strcmp(game_mode,'fight')
    audiowrite(join([name_group_1,'_VS_',name_group_2,'_tra_fight.wav']),c_tra/(max(max(abs(c_tra),1)+0.01)),Fs);
    audiowrite(join([name_group_1,'_VS_',name_group_2,'_rec_fight.wav']),c_rec/(max(max(abs(c_rec),1)+0.01)),Fs);
else
    audiowrite(join([name_group_1,'_VS_',name_group_2,'_tra_co_op.wav']),c_tra/(max(max(abs(c_tra),1)+0.01)),Fs);
    audiowrite(join([name_group_1,'_VS_',name_group_2,'_rec_co_op.wav']),c_rec/(max(max(abs(c_rec),1)+0.01)),Fs);
end
%}

% Calculate BER:
epsilon_1 = max(scr_1)/min(how_many_1,msg_size);
epsilon_2 = max(scr_2)/min(how_many_2,msg_size);

% Calculate capacity:
C_1 = 1 + epsilon_1*log2(epsilon_1) + (1-epsilon_1)*log2(1-epsilon_1);
C_2 = 1 + epsilon_2*log2(epsilon_2) + (1-epsilon_2)*log2(1-epsilon_2);

% Calculate adjusted bits sent:
s1 = min(how_many_1,msg_size)*C_1;
s2 = min(how_many_2,msg_size)*C_2;

% Rate of expense from energy:
e_rate = 1000;

% Score calculator:
if strcmp(game_mode,'test')
    result = s1-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_rec_1))/(initial_e_tra+initial_e_rec));
elseif strcmp(game_mode,'fight')
    result = s1-s2-e_rate*((e_tra_1+e_rec_1-e_tra_2-e_rec_2)/(initial_e_tra+initial_e_rec));
else
    result = min(s1,s2)-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_rec_1+e_tra_2+e_rec_2))/(initial_e_tra+initial_e_rec));
end

end
        
                
