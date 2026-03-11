# Paper Outline & Progress Tracker

## � Overall Progress
**Estimated Completion: ~55%** _(update this as you go)_

| Section | Status | Progress |
|---------|--------|----------|
| Introduction | ⚠️ Partial | ~65% |
| Problem Formulation | ✅ Complete | 100% |
| Modeling | ✅ Complete | 100% |
| Estimation Framework | ✅ Complete | 100% |
| Baseline Model | ⚠️ Partial | ~60% |
| Evaluation Setup | ⚠️ Partial | ~85% |
| Results | ❌ Not Started | 0% |
| Conclusion | ❌ Not Started | 0% |

**⚠️ Critical Path Items:**
- [ ] **Literature Review** - Needs significant expansion
- [ ] **Baseline Model Estimator** - Implementation details needed
- [ ] **Simulation Results** - Generate all plots and tables
- [ ] **Real-World Results** - Process data and create visualizations
- [ ] **Conclusion Section** - Write summary and future work

## 🎯 Next Steps Priority List
**Focus on these high-impact items first:**

1. **📖 Literature Review** (Est. 2-3 days)
   - Expand Related Works section with 15-20 more references
   - Create comparison table with existing methods
   
2. **🔬 Run Simulations** (Est. 3-5 days)
   - Execute all scenarios with both models
   - Generate all data for analysis
   
3. **📊 Create Results Figures** (Est. 3-4 days)
   - Process simulation data
   - Generate Figures 3-9 (simulation)
   
4. **📈 Process Real-World Data** (Est. 2-3 days)
   - Extract ground truth from OxTS
   - Run estimator on real data
   - Generate Figures 10-14
   
5. **📋 Create Results Tables** (Est. 1-2 days)
   - Tables 2-7 with all metrics
   
6. **✍️ Write Results Discussion** (Est. 4-5 days)
   - Interpret findings
   - Compare simulation vs real-world
   - Statistical analysis
   
7. **🏁 Write Conclusion** (Est. 1 day)
   - Summary and future work

8. **🔍 Review & Polish** (Est. 2-3 days)
   - Notation consistency
   - Grammar and style
   - Co-author feedback

**Estimated time to completion: 18-26 days**

---

## 📅 Key Milestones
- [ ] First draft complete
- [ ] Internal review complete
- [ ] Submission deadline: _________
- [ ] Revision deadline (if applicable): _________

## 📏 Document Statistics
**Word Count Tracking:**
- Current: _______ words
- Target: _______ words (IEEE Trans typically 8000-12000 words)
- Current page count: _______ pages

**Citations:**
- Current: ~3-5 citations
- Target: 40-60 citations for comprehensive journal paper

---

## 📊 Figures & Tables Planning
**Target: ~10-15 figures, ~5-7 tables for journal paper**

### Figures (Status)
- [x] Figure 1: Top-down vehicle schematic with notation ✅
- [ ] Figure 2: Coordinate frames illustration (3D visualization)
- [ ] **Simulation Results (Figures 3-9):**
  - [ ] Figure 3: Circle maneuver - state estimates vs ground truth
  - [ ] Figure 4: Sine-with-Dwell - transient response
  - [ ] Figure 5: Incline scenario - gravity effects
  - [ ] Figure 6: Error distribution histograms (all states)
  - [ ] Figure 7: NEES consistency plots
  - [ ] Figure 8: Parameter convergence (augmented states)
  - [ ] Figure 9: Robustness - error vs parameter variations
- [ ] **Real-World Results (Figures 10-14):**
  - [ ] Figure 10: Real-world cornering maneuver
  - [ ] Figure 11: Real-world lane change
  - [ ] Figure 12: Real-world braking (coupling forces)
  - [ ] Figure 13: Low friction scenario (degradation)
  - [ ] Figure 14: Filter covariance evolution

