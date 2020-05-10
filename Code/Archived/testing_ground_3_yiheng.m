% testing_ground_3_yiheng('test', 1,'group1',@send_yiheng,@reci_yiheng,'group2',@send_2,@reci_2)
function [result] = testing_ground_3_yiheng(game_mode,same_msg,name_group_1,name_tra_1,name_rec_1,name_group_2,name_tra_2,name_rec_2)

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
t_max = 120;
loop_max = Fs*t_max+1;
t = linspace(0,t_max,loop_max);

% Transcript:
r_tra = zeros(1,loop_max);
r_rec = zeros(1,loop_max);
c_tra = zeros(1,loop_max);
c_rec = zeros(1,loop_max);

% Message:
msg_size = 100;
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

% Animated line:
sub_1 = subplot(2,2,1);
cla(sub_1)
h_1 = animatedline('Color','r');
h_2 = animatedline;

% Plots:
dF = Fs/2000;
f = -Fs/4:dF:Fs/4-dF;

% Scores:
scr_1 = zeros(1,msg_size);
scr_2 = zeros(1,msg_size);

%% Challenge:

if strcmp(game_mode,'test')
    for i = 1:loop_max-1
        if mod(i,2)
            [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_1,my_msg_1);
            if enorg(e_tra_1,signal_tra_1) > 0
                [c_tra(i+1),r_tra(i+1)] = channol(signal_tra_1,0,0,sig);
                e_tra_1 = enorg(e_tra_1,signal_tra_1);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            else
                [c_tra(i+1),r_tra(i+1)] = channol(0,0,0,sig);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            end
        else
            [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i,e_rec_1,scratchpad_rec_1);
            if enorg(e_rec_1,signal_rec_1) > 0
                [c_rec(i+1),r_rec(i+1)] = channol(signal_rec_1,0,0,sig);
                e_reci_1 = enorg(e_rec_1,signal_rec_1);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            else
                [c_rec(i+1),r_rec(i+1)] = channol(0,0,0,sig);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
        end
        if (mod(i+4999,10000) == 0 && i-4998 > 0) || (mod(i,10000) == 0 && i-4998 > 0)
            ti = t(i);
            errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
            scr_1(i) = msg_size - errors_1;
            addpoints(h_1,ti,scr_1(i));
            drawnow limitrate
            title(name_1)
            subplot(2,2,2)
            hold on
            plot(-1,e_tra_1,'r*')
            plot(-0.5,e_rec_1,'r*')
            hold off
            xlim([-1.5 0])
            ylim([0 initial_e_tra+1])
            title('energy Left')
            sub_3 = abs(fftshift(fft(c_tra(i-999:i))))/1000;
            subplot(2,2,3)
            plot(f,sub_3)
            title('Spectrum of Transmitters')
            axis([0 Fs/4-dF 0 0.25])
            sub_4 = abs(fftshift(fft(c_rec(i-999:i))))/1000;
            subplot(2,2,4)
            plot(f,sub_4)
            title('Spectrum of Receivers')
            axis([0 Fs/4-dF 0 0.25])
            clear global variable
        end
    end
    errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
    scr_1 = [scr_1 msg_size - errors_1];
