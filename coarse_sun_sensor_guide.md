# Building a Coarse Sun Sensor (CSS)

Building a coarse sun sensor comes down to five decisions: the geometry (how many photodiodes, pointing where), the detectors, the readout electronics, the mechanical housing, and the algorithm that turns currents into a Sun vector. Below is how to make each one, followed by a practical build sequence.

## 1. Choose the Architecture

Everything relies on the cosine law. A flat photodetector facing direction **n** produces a current

\[
I = I_0 \max(0, \mathbf{n}\cdot\mathbf{s})
\]

where \(I_0\) is the current at normal incidence and \(\mathbf{s}\) is the unit Sun vector. Combine several detectors facing different directions and you can solve for \(\mathbf{s}\).

There are three common layouts:

| Architecture | How it works | Typical accuracy / FOV | Notes |
|---|---|---|---|
| Distributed cosine sensors | One photodiode on each of the 6 spacecraft faces (or reuse the solar-panel currents) | About 5–10°, full sphere | Simplest and cheapest; very sensitive to albedo and panel reflections |
| Pyramid or tilted-face unit | 4 photodiodes on the faces of a pyramid tilted at angle \(\beta\) from the boresight, often plus one on top | About 1–3°, roughly hemispherical | Self-contained single unit; the most common “real” CSS |
| Quadrant photodiode with aperture mask | Light through a small square window falls on a quad cell; the spot position gives the angle | About 0.5–1°, ±50–60° | Better accuracy, smaller FOV; moving toward a fine sensor |

For a LEO satellite, a good default is one pyramid unit per side that needs coverage, often two to six units for full-sphere coverage. Many CubeSats add the six-face solar-panel method as a free backup.

### Pyramid Geometry

Take two opposite faces tilted at \(\pm\beta\), with normals

\[
\mathbf{n}_1 = (\sin\beta, 0, \cos\beta), \qquad
\mathbf{n}_3 = (-\sin\beta, 0, \cos\beta).
\]

The cosine law gives

\[
\frac{I_1-I_3}{I_1+I_3} = \tan\beta\,\frac{s_x}{s_z}
\]

so the angle about that axis is

\[
\tan\alpha_x =
\frac{I_1-I_3}{(I_1+I_3)\tan\beta}.
\]

The other pair gives \(\alpha_y\) in the same way. Because these are ratios, the solar intensity \(I_0\) cancels out. That matters because solar flux changes by about ±3.3% over the year, and lamp intensity on Earth will drift.

### Choosing \(\beta\)

- A larger tilt (around 45–60°) gives more sensitivity per degree and a wider combined FOV.
- A smaller tilt (around 20–30°) keeps all faces lit over a larger cone around the boresight, which is where the formula is valid.
- Around 30–45° is the usual compromise.

## 2. Select the Photodetectors

Silicon PIN photodiodes are the standard choice. Look for these properties:

- **Flat, wide-angle package.** Lenses or domed epoxy distort the cosine response. Flat-window parts such as the Osram BPW34 class, widely used in CubeSat-style prototypes, or Hamamatsu flat-window photodiodes work well.
- **Low outgassing.** Ceramic or metal packages are preferred. If you use plastic, check the NASA outgassing database, aiming for TML < 1% and CVCM < 0.1%.
- **Matched parts.** Buy more than you need and pick diodes with similar responsivity. Calibration is still required, but matching reduces the corrections.
- **Expected current.** A ~7 mm² silicon photodiode under 1 sun AM0 can deliver on the order of a few milliamps. Compute it for your part from the datasheet's spectral responsivity integrated over the AM0 spectrum. If the current is too high for your readout, add a small aperture or a neutral-density filter.

### Cover Glass

In orbit, UV and protons can darken ordinary glass and the photodiode's own window. A thin cerium-doped or fused-silica cover glass over the diodes can reduce responsivity degradation over the mission. Account for the cover glass in the angular calibration, because Fresnel reflections can cause deviations from a cosine response at grazing angles (beyond about 60–70°).

## 3. Design the Readout Electronics

### Operating Mode

Run the photodiodes in photovoltaic mode (zero bias) into a transimpedance amplifier (TIA). This gives near-zero dark current, good linearity, and low temperature sensitivity, all useful for this application.

### Signal Chain per Channel

- **TIA:** a low-input-bias, low-offset, rail-to-rail CMOS op-amp.
- **Feedback resistor:** \(R_f \approx V_{\text{fullscale}}/(1.2 I_{\max})\). The 20% margin helps accommodate flux variation and additional illumination.
- **Feedback capacitor:** place it in parallel with \(R_f\). It limits bandwidth to a few tens of Hz and acts as an anti-alias filter. A CSS generally does not need high bandwidth.

### Simpler Alternative

A precision shunt resistor straight into the ADC, sized so the voltage at maximum current stays below about 100 mV, can work. It is less linear and more temperature-dependent, though.

### ADC and Interface