### Tables (Status)
- [x] Table 1: State derivative mapping to equations ✅
- [ ] **Need to Create:**
  - [ ] Table 2: Vehicle parameters (masses, inertias, dimensions, tire params)
  - [ ] Table 3: Simulation RMSE results (all scenarios, both models)
  - [ ] Table 4: Simulation NEES results
  - [ ] Table 5: Computational performance (timing, memory)
  - [ ] Table 6: Real-world RMSE results
  - [ ] Table 7: Simulation vs real-world comparison

### Optional Additions
- [ ] Flowchart of UKF algorithm?
- [ ] Comparison table of related work vs this approach?
- [ ] Sensitivity analysis table?

## 📝 Writing Quality Checklist
- [ ] Notation consistency throughout paper
- [ ] All equations numbered and referenced
- [ ] All figures/tables referenced in text
- [ ] Citations complete and properly formatted
- [ ] Abstract reflects final contributions
- [ ] Acronyms defined on first use
- [ ] Spell check and grammar review
- [ ] Consistent tense (present for general truths, past for experiments)

## 💾 Supplementary Materials
- [ ] MATLAB/Python code for model implementation
- [ ] Simulation data or access instructions
- [ ] Real-world experimental data (if shareable)
- [ ] Extended derivations document
- [ ] Video demonstrations (if applicable)

## ❓ Known Issues & Open Questions
**Items that need clarification or decisions before finalizing**

### Literature & Motivation
- [ ] Need to clarify why damper model was chosen over alternatives (add design rationale)
- [ ] Should we include more citations? (target 40-60 for journal paper)
- [ ] Need better explanation of DAE computational burden

### Methodology
- [ ] What specific damper coefficient values were used? Document this
- [ ] How sensitive is the method to damper coefficient choice?
- [ ] Should we show results with different discretization methods beyond Euler?

### Results & Analysis
- [ ] Should we include computational timing benchmarks in a table?
- [ ] How to validate coupling forces without ground truth in real data?
- [ ] What threshold defines "acceptable" performance?
- [ ] Need more discussion on coupling force ground truth validation challenges
- [ ] Should we include failure cases or only successful scenarios?

### Writing & Presentation
- [ ] Need better explanation of when model assumptions break down
- [ ] Should we add a "Model Validation" subsection?
- [ ] Is the notation too complex? Feedback from coauthors?
- [ ] Do we need a nomenclature table?

### Technical Details
- [ ] Document filter tuning procedure more explicitly
- [ ] Add convergence analysis for parameter adaptation?
- [ ] Should we discuss observability of coupling forces?

### Data & Reproducibility
- [ ] Will we provide code/data as supplementary materials?
- [ ] Need to decide on data sharing policy (proprietary vehicle data?)

_Add your questions here as you write..._

## 📓 Writing Log
_Track daily progress and notes here_

### 2026-02-26
- Created paper outline with progress tracking
- Reorganized test setup section for better flow
- Added OxTS RT3000 v3 citation for ground truth system
- **Major update to outline:**
  - Reorganized all sections with current progress
  - Added 🎯 Next Steps Priority List with time estimates
  - Expanded Results section with detailed task breakdown (Figures 3-14, Tables 2-7)
  - Added 70+ specific TODO items across all sections
  - Identified critical path: Lit Review → Simulations → Results → Conclusion
  - Created comprehensive Known Issues & Open Questions
  - Added Document Statistics tracking

### [Date]
- _Add notes about what you worked on today..._

---

## ⚠️ Introduction (65% Complete)

### ✅ Motivation
- [x] Importance of accurate vehicle state and coupling force estimation for heavy commercial vehicles (safety, efficiency, control)
- [x] Challenges: complex dynamics, non-linearities, sensor noise, parameter uncertainties
- [x] Briefly state the contribution of the original conference paper

### ✅ Problem Statement
- [x] Clearly define the objective: developing a robust estimator for key vehicle states (velocities, orientation, articulation angle) and inter-unit coupling forces for multi-body vehicles
- [x] Emphasize the need for models that capture critical dynamic effects (e.g., those influenced by dampers)
- [x] State assumptions (high-friction scenarios, no extreme maneuvers)
- [x] Define state-space framework and notation

