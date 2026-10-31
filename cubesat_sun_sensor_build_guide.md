# Building a Sun Sensor for a CubeSat

A step-by-step guide to designing, building, calibrating and integrating a quad-photodiode sun sensor with an aperture, plus a face-mounted coarse sensor set for full-sky coverage.

---

## Contents

1. Write down requirements
2. Optical and geometric design
3. Choose the detector
4. Electronics
5. Mechanical design
6. Onboard algorithm
7. Firmware
8. Ground software
9. Build, test and calibrate
10. Integrate on the satellite
11. Full-sky coarse sensors (face-mounted photodiodes)
12. Bill of materials
13. Appendix: Lab test and calibration plan

---

## 1. Write down requirements

Fix these numbers first, because every later choice depends on them:

- **Field of view (FOV):** ±45° to ±60° is typical for one head. Wider FOV means lower sensitivity.
- **Accuracy:** 0.5–2° is realistic for a well-calibrated design. Under 0.5° needs much more careful mechanics and calibration.
- **Update rate:** 1–10 Hz is enough for most CubeSat ADCS loops.
- **Size, mass, power:** often under 20 g and under 50 mW per head.
- **Interface:** analog voltages, I2C, SPI, RS-485 or CAN, depending on your onboard computer (OBC).
- **Environment:** orbit (usually LEO), mission lifetime, temperature range (often −30 to +70 °C at the sensor), and the vibration levels your launcher requires.

---

## 2. Optical and geometric design

### How it works

Sunlight passes through a square aperture of side *a*, held at height *h* above the detector, and makes a square light spot on the four quadrants (A, B, C, D). When the sun is at an angle α, the spot shifts by h·tan(α).

### Key equations

With quadrant currents A, B, C, D:

```
X = [(A + D) − (B + C)] / (A + B + C + D)
Y = [(A + B) − (C + D)] / (A + B + C + D)
```

For a square spot fully on the detector:

```
X = (2h / a) · tan(αx)
Y = (2h / a) · tan(αy)
```

The output is linear in tan(α) until the spot center reaches the edge of a quadrant, which sets the usable FOV:

- **FOV half-angle:** α_max = arctan(a / 2h)
- **Spot stays on the detector** if a ≤ D/2, where D is the full detector width.

### Worked example

Take a quad photodiode about 5 mm wide (D ≈ 4.8 mm active) and choose a = 2.4 mm.

| Target FOV | Aperture height h | Relative sensitivity |
|---|---|---|
| ±60° | 2.4 / (2·tan 60°) ≈ 0.69 mm | 1.0× |
| ±45° | 2.4 / (2·tan 45°) = 1.2 mm | ≈ 1.7× |

Check your detector's datasheet for the exact active area and the gap between quadrants.

### Practical notes

- **Aperture plate:** keep it thin (0.05–0.2 mm), etched or laser-cut stainless steel, with knife-edged or beveled edges. A thick plate vignettes the spot at large angles.
- **Window (optional but recommended):** fused silica or sapphire. Ordinary glass darkens from radiation. A window refracts light, so calibrate with the window installed.
- **Sun disk:** the sun's 0.53° angular size blurs the spot by only h × 0.0093, which is negligible at these heights.
- **Precision vs accuracy:** noise is rarely the limit. With good electronics, the noise-equivalent angle is around 0.01°. Accuracy is limited by geometry errors, calibration quality, temperature drift and albedo, so put your effort there.

---

## 3. Choose the detector

Look for a silicon quadrant PIN photodiode with:

- Low dark current
- A small gap between elements (about 0.1 mm)
- A ceramic or metal package if available

Hamamatsu (S5980 or S4349 family) and First Sensor/TE (QP-series) parts are common choices. Buy several from the same batch so the quadrant gains match well, and keep spares for calibration and tests.

---

## 4. Electronics

### Architecture options

| Option | Description | Pros | Cons |
|---|---|---|---|
| Analog head | Sensor contains only amplifiers; sends four voltages to the OBC's ADC | Simpler, fewer parts | Accuracy limited by OBC ADC; long analog wires pick up noise |
| Smart digital head | Sensor has its own ADC and microcontroller; sends a computed sun vector over a bus | Better accuracy, clean interface, calibrated as one unit | More design and firmware work |

