# In-House Coarse Sun Sensor (CSS): Development and Ground-Testing Laboratory Guide

**Purpose:** A practical guide to designing, building, calibrating, and environmentally verifying an in-house coarse Sun sensor before integrating it into a satellite.

**Intended use:** University or small-satellite laboratory developing a photodiode-based CSS, including a CubeSat-class instrument.

**Document status:** Engineering guidance. This is not a qualification procedure or a substitute for mission-specific requirements, approved test specifications, or launch-provider requirements.

---

## Table of contents

1. [Objective and verification philosophy](#1-objective-and-verification-philosophy)
2. [Requirements to define before testing](#2-requirements-to-define-before-testing)
3. [Overall ground-test programme](#3-overall-ground-test-programme)
4. [TB-1: Optical characterization and angular response](#4-tb-1-optical-characterization-and-angular-response)
5. [TB-2: Sun-vector accuracy and calibration](#5-tb-2-sun-vector-accuracy-and-calibration)
6. [TB-3: Electrical characterization](#6-tb-3-electrical-characterization)
7. [TB-4: Thermal characterization and cycling](#7-tb-4-thermal-characterization-and-cycling)
8. [TB-5: Thermal-vacuum testing](#8-tb-5-thermal-vacuum-testing)
9. [TB-6: Mechanical vibration and shock testing](#9-tb-6-mechanical-vibration-and-shock-testing)
10. [TB-7: Integrated CubeSat functional test bed](#10-tb-7-integrated-cubesat-functional-test-bed)
11. [Additional mission-dependent environmental tests](#11-additional-mission-dependent-environmental-tests)
12. [How to arrange the laboratory](#12-how-to-arrange-the-laboratory)
13. [Equipment procurement plan](#13-equipment-procurement-plan)
14. [Recommended development and verification sequence](#14-recommended-development-and-verification-sequence)
15. [Verification matrix and reporting](#15-verification-matrix-and-reporting)
16. [Practical engineering recommendations](#16-practical-engineering-recommendations)
17. [References and standards](#17-references-and-standards)

---

## 1. Objective and verification philosophy

The objective is to demonstrate that the CSS can reliably detect the Sun and estimate its direction in the satellite body frame over the required operating range, and that the flight-like hardware can survive the environments relevant to the mission.

A photodiode producing a voltage when illuminated is not, by itself, a flight-ready Sun sensor. The full instrument includes:

- Photodiodes and any optical windows, masks, apertures, or baffles.
- Mechanical support and the sensor-to-spacecraft mounting interface.
- Analog front-end electronics, such as load resistors or transimpedance amplifiers (TIAs).
- ADC, digital electronics, firmware, and data interface to the onboard computer (OBC).
- Calibration data, Sun-vector estimation algorithm, health flags, and fault handling.

The ground programme should establish five things:

1. **Measurement performance:** The sensor detects the Sun and estimates its direction within the allocated angular-error budget.
2. **Operating envelope:** It works over the required field of view (FOV), irradiance range, and temperature range.
3. **Electrical performance:** Dark current, noise, drift, linearity, saturation, power consumption, and communication are acceptable.
4. **Environmental robustness:** The flight-like assembly tolerates mission-relevant thermal, vacuum, vibration, radiation, contamination, and other environments as applicable.
5. **Integrated functionality:** The CSS works with the spacecraft power, OBC, mounting geometry, coordinate frames, and attitude-control software.

### 1.1 Verification is not the same as qualification

Use separate, documented test phases:

- **Development testing:** Characterizes prototypes, finds weaknesses, and informs design changes.
- **Qualification testing:** Demonstrates that a representative design can withstand the specified qualification environment, including the project-defined margins.
- **Acceptance testing:** Screens each flight unit for workmanship and verifies it at the acceptance levels defined by the project.
- **Protoflight testing:** A project-specific approach that combines selected qualification and acceptance objectives on flight hardware. It must be planned and approved; it is not simply an informal combination of tests.

The applicable test levels, durations, margins, and sequence must come from the spacecraft's verification plan and the current project-tailored standard. Do not copy generic test numbers from another satellite.

---

## 2. Requirements to define before testing

Before designing the test beds, create a CSS requirements sheet. The exact targets depend on the spacecraft, orbit, attitude-control concept, sensor geometry, and OBC.

| Requirement | What must be specified | Why it matters |
|---|---|---|
| FOV | Required azimuth/elevation coverage and any blind regions | Sets the angular test range and geometry |
| Angular accuracy | Maximum, RMS, or percentile error requirement | Sets calibration and reference-stage accuracy |
| Resolution | Smallest useful angular change | Influences ADC resolution, noise, and calibration spacing |
| Detection threshold | Minimum irradiance or minimum usable signal | Determines low-light performance and validity logic |
| Maximum irradiance | Brightest expected condition and saturation margin | Prevents output clipping or front-end saturation |
| Spectrum | Required performance under AM0 sunlight or another defined spectrum | Photodiode responsivity depends on wavelength |
| Temperature | Operating and non-operating limits, including survival limits | Drives component selection and thermal testing |
| Vacuum | Mission pressure and relevant contamination constraints | Drives materials, harnessing, and TVAC configuration |
| Mechanical environment | Launch vibration, shock, and acoustic environments at the interface | Drives fixture and qualification planning |
| Orbit and lifetime | Altitude, inclination, mission duration, shielding, eclipse profile | Drives radiation, UV, and atomic-oxygen assessments |
| Power | Allowed voltage, current, startup behaviour, and peak consumption | Drives front-end and spacecraft interface design |
| Data interface | UART, I2C, SPI, CAN, or project-specific interface | Defines integrated testing |
| Reliability / fault response | Invalid-data handling, channel failures, reset behaviour | Prevents corrupted measurements reaching the ADCS |

**Important:** A test range such as −60° to +60° is only an example. It is not a universal CSS FOV requirement. Define the actual test range from the sensor design and mission requirements.

---

## 3. Overall ground-test programme

The recommended programme has seven core test beds, plus additional mission-dependent environmental tests.

| Test bed | Main purpose | Recommended approach |
|---|---|---|
| TB-1: Optical characterization | FOV, angular response, sensitivity, cosine-like behaviour | Build in-house |
| TB-2: Angular accuracy | Validate calibration and Sun-vector estimation | Build in-house |
| TB-3: Electrical characterization | Dark current, noise, linearity, ADC, power | Build in-house |
| TB-4: Thermal characterization | Temperature dependence and thermal cycling | Use a university chamber or partner facility |
| TB-5: Thermal vacuum (TVAC) | Verify operation under vacuum and thermal extremes | Outsource initially |
| TB-6: Mechanical testing | Verify structural and electrical integrity under launch loads | Outsource to a qualified shaker facility |
| TB-7: Integrated satellite testing | Verify CSS-to-OBC-to-ADCS data path and coordinate transformations | Build in-house |

The most useful first investment is a stable optical bench with a two-axis rotary stage, reference detector, low-noise readout, and repeatable data acquisition. This gives the team a way to compare photodiodes, masks, housings, and electronics without rebuilding the laboratory for each design iteration.

---

## 4. TB-1: Optical characterization and angular response

**Priority:** Build in-house first.

### 4.1 Purpose

This test bed determines how each photodiode responds to incoming light as a function of incidence angle and irradiance. It should establish:

- Angular response of each detector.
- FOV and detection threshold near the FOV boundary.
- Response relative to the ideal cosine law.
- Irradiance sensitivity and usable dynamic range.
- Repeatability and hysteresis.
- Effects of apertures, masks, protective windows, and housing geometry.

For an ideal planar detector with a fixed spectrum and uniform irradiance, the direct-light component is approximately proportional to the cosine of the angle between the incoming ray and the detector normal:

\[
I_{\mathrm{ph}}(\theta) \propto E A R_{\mathrm{eff}}\max(0,\cos\theta),
\]

where \(E\) is irradiance, \(A\) is active area, \(R_{\mathrm{eff}}\) is the effective spectral responsivity for the source spectrum, and \(\theta\) is the incidence angle relative to the detector normal. The actual response can depart from this ideal model because of package lenses, encapsulation, masks, detector construction, reflections, and internal shading. Measure the assembled sensor rather than assuming an ideal cosine response.

### 4.2 Equipment

| Equipment | Purpose |
|---|---|
| Stable broadband light source or solar simulator | Provides controlled illumination |
| Optical collimator | Produces a beam with known direction and low angular spread |
| Optical breadboard or rigid optical rail | Stable mechanical support |
| Two-axis rotary stage / goniometer | Changes CSS orientation in pitch and yaw |
| Calibrated angular encoders | Provides angular reference data |
| Calibrated reference photodiode or radiometer | Measures irradiance at the detector plane |
| Optical power meter | Reads the reference detector |
| Neutral-density filters | Varies irradiance in a controlled manner |
| Iris, aperture, and field stop | Controls beam size and illuminated area |
| Dark enclosure with matte-black interior | Suppresses ambient light and stray reflections |
| Alignment telescope, autocollimator, or laser alignment tool | Establishes optical and mechanical alignment |
| Multichannel DAQ | Records all CSS channels synchronously |
| Temperature sensor near the photodiodes | Records detector temperature during calibration |

### 4.3 Selecting the illumination source

Three practical options are available:

| Source | Best use | Limitations |
|---|---|---|
| Quartz-tungsten-halogen lamp | Low-cost initial response curves and relative tests | Spectrum differs from AM0; output and temperature must be controlled |
| Broadband LED source | Basic electronic checks and controlled relative measurements | Spectrum may be narrow or structured; not a solar-spectrum substitute |
| Xenon-arc or other characterized solar simulator | Higher-fidelity solar-spectrum characterization | More expensive; spectrum, uniformity, stability, and calibration must still be verified |

Use a lower-cost source for early development if necessary. However, do not treat a halogen lamp or LED as an AM0 solar simulator. Photodiode current is spectrum-dependent:

\[
I_{\mathrm{ph}} = A\int E_\lambda(\lambda) R(\lambda)\,d\lambda,
\]

where \(E_\lambda\) is spectral irradiance and \(R(\lambda)\) is photodiode spectral responsivity. If the laboratory source is not AM0-like, measure or obtain credible source-spectrum and detector-responsivity data and account for spectral mismatch when transferring the calibration to the expected solar spectrum.

The AM0 reference solar irradiance is approximately **1361.1 W/m²** on a plane normal to the incoming solar direction. This is a reference value, not a requirement that every early prototype test be conducted at full solar irradiance. Use attenuators or a controlled source level as needed, and document the irradiance at the CSS plane.

### 4.4 Optical layout

A practical arrangement is:

```text
  Stable light source
         |
         v
  Source aperture / field stop
         |
         v
  Collimator and baffles
         |
         v
  Reference radiometer at DUT plane
         |
         v
  CSS mounted on two-axis goniometer
         |
         +---- electrical harness ---- DAQ / PC

  Enclose the optical path in a dark, baffled housing.
```

Build the setup in this order:

1. Fix the source and collimator to a rigid optical breadboard or rail.
2. Align the collimator axis with the mechanical reference axis of the test fixture.
3. Install the CSS on a two-axis stage. Align the stage's centre of rotation with the intended optical reference point of the CSS, as closely as practical.
4. Place the reference radiometer at the CSS detector plane to characterize irradiance. Do not assume the source output is uniform over the whole detector area.
5. Install baffles and a dark enclosure to suppress room light and internal reflections.
6. Route the sensor harness so that it does not exert a changing torque on the rotary stage.
7. Connect the CSS to the DAQ and record the stage angles, irradiance, temperature, and all detector channels against a common time base.

#### Collimation and source angular size

Do not confuse **beam divergence** with the **apparent angular size of the source**.

- For a point-like angular-response calibration, use a beam whose direction and angular spread are measured and sufficiently small relative to the angular-error requirement.
- For a Sun-disc-representative test, the apparent angular diameter should be close to the Sun's approximately 0.53° angular diameter, if that effect is relevant to the sensor design and test objective.

For an extended source of diameter \(d\) at distance \(D\), its small-angle apparent diameter is approximately:

\[
\alpha_{\mathrm{source}} \approx \frac{d}{D}.
\]

For a finite source placed near the focal plane of a collimator of focal length \(f\), the angular extent of the collimated output is approximately \(d/f\), before including optical aberrations and alignment errors. Measure the actual output beam geometry; do not infer it only from nominal lens dimensions.

A small aperture 3 m from the sensor can define a small apparent source angle, but that geometry alone does not establish that the emitted rays are sufficiently collimated. The source, aperture, collimator, and reference-angle measurement must be treated as one calibrated optical system.

### 4.5 Experiments

#### Experiment A — Angular response

1. Stabilize the source and measure irradiance at the CSS plane.
2. Set a fixed irradiance level and record the CSS output at the nominal normal-incidence position.
3. Rotate the sensor through the required angular range in pitch and yaw.
4. Use a step size fine enough to resolve the response features and FOV boundary.
5. Record each photodiode channel, reference angles, irradiance, and temperature.
6. Repeat the sweep in both directions to identify hysteresis or mechanical backlash.
7. Compare the measured response with a cosine reference curve, but retain the measured curve as the actual calibration data.

Recommended plots:

- Detector current or voltage versus incidence angle.
- Normalized response versus incidence angle.
- Measured response versus ideal cosine response.
- Difference between forward and reverse sweeps.

#### Experiment B — FOV characterization

Define the minimum usable detector output or signal-to-noise criterion from the requirements. Rotate the sensor to find where the output falls below that criterion. Record:

- Usable FOV for each detector and for the full CSS assembly.
- Blind zones and mechanical masking effects.
- Angle at which the measurement becomes unreliable.
- Whether the FOV changes with irradiance or temperature.

Do not define the FOV solely by a non-zero output. Define it by a usable measurement criterion, such as a maximum angular error or a minimum signal-to-noise ratio.

#### Experiment C — Irradiance sensitivity and dynamic range

1. Hold the incident angle fixed.
2. Change irradiance using calibrated neutral-density filters or a controlled source setting.
3. Measure photocurrent or output voltage across the intended operating range.
4. Identify the minimum usable level, linear region, and saturation point.
5. Repeat at representative incidence angles, because angular response and irradiance sensitivity can interact.

#### Experiment D — Repeatability

Repeat identical angular sweeps after re-positioning the sensor, power cycling, and (where relevant) removing and reinstalling it. Quantify the spread in detector output and estimated angle. This helps separate electronic repeatability from fixture and mounting repeatability.

### 4.6 Expected outputs

- Angular response curve for every photodiode.
- Measured FOV and blind-zone map.
- Irradiance sensitivity and dynamic range.
- Source irradiance and spectral characterization records.
- Repeatability and hysteresis results.
- Initial calibration coefficients or lookup tables.

---

## 5. TB-2: Sun-vector accuracy and calibration

**Priority:** Build in-house.

### 5.1 Purpose

This test bed verifies the output of the complete CSS algorithm against a known incoming light direction. It answers the central system question: can the instrument estimate the Sun direction in its own coordinate frame with the required accuracy?

### 5.2 Equipment

| Equipment | Purpose |
|---|---|
| Characterized collimated light source | Provides known illumination direction |
| Two-axis precision goniometer | Provides controlled pitch/yaw positions |
| Calibrated angular encoders | Provides reference angles |
| Optical alignment reference | Establishes the relationship between beam, stage, and sensor frames |
| Reference irradiance detector | Monitors illumination |
| DAQ and computer | Acquires raw channels and runs the calibration software |

### 5.3 Test arrangement and procedure

Fix the source and collimator. Mount the CSS on the goniometer. Establish the sensor coordinate frame and record the alignment transform between the stage frame and the CSS frame.

For each test position:

1. Command or set the required pitch and yaw.
2. Record both reference angles from the calibrated encoders.
3. Record all raw photodiode outputs.
4. Calculate the Sun vector using the candidate CSS algorithm.
5. Transform the reference direction into the same coordinate frame as the estimated vector.
6. Calculate the angular error.
7. Repeat over the full required FOV and over representative irradiance levels.

### 5.4 Reference vector and angular error

For one common azimuth/elevation convention, the unit vector can be written as:

\[
\hat{\mathbf{s}}_{\mathrm{ref}} =
\begin{bmatrix}
\cos\delta\cos\alpha\\
\cos\delta\sin\alpha\\
\sin\delta
\end{bmatrix},
\]

where \(\alpha\) is azimuth and \(\delta\) is elevation. This convention is only an example: use the coordinate definitions and rotation sequence specified by the project, and document signs and axis directions explicitly.

Let \(\hat{\mathbf{s}}_{\mathrm{CSS}}\) be the estimated unit vector. The angular error is:

\[
\epsilon = \cos^{-1}\!\left(\operatorname{clip}\left(
\hat{\mathbf{s}}_{\mathrm{ref}}\cdot\hat{\mathbf{s}}_{\mathrm{CSS}},-1,1
\right)\right).
\]

Normalize both vectors before computing the dot product. The `clip` operation avoids numerical errors slightly outside the valid inverse-cosine range.

### 5.5 Experiments

- **Pitch sweep:** Characterize elevation response.
- **Yaw sweep:** Characterize azimuth response.
- **Two-dimensional grid:** Test combined pitch and yaw over the whole useful FOV.
- **Boundary test:** Check performance close to the edges of the FOV and near detector handover regions.
- **Irradiance variation:** Repeat selected angles at different light levels.
- **Repeatability:** Repeat the same grid after re-mounting or power cycling.
- **Fault injection:** Simulate an open, short, saturated, or obscured detector channel in a safe way and verify fault flags and degraded-mode behaviour.

### 5.6 Calibration and independent validation

Do not use every measured point to fit the calibration and then claim the fit error as independent validation.

Split the measurements into:

- **Calibration set:** Used to fit curves, coefficients, or lookup tables.
- **Validation set:** Independent angular positions, including intermediate points not used during fitting.

A calibration grid may use regular angular spacing, while validation points should include interstitial and boundary-near locations. Set the spacing based on the required angular resolution and the stage's measurement uncertainty.

Report at least:

- Mean angular error.
- RMS angular error.
- Maximum angular error.
- 95th-percentile angular error.
- Repeatability.
- Error as a function of pitch, yaw, irradiance, and temperature.

A two-dimensional error heat map over the FOV is particularly useful for diagnosing geometry and calibration problems.

### 5.7 Expected outputs

- Sensor-to-stage alignment transform.
- Calibration coefficients or lookup tables.
- Independent validation dataset.
- Angular-error statistics and FOV error maps.
- Fault-detection and invalid-measurement behaviour.

---

## 6. TB-3: Electrical characterization

**Priority:** Build in-house.

### 6.1 Purpose

This test bed validates the photodiodes, analog front end, ADC, power supply interface, and digital readout. A sensor can have good optical properties but still fail because of dark current, noise, offset drift, saturation, unstable supplies, poor grounding, or firmware issues.

### 6.2 Equipment

| Equipment | Purpose |
|---|---|
| Source Measure Unit (SMU) | Measures detector current and electrical characteristics |
| Precision digital multimeter | Measures voltage, current, and reference values |
| Oscilloscope | Observes noise, transients, and startup behaviour |
| Programmable DC power supply | Provides controlled input voltage and power cycling |
| Low-noise TIA test circuit | Converts small photodiode currents to measurable voltage |
| DAQ or flight-like ADC | Measures the complete readout chain |
| Dark enclosure | Provides a controlled no-light condition |
| Temperature sensors | Records detector and electronics temperatures |
| Computer and data logger | Stores raw data and test conditions |

### 6.3 Experiments

#### A. Dark-current measurement

Place the detector in a light-tight enclosure and measure its current with no intended illumination. Record the detector temperature, measurement bandwidth, bias condition, and instrument range. Dark current is temperature-dependent, so a room-temperature result alone is insufficient.

#### B. Linearity

Change irradiance in measured steps while keeping the incident angle fixed. Plot photocurrent or output voltage against irradiance. Determine the usable linear range, deviation from the fitted response, and the onset of saturation.

#### C. Noise and stability

Hold the CSS at a fixed angle and fixed irradiance. Record a sufficiently long time series. Evaluate:

- RMS noise and peak-to-peak variation.
- Short-term stability and long-term drift.
- Low-frequency fluctuations.
- Channel-to-channel variation.
- Noise after filtering and at the actual ADC sampling rate.

State the sample rate, bandwidth, filter settings, and measurement duration whenever reporting noise.

#### D. TIA and ADC performance

Test the whole signal chain, including the sensor, TIA, filters, ADC reference, grounding, and firmware. Verify that the smallest angularly significant change in photocurrent is distinguishable above the total measurement noise. Confirm headroom at the maximum expected signal and avoid clipping at any stage.

For a simple TIA operating in its linear region, the output magnitude is approximately:

\[
|V_{\mathrm{out}}| \approx I_{\mathrm{ph}}R_f,
\]

where \(R_f\) is the feedback resistance. The actual design must account for amplifier input bias current, input noise, stability, bandwidth, parasitic capacitance, output swing, and the photodiode capacitance.

#### E. Power, startup, and reset behaviour

Measure supply current and voltage during:

- Power-up and initialization.
- Normal measurement.
- Maximum illumination.
- Low-signal operation.
- Data transmission to the OBC.
- Reset, brownout, and recovery.

Verify that the CSS returns to a known state after power cycling and that the OBC can identify stale or invalid measurements.

### 6.4 Expected outputs

- Dark-current versus temperature data.
- Linearity and dynamic-range plots.
- Noise and stability report.
- ADC resolution and saturation assessment.
- Startup, reset, and power-consumption report.

---

## 7. TB-4: Thermal characterization and cycling

**Priority:** Use a university thermal chamber or external environmental facility during early development.

### 7.1 Purpose

The CSS must maintain useful performance across the temperatures predicted for its installed location. Temperature can affect photodiode responsivity and dark current, TIA offset and gain, ADC references, mechanical alignment, adhesives, and protective optical materials.

### 7.2 Equipment

| Equipment | Purpose |
|---|---|
| Programmable thermal chamber | Controls the test article temperature |
| RTDs or calibrated thermistors | Measures detector, PCB, and fixture temperatures |
| Temperature data logger | Records thermal history |
| Optical source and collimator | Allows illuminated functional testing |
| Optical window or suitable optical feedthrough | Allows illumination while the article is inside the chamber |
| DC supply and DAQ feedthroughs | Power and data connections |
| Reference thermometer | Checks the temperature measurement chain |

### 7.3 Test configuration

A basic arrangement is:

```text
       Collimated light source
                 |
                 v
        Chamber optical window
                 |
       +---------------------+
       |  Thermal chamber   |
       |                     |
       |  CSS on fixture     |
       |  RTD / thermistors  |
       +---------------------+
                 |
       Electrical feedthroughs
                 |
              DAQ / PC
```

If the chamber does not have a suitable optical window, an alternative test method may be needed. Do not compromise the chamber's thermal or vacuum integrity by installing an improvised window or feedthrough.

### 7.4 Experiments

#### A. Temperature-dependent optical calibration

At each temperature plateau:

1. Allow the detector, PCB, and relevant fixture locations to reach the defined stabilization condition.
2. Record all temperatures.
3. Illuminate the CSS at known reference angles and irradiance.
4. Record all photodiode channels and the estimated Sun vector.
5. Compare response and angular error against the room-temperature baseline.
6. Repeat at selected points during heating and cooling to look for hysteresis.

This determines whether one calibration is adequate or whether temperature-dependent correction tables are needed.

#### B. Thermal cycling

Cycle the assembly through the mission-derived hot and cold test limits and required number of cycles. Record powered and unpowered conditions according to the approved test procedure. Inspect for:

- PCB, solder, or connector damage.
- Photodiode movement or detachment.
- Window or coating damage.
- Adhesive cracking or degradation.
- Changes in alignment.
- Irreversible changes in sensitivity, dark current, or noise.

**Do not select arbitrary limits such as −40 °C and +85 °C and assume that passing them demonstrates flight suitability.** Derive the operating and non-operating limits from thermal analysis, component limits, mission conditions, and the tailored verification plan.

### 7.5 Expected outputs

- Photodiode output versus temperature.
- Dark-current and noise versus temperature.
- Angular-error versus temperature.
- Thermal-cycle history and post-cycle inspection report.
- Decision on temperature compensation or recalibration.

---

## 8. TB-5: Thermal-vacuum testing

**Priority:** Outsource initially to a qualified thermal-vacuum facility.

### 8.1 Purpose

A thermal chamber at atmospheric pressure is not equivalent to space vacuum. In vacuum, convective heat transfer is essentially absent, so component temperatures and heat flow can differ substantially. TVAC testing verifies that the CSS operates under the combined vacuum and thermal conditions specified for the mission.

### 8.2 Equipment and facility provisions

| Equipment / provision | Purpose |
|---|---|
| Thermal-vacuum chamber and pumping system | Creates the required vacuum environment |
| Vacuum gauges | Measures chamber pressure |
| Thermal shroud or controlled mounting plate | Provides the specified thermal boundary conditions |
| Thermocouples or RTDs | Measures CSS, fixture, and interface temperatures |
| Optical viewport or suitable internal illumination system | Allows functional optical tests in vacuum |
| Electrical feedthroughs | Carries power and sensor data outside the chamber |
| Vacuum-compatible mounting fixture | Represents the spacecraft mounting interface |
| DAQ and control workstation | Monitors performance throughout the test |

### 8.3 Recommended arrangement

A practical arrangement is to mount the CSS on a thermally representative plate inside the chamber. Place the solar simulator and collimator outside the chamber and send the beam through an appropriate optical viewport, if the facility supports this arrangement.

Before testing, characterize the viewport's:

- Spectral transmission over the detector's relevant response range.
- Reflection and transmission losses.
- Wedge or angular effects that could alter beam direction.
- Thermal behaviour and suitability for the chamber pressure and temperature.

Measure illumination at the test plane or use a suitable internal reference detector where practical. Include viewport and alignment effects in the test uncertainty budget.

### 8.4 Tests to perform

- **Vacuum functional test:** Monitor electronics, data interfaces, and detector outputs during pump-down and at the defined vacuum condition.
- **Hot and cold functional plateaus:** At specified plateaus, measure dark current, output noise, angular response at selected points, Sun-vector error, and power consumption.
- **Thermal-vacuum cycling:** Perform the project-defined cycles and dwell periods under vacuum.
- **Post-TVAC functional test:** Repeat the optical and electrical checks after return to ambient conditions.
- **Inspection:** Check connectors, coatings, windows, adhesives, and mechanical alignment.

The chamber pressure, temperatures, dwell times, number of cycles, powered states, and functional-test points must be defined by the mission-specific test specification. They are not universal values.

### 8.5 Expected outputs

- Pressure and temperature histories.
- Functional performance at hot and cold plateaus.
- Electrical and optical results before, during, and after TVAC.
- Anomaly log and post-test inspection report.

---

## 9. TB-6: Mechanical vibration and shock testing

**Priority:** Outsource to a facility with an electrodynamic shaker and suitable instrumentation.

### 9.1 Purpose

Launch loads can damage the CSS or shift the alignment of its detectors. Possible failure modes include:

- Photodiode or window detachment.
- Cracked PCB or solder joints.
- Broken connectors or harnesses.
- Structural cracking.
- Loss of mounting preload.
- Permanent sensor-to-spacecraft alignment shift.

### 9.2 Equipment

| Equipment | Purpose |
|---|---|
| Electrodynamic shaker | Applies controlled vibration |
| Flight-representative mounting fixture | Reproduces the satellite interface |
| Accelerometers | Measures input and response acceleration |
| Vibration controller | Controls the required test profile |
| Signal conditioner | Conditions accelerometer signals |
| DAQ | Monitors CSS function before, during where appropriate, and after test |
| Calibrated torque tools | Controls installation torque |

### 9.3 Test procedure

1. Record the CSS configuration, fastener details, mounting torque, harness routing, and photographs.
2. Perform pre-test visual, electrical, and optical characterization.
3. Install the CSS in a fixture that reproduces the flight mounting interface and relevant boundary conditions.
4. Install control and response accelerometers at approved locations.
5. Perform a low-level resonance survey if specified.
6. Apply the project-defined sine and/or random vibration test along the required axes.
7. Perform shock testing only where the spacecraft or launch/deployment environment requires it.
8. Inspect the assembly after each test direction or stage as specified.
9. Repeat optical and electrical characterization and compare with the pre-test baseline.

Do not simply clamp the sensor in an arbitrary orientation. The fixture stiffness, fastener arrangement, panel interface, and harness restraint can significantly affect the measured response.

### 9.4 Mechanical test types

| Test | Typical purpose |
|---|---|
| Resonance survey | Identifies structural modes and detects major shifts |
| Sine vibration | Evaluates response to specified sinusoidal excitation |
| Random vibration | Evaluates response to broadband launch vibration |
| Mechanical shock | Evaluates specified separation or deployment shock environment |
| Acoustic test | Usually considered at spacecraft or subsystem level when required by the launch environment |

The test spectrum, levels, duration, axes, notching, and acceptance criteria must be derived from launch-provider and spacecraft interface requirements. Do not invent a generic vibration profile.

### 9.5 Expected outputs

- Fixture and instrumentation configuration.
- Accelerometer records and test profiles.
- Pre/post-test inspection report.
- Pre/post-test angular calibration comparison.
- Evidence that no unacceptable structural or functional degradation occurred.

---

## 10. TB-7: Integrated CubeSat functional test bed

**Priority:** Build in-house; use a structural mock-up or engineering model.

### 10.1 Purpose

A standalone CSS can work on the optical bench yet fail after integration because of grounding, supply fluctuations, harness routing, data protocol errors, incorrect sensor mounting orientation, or coordinate-frame mistakes. The integrated test bed verifies the end-to-end measurement chain.

### 10.2 Equipment

| Equipment | Purpose |
|---|---|
| CubeSat structural mock-up or engineering model | Reproduces the installation geometry |
| Flight-like CSS assembly | Sensor under test |
| OBC development board or engineering model | Receives measurements and runs flight-like software |
| Programmable power supply | Simulates satellite power interface |
| UART, I2C, SPI, or CAN tools as applicable | Tests communication and data integrity |
| Collimated optical source | Provides known illumination direction |
| Precision rotary table or goniometer | Changes spacecraft orientation relative to the source |
| DAQ and data-logging computer | Records sensor, OBC, and reference data |
| Three-axis rate table, where available | Supports dynamic rotation tests |

### 10.3 End-to-end test

Verify the complete chain:

```text
Incoming light
      |
      v
Photodiode array
      |
      v
Analog front end / TIA
      |
      v
ADC and digital readout
      |
      v
CSS firmware and data packet
      |
      v
Onboard computer
      |
      v
Sensor-frame to body-frame transformation
      |
      v
Sun vector and validity/status flags
      |
      v
ADCS software
```

Test the following:

1. Illuminate the integrated model from a known reference direction.
2. Confirm the raw detector outputs match the standalone calibration within the expected integration tolerance.
3. Verify packet format, scaling, units, sign conventions, timestamps, and data validity flags.
4. Verify the sensor-to-body mounting transformation using the actual mounting geometry.
5. Compare the OBC Sun vector against the optical reference direction in the same coordinate frame.
6. Test power cycling, reset, brownout recovery, and communication loss.
7. Test invalid conditions: Sun outside FOV, partial illumination, detector obstruction, saturated channel, disconnected channel, and low-signal condition.

### 10.4 Dynamic attitude testing

Rotate the model while keeping the simulated incoming light direction fixed in the laboratory frame. The apparent Sun direction in the spacecraft body frame should change as predicted by the known rotation. Check sampling frequency, latency, filtering, dropout handling, and coordinate transformations.

A precision rotary table is sufficient for many static and low-rate tests. A three-axis rate table is useful if the mission requires dynamic performance characterization and the facility is available.

### 10.5 Expected outputs

- End-to-end test report.
- Verified sensor-to-body transformation.
- Data-interface and timing report.
- Invalid-data and fault-handling results.
- Integrated Sun-vector error statistics.

---

## 11. Additional mission-dependent environmental tests

These tests are not automatically required for every CSS. Their applicability should be decided from orbit, duration, exposed materials, component selection, shielding, installation location, and system-level requirements.

### 11.1 Radiation testing

Relevant semiconductor effects include:

- **Total ionizing dose (TID):** Cumulative ionizing radiation can cause parameter shifts or functional degradation.
- **Displacement damage dose (DDD):** Non-ionizing particle interactions can degrade semiconductor properties, including detector performance.
- **Single-event effects (SEE):** Individual energetic particles can cause transient or destructive effects in susceptible electronics.

The radiation environment must be estimated for the mission orbit, duration, shielding, and component location. Test representative components or assemblies when the radiation analysis and project risk justify it. Use a radiation-effects facility with appropriate dosimetry and pre/post-test electrical characterization.

Potential equipment/facility needs include proton or electron irradiation, dosimetry, controlled biasing, current monitoring, and calibrated electrical measurement equipment. These tests are normally outsourced.

### 11.2 UV and atomic oxygen exposure

For exposed LEO hardware, assess ultraviolet exposure and atomic oxygen (AO) effects on optical windows, coatings, adhesives, polymers, and protective materials. Depending on the material and location, degradation can include erosion, discoloration, cracking, or reduced optical transmission.

Use an appropriate UV exposure facility and, where justified, an atomic-oxygen exposure facility. Measure window and coating transmission before and after exposure. Not every CSS component requires a dedicated AO test; material and mission exposure analysis should drive the decision.

### 11.3 Outgassing and contamination

Potential sources include adhesives, encapsulants, potting compounds, coatings, cable insulation, and polymeric structural elements. Volatile compounds can be released in vacuum and may deposit on a cooler optical surface.

ASTM E595 is a screening method for total mass loss (TML) and collected volatile condensable materials (CVCM). It is a material-screening test, not a guarantee that a complete assembly will remain uncontaminated. Acceptance criteria must be specified by the project and should consider material processing, geometry, temperature, and optical contamination sensitivity.

Also define cleaning, handling, storage, and contamination-control practices for optical parts and assemblies.

### 11.4 EMI/EMC and ESD

Evaluate the CSS electronics in the context of the satellite electrical environment. Tests may include:

- Conducted emissions and susceptibility.
- Radiated emissions and susceptibility.
- Power-line disturbances and transient response.
- Grounding and bonding checks.
- ESD susceptibility at applicable interfaces and handling controls.

The spacecraft-level EMC plan and applicable project standards should determine test methods and limits.

---

## 12. How to arrange the laboratory

A cost-effective approach is to build one optical/electronics laboratory and use shared or external environmental facilities. Do not initially spend the project budget on a TVAC chamber or vibration shaker unless there is a wider institutional requirement for those facilities.

### 12.1 Zone A — Optical characterization area

Allocate approximately 2–3 m of bench length if the collimator and optical geometry need it; the actual footprint depends on focal length, source size, and enclosure. Install:

- Rigid optical breadboard or rail.
- Stable broadband source.
- Collimator and apertures.
- Two-axis rotary stage and angular encoders.
- CSS mounting fixture.
- Calibrated reference radiometer.
- Neutral-density filters.
- Dark enclosure with baffles.
- DAQ and workstation.

Keep the optical path free from ambient light and reflective objects. Use matte-black baffles and a stable mechanical base. Keep electrical cables from pulling on the rotating stage.

### 12.2 Zone B — Electronics workbench

Install:

- Oscilloscope.
- SMU.
- Precision DMM.
- Programmable DC power supply.
- Low-noise TIA development boards.
- ADC and DAQ hardware.
- Temperature sensor readout.
- Soldering and rework station.
- ESD-safe work surface and handling tools.
- Computer for Python/MATLAB analysis and version-controlled test scripts.

### 12.3 Zone C — Environmental test access

Arrange access to:

- Programmable thermal chamber.
- Thermal-vacuum chamber.
- Electrodynamic shaker and vibration instrumentation.
- Radiation-effects facility where required.
- UV and atomic-oxygen facilities where required.
- EMC laboratory.

For a university project, these facilities are usually better accessed through another institute, national laboratory, launch/space industry partner, or commercial test house during early development.

---

## 13. Equipment procurement plan

### 13.1 Priority 1 — Build the in-house optical/electrical laboratory

| Equipment | Minimum functional requirement / selection note |
|---|---|
| Optical breadboard or rigid optical rail | Stiff enough to maintain source, collimator, and stage alignment |
| Stable broadband source | Prefer adjustable intensity and stable output |
| Collimator | Select based on beam diameter, source size, and required angular spread |
| Two-axis rotary stage | Travel must cover required FOV; encoder accuracy must support the error budget |
| Calibrated angular reference | Calibrated encoders or external angular metrology |
| Reference photodiode/radiometer | Calibrated over the relevant wavelength and irradiance range |
| Optical power meter | Compatible with the reference detector |
| Neutral-density filters | Known optical density and suitable spectral behaviour |
| Dark enclosure | Light-tight, baffled, matte-black interior |
| SMU | Suitable current range and resolution for photodiode measurements |
| Oscilloscope | Adequate bandwidth and noise performance for the circuit under test |
| Precision DMM | Calibrated voltage/current measurement |
| Programmable power supply | Adjustable voltage, current limit, and power cycling |
| Low-noise TIA and ADC hardware | Representative of the intended signal chain |
| Multichannel DAQ | Synchronous acquisition of channels and test metadata |
| Temperature sensors and logger | Calibrated measurement near detector and electronics |
| Workstation | Data logging, plotting, calibration, and analysis |

### 13.2 Priority 2 — Add when the prototype is stable

| Equipment | Purpose |
|---|---|
| AM0-characterized solar simulator | Mission-relevant spectral characterization |
| Precision autocollimator | High-quality angular alignment and reference measurement |
| Programmable thermal chamber | Temperature-dependent optical/electrical characterization |
| Spectroradiometer | Measures source spectral irradiance |
| Spectrophotometer | Measures optical window/coating transmission |
| Environmental data logger | Long-duration test monitoring |

### 13.3 Priority 3 — Outsource initially

| Facility | Purpose |
|---|---|
| Thermal-vacuum facility | Combined vacuum and thermal verification |
| Electrodynamic shaker | Sine/random vibration and applicable shock tests |
| Radiation facility | TID, DDD, and SEE testing as required |
| Atomic-oxygen facility | LEO material exposure as required |
| UV exposure facility | Material and optical degradation testing |
| EMC laboratory | Electromagnetic compatibility testing |

---

## 14. Recommended development and verification sequence

Use a staged process. Do not send an uncharacterized first prototype directly to expensive environmental testing.

1. **Engineering prototype:** Assemble the photodiodes, mechanical structure, analog electronics, ADC, and firmware. Establish basic dark and illuminated operation.
2. **Optical characterization:** Measure angular response, FOV, irradiance response, repeatability, and source conditions.
3. **Algorithm validation:** Use the goniometer as angular ground truth. Fit calibration curves and validate on independent angular points.
4. **Electrical characterization:** Measure dark current, noise, linearity, dynamic range, ADC behaviour, startup, power consumption, and reset recovery.
5. **Thermal characterization:** Measure performance at mission-derived temperature plateaus and through thermal cycles.
6. **Design iteration and configuration freeze:** Resolve anomalies, update drawings, firmware, calibration procedures, and the bill of materials. Record the exact configuration under test.
7. **Environmental verification:** Perform applicable TVAC, vibration, shock, radiation, UV/AO, outgassing, and EMC tests using approved test specifications.
8. **Post-environment characterization:** Repeat optical and electrical tests and compare with the pre-environment baseline.
9. **Satellite integration:** Verify the flight-like CSS with the OBC, actual mounting interface, harness, and ADCS data path.
10. **Flight-unit acceptance and closeout:** Perform the project-defined acceptance tests, review nonconformances, and deliver the test data package.

---

## 15. Verification matrix and reporting

Create a requirements verification matrix before formal testing. Each row should point to a requirement, test method, measured result, acceptance limit, evidence file, and pass/fail disposition.

| Parameter | Measurement / method | Acceptance basis |
|---|---|---|
| FOV | Angular sweep over required directions | Meets specified coverage and blind-zone requirements |
| Angular accuracy | Estimated vector versus reference vector | Within allocated angular-error budget |
| Resolution | Smallest distinguishable direction change | Meets specified angular resolution |
| Repeatability | Repeated runs and re-mount tests | Within repeatability requirement |
| Sensitivity | Output versus measured irradiance | Detects minimum specified irradiance |
| Linearity | Photocurrent/output versus irradiance | Within allocated nonlinearity |
| Dark current | Dark measurement at specified temperatures | Below design limit |
| Noise | Time-series analysis at specified bandwidth/sample rate | Below measurement noise budget |
| Power | Supply current and voltage measurement | Within spacecraft power budget |
| Temperature | Functional and accuracy tests across temperature | Meets operating accuracy and survival requirements |
| Vacuum | Functional monitoring during TVAC | No unacceptable degradation or anomaly |
| Vibration/shock | Pre/post-test inspection and functional characterization | No unacceptable structural or performance failure |
| Radiation | Pre/post-irradiation component or assembly characterization | Meets mission radiation tolerance requirement |
| Optical material exposure | Transmission and inspection before/after UV/AO as applicable | Meets optical/material degradation limits |
| Integrated operation | OBC and ADCS end-to-end functional test | Correct data, frame, timing, and validity behaviour |

### 15.1 Suggested test report contents

Every test report should include:

- Test ID, date, operator, facility, and approved procedure revision.
- Hardware serial number and configuration: PCB revision, detector part numbers, firmware hash, mechanical drawing revision, and calibration version.
- Test objective and requirements verified.
- Setup photographs and wiring/optical diagrams.
- Equipment list, instrument serial numbers, calibration status, and measurement uncertainty.
- Environmental conditions and boundary conditions.
- Raw data files and analysis scripts.
- Plots, statistics, and pass/fail assessment.
- Anomaly log, deviations, waivers, and corrective actions.
- Pre-test and post-test inspection records.

Keep raw detector channels. Do not store only the final Sun vector; raw data is essential for diagnosing sensor, electronics, calibration, and algorithm problems.

---

## 16. Practical engineering recommendations

1. **Build the two-axis optical calibration rig first.** It provides the highest development value per unit cost and supports rapid iteration of sensor geometry, detector choice, masks, and electronics.
2. **Measure the assembled sensor.** Package windows, adhesives, baffles, apertures, and mechanical tolerances can change the response from the bare-photodiode datasheet.
3. **Treat spectrum as a calibration variable.** A halogen or LED source is useful for development, but its response cannot be assumed identical to AM0 solar illumination.
4. **Calibrate and validate with separate datasets.** Independent angular points prevent an over-fitted response curve from appearing more accurate than it is.
5. **Build the uncertainty budget.** Include stage accuracy, alignment, source divergence, source stability, irradiance measurement, DAQ resolution, noise, and repeatability.
6. **Characterize temperature dependence early.** Photodiode dark current and electronic offsets can change with temperature; do not wait until TVAC to discover this.
7. **Use flight-like mounting during mechanical testing.** Fixture stiffness and mounting details influence the result.
8. **Re-run optical calibration after environmental tests.** A sensor that still powers on may have shifted mechanically or electrically.
9. **Keep a controlled hardware/software configuration.** The test evidence is valid only for a traceable configuration; changes after qualification may require analysis or retesting.
10. **Define invalid-measurement behaviour.** The OBC should know when the Sun is outside the FOV, the signal is too weak, a detector has failed, or an output is saturated.
11. **Do not equate passing a component test with mission qualification.** The integrated, flight-like assembly and the complete mission environment matter.

### 16.1 Safety

High-intensity lamps, UV sources, lasers, high-voltage supplies, thermal chambers, vacuum systems, and vibration equipment introduce hazards. Use facility-approved operating procedures, interlocks, eye protection, electrical protection, and trained operators. Do not look directly into a collimated high-intensity source or operate improvised vacuum/thermal equipment without an approved safety review.

---

## 17. References and standards

The following references provide useful methods, standards, and examples. Check the current revision and applicability before writing a formal test procedure.

### 17.1 Directly relevant Sun-sensor study

1. **Porras-Hermoso, A. et al. (2021).** “Design, Ground Testing and On-Orbit Performance of a Sun Sensor Based on COTS Photodiodes for the UPMSat-2 Satellite.” *Sensors*, 21(14), 4905. [https://doi.org/10.3390/s21144905](https://doi.org/10.3390/s21144905)  
   Particularly relevant to a low-cost academic CSS programme: it describes a photodiode-based sensor, low-cost illumination and angular-response tests, response-curve fitting, and comparison with on-orbit performance. The authors discuss the spectral difference between terrestrial illumination and AM0 and the implications for photodiode calibration.

### 17.2 Environmental verification and testing standards

2. **NASA GSFC-STD-7000B (28 April 2021).** *General Environmental Verification Standard (GEVS) for GSFC Flight Programs and Projects.* [NASA Technical Standards System — standard record and PDF](https://standards.nasa.gov/node/791)  
   Provides guidance for environmental verification of GSFC payloads, subsystems, and components. It is a useful reference, but its requirements should be tailored to the actual mission and governing authority.

3. **ECSS-E-ST-10-03C Rev.1 (31 May 2022).** *Space engineering — Testing.* [ECSS standard page](https://ecss.nl/home/ecss-e-st-10-03c-rev-1-testing-31-may-2022/)  
   Covers ground verification testing for space-segment elements and equipment, including test programme management, environmental tests, and qualification, acceptance, and protoflight testing. Tailor it to the project.

4. **NASA Small Satellite Reliability Initiative (SSRI) Knowledge Base.** [NASA SSRI Knowledge Base](https://www.nasa.gov/smallsat-institute/ssri-knowledge-base/)  
   Useful topic-based resources for small-satellite design, integration and test, thermal cycling, thermal vacuum, vibration, radiation, and day-in-the-life testing. See also the [Day-in-the-Life Testing topic](https://s3vi.ndc.nasa.gov/ssri-kb/topics/36/).

### 17.3 Solar-spectrum and simulator reference

5. **ECSS-E-ST-20-08C Rev.2 (20 April 2023).** *Photovoltaic assemblies and components.* [ECSS PDF](https://ecss.nl/wp-content/uploads/2023/08/ECSS-E-ST-20-08C_Rev.2%2820April2023%29.pdf)  
   This is primarily a photovoltaic-assemblies-and-components standard, not a dedicated coarse Sun-sensor standard. Its solar-simulator and calibration section includes AM0 spectral-distribution, irradiance, and simulator-characterization material that can be useful as a technical reference when specifying illumination. Apply it to a CSS only where relevant and with project approval.

### 17.4 Materials outgassing

6. **ASTM E595-15(2021).** *Standard Test Method for Total Mass Loss and Collected Volatile Condensable Materials from Outgassing in a Vacuum Environment.* [ASTM standard page](https://store.astm.org/e0595-15r21.html)  
   Describes a screening method for material outgassing. The standard notes that material acceptance criteria are user- and application-dependent and that passing the material screen alone does not guarantee system-level contamination control.

### 17.5 Radiation-effects background

7. **NASA Small Spacecraft State-of-the-Art: Small Spacecraft Avionics — Radiation Mitigation and Tolerance Schemes.** [NASA SmallSat Institute](https://www.nasa.gov/smallsat-institute/sst-soa/small-spacecraft-avionics/)  
   Summarizes TID, displacement damage, and single-event effects relevant to small-spacecraft electronics.

---

## Final recommendation

For an in-house development effort, first build the **optical characterization and two-axis angular calibration facility**, together with a low-noise electronics bench. These facilities will let the team establish the CSS response, Sun-vector accuracy, and electrical behaviour before spending money on expensive environmental campaigns.

Once the design is stable, use shared or external facilities for thermal-vacuum, vibration, radiation, UV/atomic-oxygen, and EMC testing as required by the mission. Repeat the optical and electrical characterization after environmental exposure, then complete an end-to-end test with the flight-like spacecraft electronics and mounting geometry.

A CSS should be considered a credible flight candidate only when its requirements are defined, its calibration is independently validated, its flight-like hardware has passed the applicable mission-tailored verification programme, and its performance evidence is traceable to the final hardware and firmware configuration.