elseif strcmp(game_mode,'fight') || strcmp(game_mode,'co_op')
    for i = 1:loop_max-1
        if mod(i,2)
            [signal_tra_1,new_scratchpad_tra_1,new_msg_1] = tra_1(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_1,my_msg_1);
            [signal_tra_2,new_scratchpad_tra_2,new_msg_2] = tra_2(r_tra,r_rec,t,i,e_tra_1,scratchpad_tra_2,my_msg_2);
            if enorg(e_tra_1,signal_tra_1) > 0
                [c_tra(i+1),r_tra(i+1)] = channol(signal_tra_1,0,0,sig);
                e_tra_1 = enorg(e_tra_1,signal_tra_1);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            else
                [c_tra(i+1),r_tra(i+1)] = channol(0,0,0,sig);
                scratchpad_tra_1 = new_scratchpad_tra_1;
                my_msg_1 = new_msg_1;
            end
            if enorg(e_tra_2,signal_tra_2) > 0
                [c_tra(i+1),r_tra(i+1)] = channol(signal_tra_2,c_tra(i+1),0,sig);
                e_tra_2 = enorg(e_tra_2,signal_tra_2);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            else
                [c_tra(i+1),r_tra(i+1)] = channol(0,c_tra(i+1),0,sig);
                scratchpad_tra_2 = new_scratchpad_tra_2;
                my_msg_2 = new_msg_2;
            end
        else
            [signal_rec_1,new_scratchpad_rec_1,new_bits_rec_1] = rec_1(r_rec,r_tra,t,i,e_rec_1,scratchpad_rec_1);
            [signal_rec_2,new_scratchpad_rec_2,new_bits_rec_2] = rec_2(r_rec,r_tra,t,i,e_rec_2,scratchpad_rec_2);
            if enorg(e_rec_1,signal_rec_1) > 0
                [c_rec(i+1),r_rec(i+1)] = channol(signal_rec_1,0,0,sig);
                e_reci_1 = enorg(e_rec_1,signal_rec_1);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            else
                [c_rec(i+1),r_rec(i+1)] = channol(0,0,0,sig);
                scratchpad_rec_1 = new_scratchpad_rec_1;
                if ~isempty(new_bits_rec_1)
                    how_many_new_1 = length(new_bits_rec_1);
                    new_bits_1(1,how_many_1+1:how_many_1+how_many_new_1) = new_bits_rec_1;
                    how_many_1 = how_many_1 + how_many_new_1;
                end
            end
            if enorg(e_rec_2,signal_rec_2) > 0
                [c_rec(i+1),r_rec(i+1)] = channol(signal_rec_2,c_rec(i+1),0,sig);
                e_reci_2 = enorg(e_rec_2,signal_rec_2);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            else
                [c_rec(i+1),r_rec(i+1)] = channol(0,c_rec(i+1),0,sig);
                scratchpad_rec_2 = new_scratchpad_rec_2;
                if ~isempty(new_bits_rec_2)
                    how_many_new_2 = length(new_bits_rec_2);
                    new_bits_2(1,how_many_2+1:how_many_2+how_many_new_2) = new_bits_rec_2;
                    how_many_2 = how_many_2 + how_many_new_2;
                end
            end
        end
        if (mod(i+4999,10000) == 0 && i-4998 > 0) || (mod(i,10000) == 0 && i-4998 > 0)
            ti = t(i);
            errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
            scr_1(i) = msg_size - errors_1;
            errors_2 = dot(b_2-new_bits_2(1:msg_size),b_2-new_bits_2(1:msg_size));
            scr_2(i) = msg_size - errors_2;
            addpoints(h_1,ti,scr_1(i));
            addpoints(h_2,ti,scr_2(i));
            drawnow limitrate
            title(join([name_1,' ',name_2]))
            subplot(2,2,2)
            hold on
            plot(-1,e_tra_1,'r*')
            plot(-0.5,e_rec_1,'r*')
            plot(0.5,e_tra_2,'k*')
            plot(1,e_rec_2,'k*')
            hold off
            xlim([-1.5 1.5])
            ylim([0 initial_e_tra+1])
            title('energy Left')
            sub_5 = abs(fftshift(fft(c_tra(i-999:i))))/1000;
            subplot(2,2,3)
            plot(f,sub_5)
            title('Spectrum of Transmitters')
            
            sub_6 = abs(fftshift(fft(c_rec(i-999:i))))/1000;
            subplot(2,2,4)
            plot(f,sub_6)
            title('Spectrum of Receivers')
            axis([0 Fs/4-dF 0 0.5])
            clear global variable
        end
    end
    errors_1 = dot(b_1-new_bits_1(1:msg_size),b_1-new_bits_1(1:msg_size));
    scr_1 = [scr_1 msg_size - errors_1];
    errors_2 = dot(b_2-new_bits_2(1:msg_size),b_2-new_bits_2(1:msg_size));
    scr_2 = [scr_2 msg_size - errors_2];
else
    error('incorrect game mode')
end

e_rate = 1000;

s1 = max(scr_1);
s2 = max(scr_2);

if strcmp(game_mode,'test')
    result = s1-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_reci_1))/(initial_e_tra+initial_e_rec));
elseif strcmp(game_mode,'fight')
    result = s1-s2-e_rate*((e_tra_1+e_reci_1-e_tra_2-e_reci_2)/(initial_e_tra+initial_e_rec));
else
    result = min(s1,s2)-e_rate*(((initial_e_tra+initial_e_rec)-(e_tra_1+e_reci_1+e_tra_2+e_reci_2))/(initial_e_tra+initial_e_rec));
end

end

function [cle,dir] = channol(sig_1,sig_2,mu,sig)
cle = sig_1+sig_2;
dir = cle+normrnd(mu,sig);
end

function enorgy_left = enorg(e,sig)
enorgy_left = e - (sig^(2));
end