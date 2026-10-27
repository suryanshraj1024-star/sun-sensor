function p = css_params()
%CSS_PARAMS Default parameters for the coarse sun sensor (CSS) simulation.
%   p = css_params() returns a struct with every model parameter.
%   All units are SI unless the field name says otherwise (_deg, C, ...).
%   Values marked (!) are placeholders: replace them with your datasheet
%   numbers and test results.

% ---------------- Geometry ----------------
p.geom.type         = 'pyramid'; % 'pyramid' (single unit) or 'cube' (6 body-mounted diodes)
p.geom.beta_deg     = 45;        % tilt of each face from the boresight (+Z)
p.geom.nFaces       = 4;         % number of tilted faces, equally spaced in azimuth
p.geom.topDiode     = false;     % extra diode looking along the boresight
p.geom.mountErr_deg = 0.5;       % 1-sigma as-built error of each diode normal

% ---------------- Environment ----------------
p.env.Esun     = 1361;     % W/m^2, solar irradiance at 1 AU (AM0)
p.env.EsunVar  = 0.034;    % +/- fractional annual variation (perihelion/aphelion)
p.env.albedo   = 0.30;     % Earth mean albedo (try 0.5-0.8 for cloud/ice worst case)
p.env.altitude = 500e3;    % m, orbit altitude
p.env.Re       = 6371e3;   % m, Earth radius
p.env.mu       = 3.986004418e14; % m^3/s^2

% ---------------- Photodiode ----------------
p.diode.area         = 7.5e-6; % m^2 (BPW34-class silicon PIN)            (!)
p.diode.resp         = 0.35;   % A/W, responsivity averaged over AM0 band  (!)
p.diode.gainMismatch = 0.03;   % 1-sigma diode-to-diode responsivity spread (as built)
p.diode.nGlass       = 1.46;   % refractive index of window / cover glass
p.diode.cutoff_deg   = 88;     % package shadows the die beyond this angle (!)
p.diode.Idark25      = 1e-9;   % A, dark current at 25 C (doubles every 10 C)
p.diode.tempcoResp   = 0.001;  % 1/K, responsivity temperature coefficient (!)

% ---------------- Thermal ----------------
p.therm.Tmean         = 20;  % C, mean sensor temperature
p.therm.Trange        = 40;  % C, sensor temperature drawn uniformly in Tmean +/- Trange
p.therm.gradient      = 2;   % C, 1-sigma diode-to-diode temperature difference
p.therm.Tsensor_noise = 1;   % C, 1-sigma error of the board temperature sensor

% ---------------- Electronics (TIA + ADC) ----------------
p.elec.bandwidth  = 50;     % Hz, TIA / anti-alias bandwidth
p.elec.Vfs        = 3.3;    % V, ADC full scale
p.elec.margin     = 1.3;    % headroom over max direct-sun current (sizes Rf)
p.elec.Vos        = 50e-6;  % V, 1-sigma op-amp offset per channel
p.elec.en         = 20e-9;  % V/sqrt(Hz), op-amp voltage noise density
p.elec.adcBits    = 12;
p.elec.adcINL_lsb = 1;      % 1-sigma ADC nonlinearity, in LSB
p.elec.nAvg       = 4;      % ADC samples averaged per measurement

% ---------------- Calibration (what the estimator knows) ----------------
p.cal.calibrated      = true;  % gains/normals known to the residuals below
p.cal.normalResid_deg = 0.1;   % 1-sigma residual normal error after calibration
p.cal.gainResid       = 0.003; % 1-sigma residual gain error after calibration
p.cal.fresnelCorr     = true;  % estimator corrects the non-cosine response
p.cal.darkCorr        = true;  % estimator subtracts offsets and modeled dark current
p.cal.tempCorr        = true;  % estimator compensates responsivity with measured T

% ---------------- Estimator ----------------
p.est.litThresh = 0.02;  % a diode is "lit" above this fraction of max current
p.est.minLit    = 3;     % minimum lit diodes for a 3-D solution
p.est.nIter     = 15;    % max Gauss-Newton iterations (non-cosine correction)

% ---------------- Monte Carlo ----------------
p.sim.nSamples    = 5000;
p.sim.fovHalf_deg = 60;   % Sun drawn uniformly within this cone around boresight
p.sim.seed        = 1;

% ---------------- Error-source switches (used for the error budget) ----------
p.err.noise     = true;  % shot, Johnson and op-amp noise
p.err.quant     = true;  % ADC quantization, nonlinearity and clipping
p.err.albedo    = true;  % Earth-reflected sunlight
p.err.temp      = true;  % temperature effects on responsivity
p.err.mismatch  = true;  % as-built gain and alignment errors
p.err.nonCosine = true;  % Fresnel losses and package cutoff
p.err.offset    = true;  % op-amp offsets and dark current
p.err.sunVar    = true;  % annual solar flux variation
end
