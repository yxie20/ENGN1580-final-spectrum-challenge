clear all

%% Initial Conditions
% In this section I initialize and set the parameters for the challenge

game_mode = 'fight'; % type of challenge (test, fight, co_op)

tra_1 = @send_1; % first transmitter
tra_2 = @send_2; % second transmitter

rec_1 = @reci_1; % first receiver
rec_2 = @reci_2; % second receiver

name_1 = join(['Group 1',' (red)']);
name_2 = join(['Group 2',' (black)']);

sig = 10;

Fs = 25*10^(3); % sampling frequency (Hz)
t_max = 400; % total given time (s)
loop_max = Fs*t_max+1; % number of iterations in a loop
t = linspace(0,t_max,loop_max); % time line [0 1/Fs 2/Fs ... t_max]
r_tra = zeros(1,loop_max); % list of everything sent by transmitters
r_rec = zeros(1,loop_max); % list of everything sent by recivers

msg_size = 10000; % number of bits in the messages
msg_bias_1 = 0; % fixing first probability of 1s and 0s (-1-> all 0s, +1-> all 1s)
msg_bias_2 = 0; % fixing second probability of 1s and 0s (-1-> all 0s, +1-> all 1s)

initial_e_tra = 1000000; % initial energy for transmitter
initial_e_rec = 1000000; % initial energy for receiver

res_1 = []; % results from first receiver
res_2 = []; % results from second receiver

res_size = 20000;
new_bits_1 = zeros(1,res_size); % bits for first to attach to res_1
new_bits_2 = zeros(1,res_size); % bits for first to attach to res_2
how_many_1 = 0; % how many bits have been send by first so far
how_many_2 = 0; % how many bits have been send by second so far

scratchpad_tra_1 = []; % vector that can be used to keep track of the first transmitter
scratchpad_tra_2 = []; % vector that can be used to keep track of the second transmitter

scratchpad_rec_1 = []; % vector that can be used to keep track of the first receiver
scratchpad_rec_2 = []; % vector that can be used to keep track of the second receiver

c_1 = 0; % counter that keeps tally of the first score
c_2 = 0; % counter that keeps tally of the second score

b_1 = round(rand(1,msg_size)+msg_bias_1); % first message
b_2 = round(rand(1,msg_size)+msg_bias_2); % second message

my_msg_1 = b_1; % gives the first control of how to senf their message
my_msg_2 = b_2; % gives the second control of how to senf their message

e_tra_1 = initial_e_tra; % initializing energy left for first transmitter
e_tra_2 = initial_e_tra; % initializing energy left for second transmitter

e_rec_1 = initial_e_rec; % initializing energy left for first receiver
e_rec_2 = initial_e_rec; % initializing energy left for second receiver

h_1 = animatedline('Color','r');
h_2 = animatedline;

%% The Challenge

if strcmp(game_mode,'test') % checking if the game mode is test
    for i = 1:loop_max-1
        if mod(i,2)
            [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_1,my_msg_1);
            if energ(e_tra_1,signal_tra_1) > 0
                r_tra(i+1) = channel(signal_tra_1,0,0,sig);
                e_tra_1 = energ(e_tra_1,signal_tra_1);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            else
                r_tra(i+1) = channel(0,0,0,sig);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            end
        else
            [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i,e_rec_1,scratchpad_rec_1);
            if energ(e_rec_1,signal_rec_1) > 0
                r_rec(i+1) = channel(signal_rec_1,0,0,sig);
                e_reci_1 = energ(e_rec_1,signal_rec_1);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            else
                r_rec(i+1) = channel(0,0,0,sig);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
        end
        if mod(i+1000,2000) == 0 || mod(i+1999,2000) == 0
            ti = t(i);
            errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
            scr_1 = msg_size - errors_1;
            addpoints(h_1,ti,scr_1);
            title(name_1)
            drawnow limitrate
            clear global variable
        end
    end
