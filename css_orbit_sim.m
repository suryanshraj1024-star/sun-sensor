%CSS_ORBIT_SIM Time simulation of one flight unit over a circular LEO orbit.
%   Nadir-pointing spacecraft (body x = velocity, z = nadir). Choose where
%   the sensor boresight points in the body frame. Shows the Sun angle,
%   eclipse, albedo level, and the error with and without albedo, so you
%   can see when albedo corrupts the measurement.
clear; close all;

p  = css_params();
EG = css_earthgrid(p);
css_seed(p.sim.seed);

boresightBody = [0; 0; -1];   % [0;0;-1] = zenith-facing; try [1;0;0] (ram) or [0;1;0]
betaSun_deg   = 30;           % solar beta angle (Sun elevation above orbit plane)
nOrbits       = 2;
nPts          = 600;

S     = css_build_sensor(p);           % one as-built unit
R_s2b = css_frame(boresightBody);      % sensor +Z -> body boresight
a     = p.env.Re + p.env.altitude;
Tper  = 2*pi*sqrt(a^3/p.env.mu);
bs    = betaSun_deg*pi/180;
sI    = [cos(bs); 0; sin(bs)];         % orbit lies in the inertial XY plane
u     = linspace(0, 2*pi*nOrbits, nPts);
tmin  = u/(2*pi)*Tper/60;

sunAng = nan(1,nPts); eAlb = nan(1,nPts); eNo = nan(1,nPts);
albMax = zeros(1,nPts); ecl = false(1,nPts);
for k = 1:nPts
    r  = a*[cos(u(k)); sin(u(k)); 0];
    zb = -r/norm(r);                         % nadir
    xb = [-sin(u(k)); cos(u(k)); 0];         % velocity
    yb = cross(zb, xb);
    R_s2i = [xb yb zb]*R_s2b;
    sS = R_s2i'*sI;
    sunAng(k) = acos(sS(3))*180/pi;

    along  = r'*sI;
    ecl(k) = along < 0 && norm(r - along*sI) < p.env.Re;
    Esun   = p.env.Esun*~ecl(k);

    Ealb = css_albedo(r, sI, (R_s2i*S.Ntrue')', p.env.Esun, p, EG);
    albMax(k) = max(Ealb)/p.env.Esun;

    Tbase = p.therm.Tmean + p.therm.Trange*sin(u(k));   % crude orbital thermal cycle
    [Td, Tmeas] = css_temps(S.nD, p, Tbase);

    V = css_measure(S, sS, Ealb, Td, Esun, p);
    [s, ok] = css_estimate(V, S, Tmeas, p);
    if ok && ~ecl(k), eAlb(k) = acos(min(1, max(-1, s'*sS)))*180/pi; end

    V = css_measure(S, sS, zeros(S.nD,1), Td, Esun, p);
    [s, ok] = css_estimate(V, S, Tmeas, p);
    if ok && ~ecl(k), eNo(k) = acos(min(1, max(-1, s'*sS)))*180/pi; end
end

figure('Name','CSS over orbit','Position',[80 60 900 700]);
subplot(3,1,1);
plot(tmin, sunAng); hold on;
plot(tmin(ecl), 0*tmin(ecl) + 5, 'k.', 'MarkerSize', 6);
ylabel('Sun from boresight (deg)'); grid on;
legend('Sun angle','Eclipse','Location','best');
title(sprintf('Boresight [%g %g %g] in body, beta_{sun} = %g deg', boresightBody, betaSun_deg));
subplot(3,1,2);
plot(tmin, 100*albMax); ylabel('Max albedo on a diode (% of 1 sun)'); grid on;
subplot(3,1,3);
plot(tmin, eAlb, tmin, eNo); grid on;
xlabel('Time (min)'); ylabel('Error (deg)');
legend('With albedo','Without albedo','Location','best');

fprintf('Orbit period %.1f min. Valid solutions in sunlight: %.0f%%\n', Tper/60, ...
    100*mean(isfinite(eAlb(~ecl))));
st = css_stats(eAlb(isfinite(eAlb)));
fprintf('With albedo:    RMS %.2f deg, 99.7%% %.2f deg, max %.2f deg\n', st.rms, st.p997, st.max);
st = css_stats(eNo(isfinite(eNo)));
fprintf('Without albedo: RMS %.2f deg, 99.7%% %.2f deg, max %.2f deg\n', st.rms, st.p997, st.max);
