function carriers=modulation_scheme(t, i, all, cnst)
%%%
% t: the time at which we should calculate our modulated signal
% i: the index of our modulation scheme (index of codeword)
% all: boolean, if true, return a list with ALL carrier signals at time t
%   (only needed for receiver for code simplicity)
% returns: a single carrier wave sample if argument all is 0; a list of carrier
% sampels with each entry index correspond to carrier index i if all is 1
% NOTE: returned carrier MUST be normalized to have unit energy
% NOTE: Even though we have 16 signal points here, it's okay if some of
%  them are not used.%%%
carriers = [];
if ((i==0) || (all && (2^cnst.src_code_len > 0)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*100*t)];
end
if ((i==1) || (all && (2^cnst.src_code_len > 1)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*100*t)];
end
if ((i==2) || (all && (2^cnst.src_code_len > 2)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*2000*t)];
end
if ((i==3) || (all && (2^cnst.src_code_len > 3)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*2000*t)];
end
if ((i==4) || (all && (2^cnst.src_code_len > 4)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*750*t)];
end
if ((i==5) || (all && (2^cnst.src_code_len > 5)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*750*t)];
end
if ((i==6) || (all && (2^cnst.src_code_len > 6)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*1400*t)];
end
if ((i==7) || (all && (2^cnst.src_code_len > 7)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*1400*t)];
end

if ((i==8) || (all && (2^cnst.src_code_len > 8)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*425*t)];
end
if ((i==9) || (all && (2^cnst.src_code_len > 9)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*425*t)];
end
if ((i==10) || (all && (2^cnst.src_code_len > 10)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*1000*t)];
end
if ((i==11) || (all && (2^cnst.src_code_len > 11)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*1000*t)];
end
if ((i==12) || (all && (2^cnst.src_code_len > 12)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*1700*t)];
end
if ((i==13) || (all && (2^cnst.src_code_len > 13)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*1700*t)];
end
if ((i==14) || (all && (2^cnst.src_code_len > 14)))
    carriers = [carriers; sqrt(2)*cos(2*pi()*2300*t)];
end
if ((i==15) || (all && (2^cnst.src_code_len > 15)))
    carriers = [carriers; sqrt(2)*sin(2*pi()*2300*t)];
end

if ~all
    carriers = carriers(1);
end
end