The smart digital head is recommended for a flight sensor.

### Signal chain (per quadrant)

1. **Photodiode in photovoltaic mode** (zero bias). Lowest dark current; high speed is not needed.
2. **Transimpedance amplifier (TIA).** Quad op-amp with low input bias current and low offset (for example the OPA4140 class). Use 0.1% feedback resistors with low temperature coefficient, and add a feedback capacitor for stability and to set the bandwidth (a few hundred Hz is plenty).
3. **Gain sizing.** In orbit, full sun (about 1361 W/m²) on a 2.4 × 2.4 mm spot is about 7.8 mW. With silicon responsivity of about 0.3–0.4 A/W, that's 2–3 mA total, or roughly 0.5–0.8 mA per quadrant. A feedback resistor of about 1.5–2 kΩ gives roughly 1–1.5 V. Redo this calculation with your exact aperture and detector, and leave headroom so nothing saturates.
4. **Anti-alias filter** (simple RC) before the ADC.
5. **Simultaneous-sampling ADC**, for example a 4-channel 24-bit part like the ADS131M04. Sampling all four channels at the same instant prevents errors when the satellite is rotating.
6. **Temperature sensor** close to the detector (TMP117 or a thermistor), for temperature compensation.

### Rest of the board

- **Microcontroller:** low-power ARM part such as the STM32L4 family, with a watchdog and ideally flash with ECC.
- **Power:** LDO regulators from the bus (3.3 V), with a current limiter or latch-up protection on the supply, since radiation can cause latch-up in COTS chips.
- **Interface:** bus transceiver if you use RS-485 or CAN, and a locking connector (for example Harwin Gecko or Datamate).
- **Layout:** four-layer PCB with a solid ground plane, TIAs as close as possible to the photodiode, and guard traces around the high-impedance inputs.
- **Space practices:** no electrolytic capacitors, avoid pure-tin finishes (tin whiskers), use conformal coating, and only low-outgassing materials.

---

## 5. Mechanical design

- **Housing:** aluminum 6061, black anodized (or painted with a space-rated black coating) to suppress internal reflections.
- **Aperture alignment:** use dowel pins or precision locating features so the aperture is centered over the detector. A lateral offset becomes a constant angle bias, and an error in *h* becomes a scale-factor error. Calibration removes both, but only if they stay stable.
- **Baffle or sunshade:** a short black tube or fins above the aperture to block light from just outside the FOV.
- **Mounting reference surface:** a flat, machined face with mounting holes, so the sensor's orientation on the satellite can be measured precisely.
- **Adhesives:** low-outgassing epoxies only. Check the NASA outgassing database for total mass loss (TML) under 1% and collected volatile condensable material (CVCM) under 0.1%.
- **Venting:** small vent paths so trapped air doesn't stress the window during launch depressurization.

---

## 6. Onboard algorithm

Runs on the sensor's microcontroller, or on the OBC for an analog head.

```
every sample period:
    read A, B, C, D simultaneously (oversample and average N times)
    subtract dark offsets (from calibration table, temperature-dependent)
    multiply by per-quadrant gain corrections
    S = A + B + C + D
    valid = (S > sun_threshold) and (S < saturation_limit)
    X = ((A + D) - (B + C)) / S
    Y = ((A + B) - (C + D)) / S
    valid = valid and |X| < 0.95 and |Y| < 0.95
    (tan_ax, tan_ay) = calibration_map(X, Y, temperature)
    s_sensor = normalize([tan_ax, tan_ay, 1])
    s_body = R_mount * s_sensor
    output s_body, valid flag, S, temperature, timestamp
```

### Calibration map

The simple model is tan(α) = a·X / 2h. In practice, use either:

- a 2D polynomial in X and Y (third to fifth order) fitted from lab data, or
- a lookup table with bilinear interpolation.

Add a temperature correction term if thermal tests show drift.

### Validity checks

- The sum **S** is also the eclipse detector: if S is near zero, the satellite is in Earth's shadow.
- If S is far below the expected full-sun level, the light is probably albedo or a reflection, so flag the reading as suspect.

### How the ADCS uses it

The sensor only measures a direction. The ADCS combines it with a second reference vector, usually the magnetometer reading, using TRIAD, QUEST, or an extended Kalman filter. It also needs onboard sun and magnetic-field models (a sun ephemeris and IGRF) to get full attitude.

