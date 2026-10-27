function [s, ok] = css_estimate(V, S, Tmeas, p)
%CSS_ESTIMATE Sun vector (sensor frame) from channel voltages.
%   Steps: offset/dark subtraction, gain and temperature correction,
%   lit-diode selection, least squares s = (N'N)^-1 N' I, normalization,
%   then (optionally) Gauss-Newton refinement with the non-cosine model.
s  = [NaN; NaN; NaN];
ok = false;

I = (V - S.VosKnown)/S.Rf;
if p.cal.darkCorr && p.err.offset
    I = I - p.diode.Idark25*2.^((Tmeas - 25)/10);
end
I = I./S.gKnown;
if p.cal.tempCorr && p.err.temp
    I = I./(1 + p.diode.tempcoResp*(Tmeas - 25));
end

lit = I > p.est.litThresh*S.Imax;
if nnz(lit) < p.est.minLit, return; end
N = S.Nknown(lit,:);
y = I(lit);
if rcond(N'*N) < 1e-6, return; end          % lit diodes nearly coplanar

s = N\y;                                     % linear least squares (ideal cosine)
if p.cal.fresnelCorr && p.err.nonCosine
    % Refine with Gauss-Newton on v = I0*s using the full angular model:
    % y_i = |v| * f(n_i . v/|v|)
    v = s;
    for it = 1:p.est.nIter
        r = y - css_model(N, v, p);
        J = zeros(numel(y), 3);
        h = 1e-6*norm(v);
        for j = 1:3
            dv = zeros(3,1); dv(j) = h;
            J(:,j) = (css_model(N, v + dv, p) - css_model(N, v - dv, p))/(2*h);
        end
        H = J'*J;
        H = H + 1e-6*trace(H)/3*eye(3);       % light Levenberg-Marquardt damping
        if rcond(H) < 1e-12, break; end
        step = H\(J'*r);
        v = v + step;
        if norm(step) < 1e-9*norm(v), break; end
    end
    s = v;
end
s = s/norm(s);
ok = all(isfinite(s));
end

function m = css_model(N, v, p)
% Predicted (gain-normalized) currents for unnormalized Sun vector v.
nv = norm(v);
m  = nv*css_angular(N*v/nv, p, true, false);   % smooth model, no cutoff
end
