function V = css_measure(S, sS, Ealb, Td, Esun, p)
%CSS_MEASURE Simulate the averaged ADC reading (volts) of each channel.
%   sS: true Sun unit vector in the sensor frame (zero vector in eclipse
%   is handled by passing Esun = 0). Ealb: albedo irradiance per diode.
q  = 1.602176634e-19;
kB = 1.380649e-23;

g    = S.gTrue.*(1 + p.diode.tempcoResp*(Td - 25));
Edir = Esun*css_angular(S.Ntrue*sS, p, p.err.nonCosine);
I    = p.diode.resp*p.diode.area*g.*(Edir + Ealb);
if p.err.offset
    I = I + p.diode.Idark25*2.^((Td - 25)/10);
end
Vclean = I*S.Rf + S.Vos;

B = p.elec.bandwidth;
if p.err.noise
    sigI = sqrt(2*q*abs(I)*B + 4*kB*(Td + 273.15)*B/S.Rf);   % shot + Johnson
    sigV = sqrt((sigI*S.Rf).^2 + p.elec.en^2*B);             % + op-amp voltage noise
else
    sigV = zeros(S.nD,1);
end

nA  = p.elec.nAvg;
lsb = p.elec.Vfs/2^p.elec.adcBits;
Vs  = repmat(Vclean,1,nA) + repmat(sigV,1,nA).*randn(S.nD,nA);
if p.err.quant
    % INL modeled as a random code error (a simplification of a static INL curve)
    codes = round(Vs/lsb + p.elec.adcINL_lsb*randn(S.nD,nA));
    codes = min(max(codes, 0), 2^p.elec.adcBits - 1);   % single-supply clipping
    Vs    = codes*lsb;
else
    Vs = min(max(Vs, 0), p.elec.Vfs);
end
V = mean(Vs, 2);
end
