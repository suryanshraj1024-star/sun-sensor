%CSS_ERROR_BUDGET Error budget for the baseline design in css_params.m.
%   Runs the Monte Carlo with each error source alone, a few "what if not
%   calibrated" cases, and the combined case with and without albedo.
%   Prints a table and plots the contributions and error vs. Sun angle.
clear; close all;

p0 = css_params();
EG = css_earthgrid(p0);
src = {'noise','quant','albedo','temp','mismatch','nonCosine','offset','sunVar'};
lbl = {'Electronic noise','ADC quantization + INL','Earth albedo', ...
       'Temperature (compensated)','Gain/alignment (calibrated)', ...
       'Non-cosine (corrected)','Offsets + dark current','Solar flux variation'};

pNone = p0;
for i = 1:numel(src), pNone.err.(src{i}) = false; end

cases = {};   % {label, params, includeInRSS}
for i = 1:numel(src)
    p = pNone; p.err.(src{i}) = true;
    cases(end+1,:) = {lbl{i}, p, true}; %#ok<SAGROW>
end
p = pNone; p.err.mismatch = true; p.cal.calibrated = false;
cases(end+1,:) = {'Gain/alignment (NOT calibrated)', p, false};
p = pNone; p.err.nonCosine = true; p.cal.fresnelCorr = false;
cases(end+1,:) = {'Non-cosine (NOT corrected)', p, false};
p = pNone; p.err.temp = true; p.cal.tempCorr = false;
cases(end+1,:) = {'Temperature (NOT compensated)', p, false};
p = p0; p.err.albedo = false;
cases(end+1,:) = {'ALL except albedo', p, false};
cases(end+1,:) = {'ALL sources', p0, false};

nC  = size(cases,1);
tab = zeros(nC,4);   % rms, p95, p997, availability
res = cell(nC,1);
fprintf('\nCSS error budget: beta = %g deg, %d faces%s, %d-bit ADC, Sun within %g deg of boresight, %d samples\n', ...
    p0.geom.beta_deg, p0.geom.nFaces, ternary(p0.geom.topDiode,' + top',''), ...
    p0.elec.adcBits, p0.sim.fovHalf_deg, p0.sim.nSamples);
fprintf('%-34s %8s %8s %8s %8s\n','Error source (deg)','RMS','95%','99.7%','Avail');
for c = 1:nC
    R = css_montecarlo(cases{c,2}, EG);
    res{c} = R;
    tab(c,:) = [R.stats.rms R.stats.p95 R.stats.p997 R.availability];
    fprintf('%-34s %7.3f  %7.3f  %7.3f  %7.1f%%\n', cases{c,1}, tab(c,1:3), 100*tab(c,4));
end
inRSS = [cases{:,3}];
noAlb = inRSS & ~strcmp(cases(:,1)', lbl{3});
fprintf('%-34s %8s %8s %7.3f\n','RSS of individual 99.7% (all)','','',sqrt(sum(tab(inRSS,3).^2)));
fprintf('%-34s %8s %8s %7.3f\n','RSS of individual 99.7% (no albedo)','','',sqrt(sum(tab(noAlb,3).^2)));
fprintf(['Note: the combined Monte Carlo is the real answer; RSS assumes independent,\n' ...
         'Gaussian-like errors and is only a cross-check.\n\n']);

% ---------- Plots ----------
figure('Name','CSS error budget','Position',[80 80 1100 450]);
subplot(1,2,1);
k = 1:numel(src);
barh(tab(k,3));
set(gca,'YTick',k,'YTickLabel',lbl,'YDir','reverse');
xlabel('99.7th percentile error (deg)');
title('Contribution of each error source (alone)');
grid on;

subplot(1,2,2);
Ra = res{nC}; Rn = res{nC-1};
plot(Ra.off(Ra.valid), Ra.err(Ra.valid), '.', 'MarkerSize', 4); hold on;
plot(Rn.off(Rn.valid), Rn.err(Rn.valid), '.', 'MarkerSize', 4);
xlabel('Sun angle from boresight (deg)'); ylabel('Angular error (deg)');
legend('All sources','All except albedo','Location','northwest');
title('Error vs Sun angle'); grid on;
