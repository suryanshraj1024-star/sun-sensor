%CSS_TRADE_BETA Trade study: face tilt beta and number of diodes.
%   For each configuration it reports
%     - usable FOV: largest Sun angle where >=99% of samples give a solution
%     - availability and 99.7% error for the Sun within evalCone of boresight
%   Albedo is OFF by default to isolate the intrinsic design; set
%   includeAlbedo = true to see how geometry changes albedo sensitivity (slower).
clear; close all;

includeAlbedo = false;
evalCone      = 50;          % deg
betas         = 10:5:70;     % deg
cfg = struct('nFaces', {3, 4, 6, 3, 4, 6}, 'top', {false, false, false, true, true, true});

p0 = css_params();
p0.sim.nSamples = 2000;
p0.err.albedo   = includeAlbedo;
EG = css_earthgrid(p0);

nC = numel(cfg); nB = numel(betas);
usable = zeros(nC,nB); avail = zeros(nC,nB); e997 = zeros(nC,nB); erms = zeros(nC,nB);
names = cell(1,nC);
for c = 1:nC
    names{c} = sprintf('%d faces%s', cfg(c).nFaces, ternary(cfg(c).top,' + top',''));
    for b = 1:nB
        p = p0;
        p.geom.nFaces   = cfg(c).nFaces;
        p.geom.topDiode = cfg(c).top;
        p.geom.beta_deg = betas(b);

        p.sim.fovHalf_deg = 90;                 % whole hemisphere for coverage
        R = css_montecarlo(p, EG);
        usable(c,b) = css_usable_fov(R, 0.99, 5);

        p.sim.fovHalf_deg = evalCone;           % accuracy inside the evaluation cone
        R = css_montecarlo(p, EG);
        avail(c,b) = R.availability;
        e997(c,b)  = R.stats.p997;
        erms(c,b)  = R.stats.rms;
    end
    fprintf('%-14s done\n', names{c});
end

figure('Name','Beta / diode-count trade','Position',[60 60 1250 420]);
subplot(1,3,1); plot(betas, usable', '-o'); grid on;
xlabel('\beta (deg)'); ylabel('Usable FOV half-angle (deg)');
title('Coverage (\geq99% availability)'); legend(names,'Location','best');
subplot(1,3,2); plot(betas, 100*avail', '-o'); grid on;
xlabel('\beta (deg)'); ylabel('Availability (%)');
title(sprintf('Availability, Sun within %g deg', evalCone));
subplot(1,3,3); plot(betas, e997', '-o'); grid on;
xlabel('\beta (deg)'); ylabel('99.7% error (deg)');
title(sprintf('Accuracy, Sun within %g deg', evalCone));

% Best configuration that reaches full availability in the evaluation cone
ok = avail >= 0.999;
e  = e997; e(~ok) = Inf;
[m, idx] = min(e(:));
if isfinite(m)
    [ci, bi] = ind2sub(size(e), idx);
    fprintf('\nBest with >=99.9%% availability within %g deg: %s, beta = %g deg, 99.7%% error = %.2f deg, usable FOV = %g deg\n', ...
        evalCone, names{ci}, betas(bi), m, usable(ci,bi));
else
    fprintf('\nNo configuration reached 99.9%% availability within %g deg.\n', evalCone);
end