### ⚠️ Literature Review (30% Complete)
- [x] Reference comprehensive review paper (Habibnejad Korayem et al.)
- [x] Mention gaps in coupling-force estimation for heavy vehicles
- [ ] **TODO:** Detailed review of state estimation methods (EKF, UKF, particle filters)
- [ ] **TODO:** Review of multi-body vehicle dynamics modeling approaches
- [ ] **TODO:** Discussion of existing coupling force estimation techniques
- [ ] **TODO:** Comparison table of related work vs. this approach
- [ ] **TODO:** More citations needed (aim for 15-25 references in lit review)
- [ ] **TODO:** Discuss computational complexity of existing methods
- [ ] **TODO:** Highlight novelty of damper-based formulation more clearly

### ✅ Contributions
- [x] Detailed non-linear dynamic model for a tractor-trailer combination
- [x] Application and tuning of an Unscented Kalman Filter (UKF)
- [x] Rigorous comparison against a baseline model
- [x] Validation using both simulation and real-world data
- [x] Analysis of estimator performance across various scenarios

### ✅ Paper Outline
- [x] Brief overview of the subsequent sections

---

## ✅ Problem Formulation (Complete)

### ✅ State Estimation Objective
- [x] Define state vector $\bm{x}_k$ and uncertainty $\bm{P}_k$
- [x] Primary quantities of interest (coupling force, articulation angle, lateral velocities)
- [x] State-space model formulation

### ✅ Notation and Frame
- [x] Two-layer notation system (modeling vs. estimation)
- [x] Bold vectors, superscripts for frames/components
- [x] Subscript notation for units and positions
- [x] Example illustrations of notation

### ✅ Assumptions on Known and Measured Quantities
- [x] Known quantities (geometry, sensor calibration)
- [x] Measured quantities (axle loads, torques, wheel speeds, IMU, steering)
- [x] Uncertain quantities (mass, inertia, tire stiffness)

---

## ✅ Modeling (Complete)

### ✅ Coordinate Systems and Kinematics
- [x] Define world, vehicle body, and sensor frames
- [x] Transformation matrices (e.g., $R_{2/\w}(t) = R_z(\psi^z_{1\to2}(t)) R_{1/\w}(t)$)