elseif strcmp(game_mode,'fight') % checking if the game mode is fight
    for i = 1:loop_max-1
        if mod(i,2)
            [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_1,my_msg_1);
            [signal_tra_2,new_scratchpad_tra_2,new_msg_2] = tra_2(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_2,my_msg_2);
            if energ(e_tra_1,signal_tra_1) > 0
                r_tra(i+1) = channel(signal_tra_1,0,0,sig);
                e_tra_1 = energ(e_tra_1,signal_tra_1);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            else
                r_tra(i+1) = channel(0,0,0,sig);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            end
            if energ(e_tra_2,signal_tra_2) > 0
                r_tra(i+1) = channel(signal_tra_2,r_tra(i+1),0,sig);
                e_tra_2 = energ(e_tra_2,signal_tra_2);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            else
                r_tra(i+1) = channel(0,r_tra(i+1),0,sig);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            end
        else
            [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i,e_rec_1,scratchpad_rec_1);
            [signal_rec_2,new_scratchpad_rec_2,new_bits_rec_2] = rec_2(r_rec,r_tra,t,i,e_rec_2,scratchpad_rec_2);
            if energ(e_rec_1,signal_rec_1) > 0
                r_rec(i+1) = channel(signal_rec_1,0,0,sig);
                e_reci_1 = energ(e_rec_1,signal_rec_1);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            else
                r_rec(i+1) = channel(0,0,0,sig);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
            if energ(e_rec_2,signal_rec_2) > 0
                r_rec(i+1) = channel(signal_rec_2,r_rec(i+1),0,sig);
                e_reci_2 = energ(e_rec_2,signal_rec_2);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2+1) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            else
                r_rec(i+1) = channel(0,r_rec(i+1),0,sig);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2+1) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            end
        end
        if mod(i+1000,2000) == 0 || mod(i+1999,2000) == 0
            ti = t(i);
            errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
            scr_1 = msg_size - errors_1;
            errors_2 = dot(b_2-new_bits_2(1:msg_size),b_2-new_bits_2(1:msg_size));
            scr_2 = msg_size - errors_2;
            addpoints(h_1,ti,scr_1);
            addpoints(h_2,ti,scr_2);
            title(join([name_1,' ',name_2]))
            drawnow limitrate
            clear global variable
        end
    end
elseif strcmp(game_mode,'co_op') % checking if the game mode is co_op
    for i = 1:loop_max-1
        if mod(i,2)
            [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_1,my_msg_1);
            [signal_tra_2,new_scratchpad_tra_2,new_msg_2] = tra_2(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_2,my_msg_2);
            if energ(e_tra_1,signal_tra_1) > 0
                r_tra(i+1) = channel(signal_tra_1,0,0,sig);
                e_tra_1 = energ(e_tra_1,signal_tra_1);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            else
                r_tra(i+1) = channel(0,0,0,sig);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            end
            if energ(e_tra_2,signal_tra_2) > 0
                r_tra(i+1) = channel(signal_tra_2,r_tra(i+1),0,sig);
                e_tra_2 = energ(e_tra_2,signal_tra_2);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            else
                r_tra(i+1) = channel(0,r_tra(i+1),0,sig);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            end
        else
            [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i,e_rec_1,scratchpad_rec_1);
            [signal_rec_2,new_scratchpad_rec_2,new_bits_rec_2] = rec_2(r_rec,r_tra,t,i,e_rec_2,scratchpad_rec_2);
            if energ(e_rec_1,signal_rec_1) > 0
                r_rec(i+1) = channel(signal_rec_1,0,0,sig);
                e_reci_1 = energ(e_rec_1,signal_rec_1);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            else
                r_rec(i+1) = channel(0,0,0,sig);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1+1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
            if energ(e_rec_2,signal_rec_2) > 0
                r_rec(i+1) = channel(signal_rec_2,r_rec(i+1),0,sig);
                e_reci_2 = energ(e_rec_2,signal_rec_2);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2+1) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            else
                r_rec(i+1) = channel(0,r_rec(i+1),0,sig);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2+1) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            end
        end
        if mod(i+1000,2000) == 0 || mod(i+1999,2000) == 0
            ti = t(i);
            errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
            scr_1 = msg_size - errors_1;
            errors_2 = dot(b_2-new_bits_2(1:msg_size),b_2-new_bits_2(1:msg_size));
            scr_2 = msg_size - errors_2;
            addpoints(h_1,ti,scr_1);
            addpoints(h_2,ti,scr_2);
            title(join([name_1,' ',name_2]))
            drawnow limitrate
            clear global variable
        end
    end
else
    error('incorrect game mode')
end

e_rate = 0.1;

if strcmp(game_mode,'test') % checking if the game mode test
    result_1 = (scr_1/msg_size)+e_rate*((e_tra_1+e_reci_1)/(initial_e_tra+initial_e_rec));
elseif strcmp(game_mode,'fight') % checking if the game mode fight
    result_1 = (scr_1/msg_size)+e_rate*((e_tra_1+e_reci_1)/(initial_e_tra+initial_e_rec));
    result_2 = (scr_2/msg_size)+e_rate*((e_tra_2+e_reci_2)/(initial_e_tra+initial_e_rec));
else
    result_1 = min((scr_1/msg_size),(scr_2/msg_size))+e_rate*((e_tra_1+e_reci_1)/(initial_e_tra+initial_e_rec));
    result_2 = min((scr_1/msg_size),(scr_2/msg_size))+e_rate*((e_tra_2+e_reci_2)/(initial_e_tra+initial_e_rec));
end