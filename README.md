# Coarse Sun Sensor (CSS) simulation – MATLAB

Put all files in one folder, `cd` there in MATLAB, and run `run_all` (or any script on its own).
Tested in GNU Octave 8.4; uses only base MATLAB functions (no toolboxes, R2016b or newer).

## Scripts (what you run)
| File | Purpose |
|---|---|
| `css_error_budget.m` | Each error source alone + combined Monte Carlo → error budget table and plots |
| `css_trade_beta.m` | Sweep face tilt β and diode count → usable FOV, availability, accuracy |
| `css_trade_adc.m` | Sweep ADC bits and averaging → where resolution stops mattering |
| `css_orbit_sim.m` | One flight unit over a LEO orbit (nadir pointing) → albedo and eclipse effects vs time |
| `run_all.m` | Runs all four |

## Model (functions)
| File | Purpose |
|---|---|
| `css_params.m` | **All parameters** – edit this first (diode area/responsivity, tempco, ADC, calibration residuals, albedo…) |
| `css_geometry.m` | Diode normals: pyramid (β, n faces, optional top diode) or 6-face cube |
| `css_build_sensor.m` | One as-built unit: manufacturing errors, calibration knowledge, feedback resistor sizing |
| `css_angular.m` | Angular response: cosine × Fresnel window transmission, package cutoff |
| `css_measure.m` | Currents → TIA → noise → ADC (quantization, INL, clipping, averaging) |
| `css_estimate.m` | Corrections, lit-diode selection, least squares, Gauss-Newton non-cosine refinement |
| `css_albedo.m`, `css_earthgrid.m` | Earth albedo on each diode (Lambertian sphere, fine grid under the satellite) |
| `css_montecarlo.m` | Monte Carlo driver |
| others | Small helpers (frames, statistics, seeding, temperatures) |

## Error-source switches
`p.err.noise, quant, albedo, temp, mismatch, nonCosine, offset, sunVar` turn each effect on/off.
`p.cal.*` sets what the estimator knows after calibration (turn `calibrated`, `fresnelCorr`, `tempCorr` off to see why calibration matters).

## Replace placeholders with real data
Diode responsivity and area, tempco, the angular response (swap `css_angular` for your measured curve
from the testbed), op-amp offset/noise, calibration residuals (from your accuracy-verification test),
temperature range (from thermal analysis), and orbit altitude.
