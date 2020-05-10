% Alberto Trovamala
% ENGN 1580: Channel

% This function simply sums two signals and gaussian noise

function sig = channel(sig_1,sig_2,mu,sig)
sig = sig_1+sig_2+normrnd(mu,sig);
end