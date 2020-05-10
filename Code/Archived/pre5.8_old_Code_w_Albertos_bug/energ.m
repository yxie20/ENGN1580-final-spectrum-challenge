% Alberto Trovamala
% ENGN 1580: Channel

% This function simply sums two signals and gaussian noise

function energy_left = energ(e,sig)
energy_left = e - (sig^(2));
end