function carriers=modulation_scheme(t, i, all)
%%%
% t: the time at which we should calculate our modulated signal
% i: the index of our modulation scheme
% all: boolean, if true, return a list with ALL carrier signals at time t
%   (only needed for receiver for code simplicity)
% returns: a single carrier wave sample if argument all is 0; a list of carrier
% sampels with each entry index correspond to carrier index i if all is 1
% NOTE: returned carrier MUST be normalized to have unit energy
%%%
carriers = [];
if i==1 || all
    carriers = [carriers; ones(size(t))];
end
if i==2 || all
    carriers = [carriers; -ones(size(t))];
end
if ~all
    carriers = carriers(1);
end
end