---

## 7. Firmware

- **Drivers:** ADC over SPI (interrupt on data-ready), temperature sensor, communication bus.
- **Processing:** the algorithm above, with oversampling and filtering.
- **Calibration storage:** coefficients stored in flash with a CRC check, plus a fallback default set if the CRC fails, since radiation can corrupt memory.
- **Command set:** get sun vector, get raw counts, get temperature, get health status, set mode, upload new calibration, reset.
- **Telemetry:** always include raw counts alongside the computed vector, so the sensor can be recalibrated from the ground if it degrades in orbit.
- **Robustness:** watchdog timer, packet CRCs, timeouts, and a safe default state on boot.

---

## 8. Ground software

| Tool | Purpose | Suggested libraries |
|---|---|---|
| Data acquisition | Command the test stage and log raw sensor data with true angles | pyserial, numpy, pandas |
| Calibration fitting | Least-squares fit of offsets, gains and 2D polynomial; validate on separate dataset | numpy, scipy |
| Error budget simulation | Monte Carlo over h, aperture offset, gain mismatch, noise and temperature tolerances | numpy |
| Sun position | Reference sun vector for outdoor tests | pvlib, Skyfield, astropy |
| Calibration export | Write fitted coefficients into the firmware's format | Python |

---

## 9. Build, test and calibrate

1. Breadboard the TIA and ADC with one quad photodiode and an improvised aperture. Confirm that X and Y respond as expected.
2. Run the Monte Carlo error budget with real component tolerances.
3. Build the first PCB and housing.
4. Calibrate and test using the lab plan in the Appendix: boresight reversal, axis sweeps, 2D grid accuracy, temperature, stray light and the outdoor drift scan.
5. Run vibration testing and repeat the boresight check before and after.
6. Run thermal cycling or thermal vacuum testing if the mission requires it.

---

## 10. Integrate on the satellite

- **Mounting orientation:** measure each head's orientation on the satellite after integration (laser and mirror, or a coordinate measuring machine). That rotation matrix (R_mount) goes into the algorithm; any error in it is a direct pointing error.
- **Placement:** keep the FOV clear of antennas, deployable panels and shiny surfaces that could reflect sunlight into the sensor.
- **Coverage:** a single ±60° head sees only part of the sky, so CubeSats usually carry several heads on different faces, or add cosine sensors (Section 11).
- **End-to-end test:** shine a lamp on the assembled satellite from known directions and check that the ADCS reports the right sun vector.

---

## 11. Full-sky coarse sensors (face-mounted photodiodes)

For detumbling and safe mode, many CubeSats put one simple photodiode on each of the six faces.

- Each photodiode's current follows roughly I = k·cos(θ).
- The sun vector comes from opposing face pairs:

```
s ≈ normalize([ I(+X) − I(−X),  I(+Y) − I(−Y),  I(+Z) − I(−Z) ])
```

- For a general geometry with N cells of normal vectors nᵢ, model each lit cell as Iᵢ = kᵢ (nᵢ · s) + bᵢ, stack the normals into a matrix N, and solve s = (NᵀN)⁻¹ Nᵀ I, then normalize. Use only cells above a brightness threshold.
- Accuracy is about 5–10°, mostly limited by albedo.
- Hardware is one photodiode and one TIA channel per face.

This makes a cheap and robust backup to the quad sensor.

---

## 12. Bill of materials (per quad head)