- A multi-channel ADC of 12–16 bits on I²C or SPI is generally sufficient for a prototype. ADS1115-class parts are common in hobbyist/CubeSat development setups.
- Put a temperature sensor on the board too, because you will need it for compensation.
- Either let the spacecraft's ADCS computer read the ADC directly, or add a small microcontroller that performs the calculations and outputs a Sun vector. The first option is simpler and has fewer parts to qualify.

### LEO-Specific Considerations

- **Radiation:** choose parts with flight heritage or radiation test data. Estimate the mission dose for the specific orbit and shielding using a tool such as SPENVIS.
- **Single-event latch-up:** consider current limiting and a power switch on the supply so latch-ups can be cleared.
- **PCB quality:** use an appropriate space-grade PCB process (IPC class 3 or equivalent where applicable), low-outgassing conformal coating, and staking for large components.

## 4. Build the Mechanical Housing

- **Material and finish:** machine the housing from aluminum (6061 or 7075) and black-anodize or black-coat it to suppress internal reflections.
- **Pyramid faces:** cut the faces at the chosen \(\beta\) with tight angular tolerance, ideally better than 0.1°. Any error becomes a fixed bias, though calibration can remove most of it.
- **Avoid shadowing at grazing angles:** keep the photodiodes flush or nearly flush with the surface. A raised lip or recess shadows the diode at grazing angles and narrows the FOV.
- **Alignment references:** add precision mounting surfaces and dowel pins, or an alignment cube, so the sensor frame is known relative to the spacecraft body frame.
- **Venting and staking:** vent any enclosed volume and stake the photodiodes and cover glass as appropriate.

### Placement on the Spacecraft

Mount the sensor where it cannot see deployable solar panels, antennas, or other shiny structures. Reflections from those surfaces cause errors that are difficult to calibrate out.

## 5. Write the Algorithm

The processing chain for each measurement:

1. **Dark subtraction:** remove the offset measured in eclipse or darkness, at the current temperature.
2. **Temperature compensation:** apply responsivity and offset corrections from thermal tests.
3. **Calibration correction:** apply the per-diode non-cosine correction from the testbed, either as a lookup table or a fitted polynomial.
4. **Sun-presence check:** declare “Sun visible” only if the summed or maximum current exceeds a threshold set well above the expected albedo level.
5. **Solve for the Sun vector:** for \(N\) lit diodes with normals stacked in matrix \(\mathbf{N}\) and currents in vector \(\mathbf{I}\), a least-squares estimate is

   \[
   \hat{\mathbf{s}} = (\mathbf{N}^{T}\mathbf{N})^{-1}\mathbf{N}^{T}\mathbf{I},
   \]

   then normalize \(\hat{\mathbf{s}}\). In practice, use a pseudoinverse or weighted least squares when the geometry is poorly conditioned or measurements have different uncertainties. This requires at least three lit, non-coplanar diode normals to estimate a general 3D vector.

   For the six-face layout, the vector is proportional to

   \[
   \mathbf{s} \propto
   (I_{+x}-I_{-x},\ I_{+y}-I_{-y},\ I_{+z}-I_{-z}).
   \]

6. **Albedo handling:** Earth reflects about 30% of sunlight globally on average, and in some geometries this can bias a naive CSS by many degrees. Options, from simplest to most effective, include:
   - Reject measurements when Earth fills the field of view, using the orbit position.
   - Subtract an albedo model.
   - Weight CSS measurements appropriately in an attitude filter.
7. **Sensor fusion:** combine the Sun vector with the magnetometer using TRIAD or QUEST for a direct attitude solution, or feed both into an extended Kalman filter.

## 6. Build Sequence

1. **Requirements:** define accuracy, FOV, coverage, mass, power, interface, thermal range, and radiation dose.
2. **Simulation:** model the diodes (cosine response, noise, quantization, albedo, temperature) in Python or MATLAB. Use it to choose \(\beta\), diode count, and ADC resolution, and to build an error budget.
3. **Breadboard:** use off-the-shelf photodiodes, a TIA, and an ADC on a 3D-printed pyramid. Verify the basic mathematics under a lamp on a rotation stage.
4. **Engineering model:** use a machined housing and flight-like PCB. Run the full testbed calibration.
5. **Qualification:** run vibration, thermal-vacuum, and radiation tests on the engineering model or a qualification unit, with a calibration check before and after each test.
6. **Flight model:** build and calibrate each unit individually, measure alignment, integrate it, and run a final Sun-presence and polarity check on the spacecraft. Wrong-sign axes are a common integration mistake.

## 7. Main Error Sources

The biggest error sources, roughly in order, are:

1. Earth albedo.
2. Deviation from the cosine response at large angles.
3. Sensor misalignment.
4. Temperature drift.
5. Noise and ADC quantization.

Spend effort in that order.

> **Practical note:** This is a preliminary design guide, not a flight-qualified design. Verify component limits, radiation tolerance, thermal behavior, and the exact geometry against datasheets and mission requirements before using it on a spacecraft.

## Next Step

A Python simulation of a pyramid CSS, including albedo and noise, can help select the tilt angle and diode count before building hardware.
