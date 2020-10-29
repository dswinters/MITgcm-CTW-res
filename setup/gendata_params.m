function params = gendata_params()

% simulation parameters
params.f = 1e-4; % coriolis parameter
params.deltaT = 500; % timestep
params.n_periods = 12;
params.dx = 2.5e3;
params.dy = 2.5e3;

% wavenumber and forcing frequency
params.k = [];
params.om = [];

% pressure forcing parameters
params.p0 = 5; % Pressure forcing amplitude, N/m^2
params.p_yc = 0; % Pressure forcing offshore center, m
params.p_yl = 50e3; % Pressure forcing offshore length scale, m