| Category | Item |
|---|---|
| Detector | Silicon quadrant PIN photodiode (plus spares from the same batch) |
| Optics | Etched or laser-cut thin aperture plate; fused silica or sapphire window (optional) |
| Analog | Quad low-bias op-amp, 0.1% low-tempco resistors, C0G capacitors |
| Digital | 4-channel simultaneous-sampling ADC, low-power microcontroller, temperature sensor |
| Power and interface | LDO regulator, current limiter, bus transceiver, locking connector |
| Mechanical | Black-anodized aluminum housing, dowel pins, baffle, low-outgassing epoxy, conformal coating |
| Test equipment | Collimator, rotation stages with encoders, laser-and-mirror reference, Peltier thermal setup (see Appendix) |
| Software | Firmware (C, usually with the vendor's HAL); Python tools for logging, calibration fitting, Monte Carlo and sun ephemeris |

---

## 13. Appendix: Lab test and calibration plan

### Lab setup

**Collimated light source.** Place a pinhole at the focal point of a lens to get a collimated beam. The beam's angular size equals pinhole diameter divided by lens focal length. A 1.9 mm pinhole with a 200 mm lens gives about 0.53°, matching the sun. Use a bright white LED or halogen lamp behind the pinhole. Make the beam wider than the sensor housing, and scan it with a single photodiode to confirm it's uniform.

**Angle reference.** The reference should be about 5–10× more accurate than the sensor. For a 1° target, that means roughly 0.1–0.2°.

**Stray-light control.** Dark room, black flocked paper around the setup, and cover the stage and cables.

### Test equipment

| Item | Budget option | Notes |
|---|---|---|
| Rotation stages | Two manual rotation stages with vernier (often cheap secondhand), or stepper motors with 14-bit magnetic encoders (e.g. AS5048A, ~0.02°) | Mount the encoder on the output shaft to avoid gear backlash errors |
| Absolute angle check | Small mirror on the sensor, laser pointer, spot on a wall 3–5 m away | The spot moves 2θ; 1 mm on a 5 m wall ≈ 0.006° |
| Collimator | Plano-convex lens (150–300 mm focal length), pinholes of a few sizes, LED or halogen | Cheapest critical item; build carefully |
| Readout | Four matched TIAs with a simultaneous-sampling ADC and a microcontroller | Needed for the dynamic test |
| Irradiance reference | A second plain photodiode as a relative monitor | Corrects for lamp drift during long sweeps |
| Temperature | Peltier module, thermistor, insulated box | Watch for condensation below ambient |
| Outdoor test | Rigid tripod, inclinometer, GPS time, pvlib script | Nearly free |

### Experiments

1. **Boresight offset with reversal test.** At normal incidence, record X and Y. Rotate the sensor 180° about its boresight and measure again. Sensor offset flips sign; fixture misalignment does not. Averaging and differencing separates the two.
2. **Single-axis transfer function.** Sweep each axis edge to edge in 0.5–1° steps with the other axis at zero. Plot X against tan(α); fit a polynomial or lookup table.
3. **Two-axis grid accuracy.** Step through a full 2D grid of angles. Fit the 2D model on half the points and validate on the other half. Report RMS error, maximum error, and an error map over the FOV.
4. **FOV edge and validity threshold.** Find where the spot clips the detector edge and where the sum signal becomes unusable. Define the validity flag.
5. **Noise-equivalent angle and repeatability.** Log thousands of samples at a fixed angle; the standard deviation converted to degrees is the noise-equivalent angle. Return to the same angle from different directions to check stage backlash.
6. **Intensity independence.** Vary irradiance by at least 5–10× (distance, ND filters, LED current). X and Y should not change; if they do, check offsets, dark current and saturation.
7. **Source size sensitivity.** Repeat with pinholes of different sizes. If calibration shifts, calibrate with a source matching the sun's 0.53°.
8. **Temperature.** Repeat a reduced sweep at several temperatures across the expected range. Look for offset drift (dark current, quadrant gains) and scale drift (thermal expansion of h).
9. **Stray light, glint and albedo.** Place a bright source just outside the FOV to check for leakage. Add a dim diffuse source (~30% intensity) inside the FOV to imitate Earth albedo and measure the error.
10. **Dynamic response.** Rotate at a known rate (1–5°/s) and check the output keeps up at the ADCS sample rate.
11. **Outdoor sun drift scan.** Fix the sensor rigidly pointed near where the sun will be and let the sun drift through the FOV (~15° per hour). Log with GPS time and compare to the computed sun position (pvlib, Skyfield or astropy). Use a clear day around midday.
12. **Environmental checks.** Repeat the boresight test before and after vibration. Verify low-outgassing materials; plan vacuum and radiation tests if the mission requires them.

### Recommended order

Start with the collimator check and experiment 1, since every later result depends on a good zero. Then run 2, 3 and 5 for calibration and accuracy, followed by 6, 7 and 9 to find error sources. Run 8 and 10 once the design is fixed, use 11 as an independent check against the real sun, and leave 12 for the flight-candidate unit.