### ✅ Tractor-Trailer Dynamics
- [x] Equations of motion for longitudinal, lateral, and vertical dynamics (expanded from conference paper's Eq. (1))
- [x] Rotational dynamics (roll, pitch, yaw rates - expanded from conference paper's Eq. (2))
- [x] Modeling of forces:
  - [x] Tire forces (e.g., Magic Formula, including cornering stiffness $C_{i,\mathcal{A} a}$)
  - [x] Aerodynamic drag ($C^{dx}_1, C^{dy}_1$) - *mentioned as neglected*
  - [x] Gravitational forces
  - [x] Drive and brake torques ($\bm{\tau}_1, \bm{\tau}_2$)
  - [x] Rolling resistance ($C^{rr}_1, C^{rr}_2$) - *mentioned as neglected*

### ✅ Inter-Unit Coupling Model
- [x] Detailed model of the coupling point forces and moments
- [x] Inclusion of damper characteristics (if applicable to the main model)
- [x] Articulation angle dynamics ($\dot{\alpha}^z_{1/2}(t)$ from conference paper's Eq. (\ref{eq:artAngle}))

### ✅ Pose Dynamics
- [x] Roll ($\alpha^x_1$) and pitch ($\alpha^y_1$) angle dynamics (Euler Angle Rate Transformation)
- [x] Body-frame roll and pitch rate dynamics ($\dot \omega^x_1, \dot \omega^y_1$)

### ✅ Complete Non-linear State-Space Model
- [x] Definition of state vector $\bm{x}(t)$
- [x] Definition of input vector $\bm{u}(t)$
- [x] Definition of parameter vector $\bm{\theta}$
- [x] Continuous-time model $\dot{\bm{x}}(t) = \bm{G}(\bm{x}(t),\bm{u}(t), \bm{\theta}) + \bm{q}(t)$
- [x] Detailed discussion of process noise $\bm{q}(t)$ and its components

### ✅ Sensor Models and Measurement Equations
- [x] Accelerometer: $\hat{\bm{a}}_{1,\mathcal{A} 1}[k] = \bm{a}_{1,\mathcal{A} 1}[k] + \bm{w}^{a}[k]$
- [x] Gyroscope: $\hat{\bm{\omega}}_1[k] = \bm{\omega}_1[k] + \bm{w}^{\omega}[k]$
- [x] Wheel Speed Sensors: $\hat{\omega}_{\text{t} i,\mathcal{A} a,s}[k] = v^{x}_{i,\mathcal{A} a,s}/r_{i,\mathcal{A} a,s} + w^{\omega}_{\text{t} i,\mathcal{A} a,s}$
- [ ] **New (Potentially):** GPS, Steering Angle sensor models if used in real-data tests
- [x] Detailed characterization of measurement noise and their covariances
- [x] Measurement vector $\bm{z}[k] = \bm{H}({\bm{x}}[k],\bm{u}[k],\bm{\theta}) + \bm{v}[k]$

---

## ✅ State Estimation Framework

### ✅ Recursive Bayesian Estimation
- [x] Brief theoretical background (prediction and update steps)

### ✅ Unscented Kalman Filter (UKF)
- [x] Justification for choosing UKF (handling non-linearities)
- [x] Detailed algorithm steps (sigma point generation, prediction, update)
- [x] Process Model Discretization:
  - [x] Euler approximation (as in conference paper) or higher-order methods
  - [x] $\bm{x}(T(k+1)) \approx \bm{x}(Tk) + T\bm{G}(\bm{x}(Tk), \bm{u}(Tk), \bm{\theta}) + T\bm{q}(Tk)$
- [x] State Augmentation for Parameter Uncertainty:
  - [x] Augmented state vector $[\bm{x}^\top, \bm{\theta}^\top]^\top$
  - [x] Discussion on which parameters are estimated/calibrated online
- [x] Filter Tuning and Initialization:
  - [x] Initial state covariance $\bm{P}[0]$
  - [x] Process noise covariance $\bm{Q}$
  - [x] Measurement noise covariance $\bm{R}$
  - [x] More detailed discussion on the tuning process

---

## ⚠️ Baseline Model for Comparison (60% Complete)

### ✅ Model Formulation (DAE System)
- [x] Describe the alternative model used for the baseline
- [x] DAE formulation with implicit coupling constraint
- [x] Specify the differences in equations compared to the full model
- [x] Explain computational challenges of DAE approach

### ❌ Estimator for Baseline Model
- [ ] **TODO:** Specify if the same UKF structure is used or a simpler filter
- [ ] **TODO:** Describe how DAE is solved at each filter step
- [ ] **TODO:** Parameter tuning for the baseline estimator
- [ ] **TODO:** Computational complexity comparison with damper model
- [ ] **TODO:** Any modifications needed for real-time implementation

---

## ⚠️ Evaluation (85% Complete - Mostly Setup, Results Pending)

### ✅ Maneuver Scenarios
- [x] Steady-state cornering at different speeds and radii
- [x] Transient lane changes
- [x] Braking maneuvers with varying load distributions
- [x] Justification for scenario selection

### ⚠️ Simulation Study (70% Complete)
- [ ] **TODO:** Simulation Environment:
  - [ ] Detailed description of the high-fidelity simulator (e.g., Volvo Transport Model - VTM)
  - [ ] Adaptations made to VTM for this study
  - [ ] Simulator validation approach
- [ ] **TODO:** Test Scenarios (need to document specific parameters):
  - [ ] Scenario 1: Circle (varying radii, speed, $0.3g$ limit) - add specific values
  - [ ] Scenario 2: Sine-with-Dwell (Laine et al., varying steering angles, $0.5g$ limit)
  - [ ] Scenario 3: Incline (varying inclinations $\pm10\%$, speeds, banked road)
  - [ ] Number of Monte Carlo runs per scenario
- [x] Simulation Variations:
  - [x] Trailer load randomization (0-25,000 kg, CoM displacement $\mathcal{N}(0,0.1)$)
  - [x] Cornering stiffness variations ($C_{i,\mathcal{A} a} \sim \mathcal{N}(9,1)$)
- [ ] **TODO:** Sensor Modeling and Noise Generation:
  - [ ] IMU noise based on Allan variance (specific parameters)
  - [ ] Assumptions for wheel angular velocity and steering angle noise
  - [ ] Modeling of drive/brake torque discrepancies between estimator and simulation
  - [ ] Sampling rates for all sensors
- [ ] **TODO:** Data Extraction and Ground Truth
  - [ ] List of states extracted from simulator
  - [ ] Time synchronization approach

### ✅ Real-World Data Experiments (95% Complete)
- [x] **Test Vehicle(s):**
  - [x] Instrumented tractor-trailer combination
  - [ ] **TODO:** Add specific vehicle model/specifications
  - [ ] **TODO:** List all sensors with mounting locations
- [x] **Data Acquisition:**
  - [x] Closed test track description
  - [x] Maneuvers performed (cornering, braking, lane change)
  - [x] Low friction testing (ice/snow conditions)
  - [ ] **TODO:** Add specific maneuver parameters (speeds, radii, etc.)
  - [ ] **TODO:** Document environmental conditions (temperature, road conditions)
- [x] **Ground Truth:**
  - [x] Two OxTS RT3000 v3 systems (tractor and trailer)
  - [x] Accuracy specifications documented
  - [x] Articulation angle extraction from dual INS
  - [ ] **TODO:** Explain coupling force ground truth approach (or lack thereof)
- [x] **Data Preprocessing:**
  - [x] Hardware timestamp synchronization
  - [x] Sensor calibration procedures
  - [ ] **TODO:** Outlier detection and removal criteria
  - [ ] **TODO:** Data filtering approach (if any)

### ✅ Performance Metrics (Complete)
- [x] Root Mean Square Error (RMSE) formulation
- [x] Normalized Estimation Error Squared (NEES) formulation
- [x] NEES interpretation (consistency check)
- [x] Computational load measurement for real-time feasibility
- [x] Comparison approach (proposed vs. baseline)

---

## ❌ Results and Discussion (0% Complete - MAJOR WORK NEEDED)

### ❌ Simulation Results
**This is the largest remaining task!**

#### Data Analysis Tasks
- [ ] **TODO:** Run all simulation scenarios with both proposed and baseline models
- [ ] **TODO:** Process simulation data and compute RMSE for all states
- [ ] **TODO:** Compute NEES for all states
- [ ] **TODO:** Calculate computational timing statistics
- [ ] **TODO:** Perform statistical analysis across Monte Carlo runs

#### Tables to Create
- [ ] **TODO:** Table 2: Vehicle parameters used in simulation
- [ ] **TODO:** Table 3: RMSE results for all scenarios (proposed vs baseline)
  - [ ] Tractor lateral velocity $v^y_{1,\text{CG}}$
  - [ ] Trailer lateral velocity $v^y_{2,\text{CG}}$
  - [ ] Articulation angle $\psi^z_{2\to1}$
  - [ ] Longitudinal coupling force $f^x_{1,\Cr}$
  - [ ] Lateral coupling force $f^y_{1,\Cr}$
  - [ ] Yaw rates $\omega^z_1, \omega^z_2$
- [ ] **TODO:** Table 4: NEES results (check for consistency)
- [ ] **TODO:** Table 5: Computational performance comparison

#### Figures to Create
- [ ] **TODO:** Figure 3: State estimates vs ground truth - Circle maneuver
  - [ ] Time series: articulation angle
  - [ ] Time series: coupling forces
  - [ ] Time series: lateral velocities
- [ ] **TODO:** Figure 4: State estimates vs ground truth - Sine-with-Dwell
  - [ ] Key states during transient
  - [ ] Error convergence
- [ ] **TODO:** Figure 5: State estimates vs ground truth - Incline scenario
  - [ ] Effect of gravity on estimation
- [ ] **TODO:** Figure 6: Error distributions (histograms)
  - [ ] For each key state variable
  - [ ] Compare proposed vs baseline
- [ ] **TODO:** Figure 7: NEES consistency plot over time
  - [ ] Show Chi-squared confidence bounds
- [ ] **TODO:** Figure 8: Parameter convergence (if augmented states used)
  - [ ] Tire stiffness adaptation
  - [ ] Mass parameter evolution
- [ ] **TODO:** Figure 9: Robustness analysis
  - [ ] Error vs load variation
  - [ ] Error vs tire stiffness variation

#### Discussion Points to Write
- [ ] **TODO:** Performance in different scenarios (circle, sine, incline)
- [ ] **TODO:** Impact of parameter variations (load, cornering stiffness)
- [ ] **TODO:** Why is lateral coupling force more challenging to estimate?
- [ ] **TODO:** Limitations observed (e.g., uncaptured dynamics like lateral weight transfer)
- [ ] **TODO:** When does the linearized tire model break down?
- [ ] **TODO:** Comparison of damper model vs DAE baseline (advantages/disadvantages)
- [ ] **TODO:** Statistical significance of improvements

### ❌ Real-World Data Results
**Second major task - validates the practical applicability**

#### Data Processing Tasks
- [ ] **TODO:** Process all real-world experimental data
- [ ] **TODO:** Extract ground truth from OxTS systems
- [ ] **TODO:** Compute articulation angle from dual INS measurements
- [ ] **TODO:** Run estimator on real sensor data
- [ ] **TODO:** Handle missing data / sensor dropouts
- [ ] **TODO:** Compute RMSE against ground truth
- [ ] **TODO:** Identify failure modes or degraded performance regions

#### Tables to Create
- [ ] **TODO:** Table 6: Real-world RMSE results (proposed vs baseline)
  - [ ] All measurable states (velocities, yaw rates, articulation)
  - [ ] Note: coupling forces may not have ground truth
- [ ] **TODO:** Table 7: Comparison of simulation vs real-world performance
  - [ ] Identify where simulation overpredicts/underpredicts

#### Figures to Create
- [ ] **TODO:** Figure 10: Real-world cornering maneuver
  - [ ] Estimated states vs RT3000 ground truth
  - [ ] Show both proposed and baseline
- [ ] **TODO:** Figure 11: Real-world lane change maneuver
  - [ ] Transient response accuracy
- [ ] **TODO:** Figure 12: Real-world braking maneuver
  - [ ] Coupling force estimates (no ground truth, but show consistency)
- [ ] **TODO:** Figure 13: Low friction scenario (ice/snow)
  - [ ] Estimator degradation when assumptions violated
  - [ ] Uncertainty growth
- [ ] **TODO:** Figure 14: Filter covariance over time
  - [ ] Demonstrate consistency
  - [ ] Show adaptation to changing conditions

#### Discussion Points to Write
- [ ] **TODO:** Performance under real-world conditions (sensor noise, unmodeled dynamics)
- [ ] **TODO:** Comparison with simulation results: consistencies and discrepancies
- [ ] **TODO:** What real-world effects are not captured by model?
- [ ] **TODO:** Challenges encountered (calibration, synchronization, etc.)
- [ ] **TODO:** Validation approach for coupling forces (no direct measurement)
- [ ] **TODO:** How well did parameter adaptation work?
- [ ] **TODO:** Sensitivity to initialization
- [ ] **TODO:** Computational performance on actual hardware

### ❌ Overall Discussion
**Synthesizing section - tie everything together**

- [ ] **TODO:** Create summary comparison: simulation vs real-world
- [ ] **TODO:** When does the damper model outperform the DAE baseline? Why?
- [ ] **TODO:** Computational cost analysis
  - [ ] Wall-clock time per filter update
  - [ ] Memory requirements
  - [ ] Feasibility for real-time embedded systems
- [ ] **TODO:** Robustness analysis summary
  - [ ] Sensitivity to parameter uncertainty
  - [ ] Graceful degradation under violated assumptions
- [ ] **TODO:** Practical implications
  - [ ] Suitability for safety systems
  - [ ] Requirements for production deployment
  - [ ] Sensor requirements and cost
- [ ] **TODO:** Comparison with literature results (if available)
- [ ] **TODO:** What makes coupling force estimation challenging?
- [ ] **TODO:** Key insights from damper-based modeling approach

---

## ❌ Conclusion and Future Work (0% Complete)

### ❌ Summary of Key Findings
- [ ] **TODO:** Recap the damper-based modeling approach
- [ ] **TODO:** Summary of simulation results (quantitative highlights)
- [ ] **TODO:** Summary of real-world validation results
- [ ] **TODO:** Comparison with baseline: quantify improvements (X% better RMSE, Y% faster)
- [ ] **TODO:** When is the method most effective?
- [ ] **TODO:** Successful demonstration of real-time capability

### ❌ Reiteration of Contributions
- [ ] **TODO:** Highlight how the journal paper extends the conference work
  - [ ] Added baseline comparison
  - [ ] Real-world validation
  - [ ] Extended modeling details
  - [ ] Broader evaluation scenarios
- [ ] **TODO:** Emphasize novelty of damper-based coupling model
- [ ] **TODO:** Practical impact for heavy vehicle industry

### ❌ Limitations
- [ ] **TODO:** Write limitations section based on results
  - [ ] Model does not capture lateral weight transfer
  - [ ] Longitudinal slip neglected
  - [ ] Linear tire model valid only in certain regimes
  - [ ] Damper model is a simplification
  - [ ] No direct coupling force ground truth in real data
- [ ] **TODO:** Discuss when the method breaks down (low friction, saturation)
- [ ] **TODO:** Sensor requirements that may not be universally available

### ❌ Future Work
- [ ] **TODO:** Prioritize future work items based on results
  - [ ] More detailed tire models (if degradation observed in results)
  - [ ] Lateral load transfer modeling
  - [ ] Extension to low-friction scenarios
  - [ ] Machine learning hybrid approaches
  - [ ] Multiple trailer configurations
  - [ ] Online adaptation of more parameters
  - [ ] Embedded implementation and hardware testing
- [ ] **TODO:** Mention ongoing work or planned experiments

---

## 📋 Review & Revision Tracking
### Internal Review
- [ ] Self-review complete
- [ ] Co-author review (Author 2): _________
- [ ] Co-author review (Author 3): _________
- [ ] Co-author review (Author 4): _________
- [ ] Co-author review (Author 5): _________

### Journal Submission
- [ ] Manuscript submitted
- [ ] Reviews received
- [ ] Response to reviewers drafted
- [ ] Revision submitted
- [ ] Accepted 🎉

### Reviewer Comments Addressed
- [ ] Reviewer 1 - Comment 1
- [ ] Reviewer 1 - Comment 2
- [ ] Reviewer 2 - Comment 1
- [ ] Reviewer 2 - Comment 2
- [ ] Reviewer 3 - Comment 1

---

## Legend
- ✅ Section Complete
- ⚠️ Section Partially Complete
- ❌ Section Not Started
- [x] Task Complete
- [ ] Task Pending

---

## 💡 Tips for Using This Outline
- **In VS Code**: Click checkboxes in the preview pane (Ctrl+Shift+V) to toggle them
- **On GitHub**: Checkboxes are interactive when viewing the file
- **Track Progress**: Update section status (✅/⚠️/❌) manually as you complete work
- **Stay Focused**: Use this to prioritize what section to work on next
