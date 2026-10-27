%CSS_TRADE_ADC Trade study: ADC resolution and averaging.
%   Left: electronics-only error (noise, quantization, offsets).
%   Right: all intrinsic errors (everything except albedo).
%   The knee of each curve is the resolution worth paying for.
clear; close all;

bits = 8:16;
navg = [1 4 16];
p0 = css_params();
p0.sim.nSamples = 3000;
p0.err.albedo   = false;
EG = css_earthgrid(p0);

pElec = p0;
fn = fieldnames(pElec.err);
for i = 1:numel(fn), pElec.err.(fn{i}) = false; end
pElec.err.noise = true; pElec.err.quant = true; pElec.err.offset = true;

eE = zeros(numel(navg), numel(bits));
eA = eE;
for a = 1:numel(navg)
    for b = 1:numel(bits)
        p = pElec; p.elec.adcBits = bits(b); p.elec.nAvg = navg(a);
        R = css_montecarlo(p, EG); eE(a,b) = R.stats.p997;
        p = p0;    p.elec.adcBits = bits(b); p.elec.nAvg = navg(a);
        R = css_montecarlo(p, EG); eA(a,b) = R.stats.p997;
    end
end

leg = arrayfun(@(n) sprintf('%d-sample average', n), navg, 'UniformOutput', false);
figure('Name','ADC trade','Position',[80 80 1000 420]);
subplot(1,2,1); semilogy(bits, eE', '-o'); grid on;
xlabel('ADC bits'); ylabel('99.7% error (deg)');
title('Electronics only'); legend(leg,'Location','northeast');
subplot(1,2,2); plot(bits, eA', '-o'); grid on;
xlabel('ADC bits'); ylabel('99.7% error (deg)');
title('All intrinsic errors (no albedo)'); legend(leg,'Location','northeast');

fprintf('\n99.7%% error (deg), electronics only\n bits: %s\n', sprintf('%7d', bits));
for a = 1:numel(navg), fprintf(' avg %2d %s\n', navg(a), sprintf('%7.3f', eE(a,:))); end
fprintf('99.7%% error (deg), all intrinsic\n');
for a = 1:numel(navg), fprintf(' avg %2d %s\n', navg(a), sprintf('%7.3f', eA(a,:))); end
