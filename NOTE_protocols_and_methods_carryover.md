# NOTE — protocols & methods carryover (compounded from Code/notes, 2026-06-11)

Consolidates the still-relevant content of `Code/notes/{tuning_campaign_plan,
ablation_design, DISCUSSION_2026-06-11, STATUS_2026-06-10, ALIGN_main_supervisor_SP}.md`,
which are deleted from the Code repo (full text remains in its git history,
commit 06cc56f). Held-out RESULTS live in `NOTE_heldout_results_and_calibration_for_results.md`;
paper-change decisions in `NOTE_MASTER_paper_changes.md`. This note carries the
METHODS, PROTOCOLS, and WRITING-ALIGNMENT material.

---

## 1. Tuning-campaign protocol (authoritative; for §Method)

### Governing rule — MODEL EQUALITY, not result equality
Same vehicle/sensors/road ⇒ every PHYSICAL uncertainty is model-independent and
tied IDENTICALLY across the three formulations; only formulation-internal
propagation differs.
- **Shared block (tuned once, cross-model objective):** physical consider σ —
  m, Jz, L_CoG, Cts (tire relaxation), Crr (rolling resistance), axle
  efficiency, wheel radius R, chassis-to-road tilt δ_roll/δ_pitch per body.
  Sensor R frozen at datasheet values.
- **Per-model:** process noise Q (genuine unmodeled-dynamics/discretization
  content differs: FS carries cfx/cfy ODE states; DAE/Lag solve algebraically)
  + FS-only d_c scale.
- **Report, never tune away:** cfx/cfy NEES, low-speed divergence, articulation
  conditioning. Under identical physical uncertainty, residual result
  differences ARE the model-distinction findings.
- Quantified model-equality cost (train): shared σ that fixes DAE/Lag pushes FS
  slightly over-confident (cfy NEES 1.15→2.61 @sine; ≤×1.5 over band). Joint
  trade: FS +0.7 vs DAE/Lag −156 in J. Defensible: per-model σ would be
  physically inconsistent.

### Objective (constrained design A; signed off 2026-06-10)
Per model: gated mean-NRMSE + asymmetric NEES barrier, summed over every
(quantity, maneuver); joint J = J_FS + J_DAE + J_Lag.
- FIXED NEES band [0.5, 2]; over-confidence (NEES>2) weight 1.0,
  under-confidence (NEES<0.5) weight 0.2 — over-confidence is the dangerous
  failure mode (filter rejects good data). Barrier λ=10 dominates while
  infeasible ⇒ calibration-first, accuracy tie-break.
- 11 quantities, all optimized + constrained (anti-cheat; QoI
  {cfx, cfy, art, vy1, vy2} are the read-out, never the exclusive target):
  cfx, cfy, articulation, vy1, vy2, vx1, vx2, wz1, wz2, tractor roll-rate,
  tractor pitch-rate. Uniform weights.
- Fixed physical NRMSE scales: cfx,cfy = m_trailer·g (per case); art =
  0.0873 rad (5°); vy = 2 m/s; vx = 20 m/s; wz = 0.2 rad/s; roll/pitch rate =
  0.05 rad/s.
- Cross-maneuver: mean NRMSE across maneuvers; NEES must hold on EVERY
  maneuver (worst-case).
- **VELOCITY GATE:** all metrics computed only on samples with tractor
  |vx1| > 2 m/s. Rationale: exact-constraint forms lose 6×6 conditioning as
  forces → 0 near standstill (brake_straight cfy blows to 30 kN DAE / 13 kN Lag
  entirely in the vx<0.5 tail; truth |cfy|max = 11 N). Applied identically in
  tuning and the held-out gate. Low-speed divergence reported SEPARATELY as a
  finding (open problem, all formulations — see NOTE_heldout §4).
- Train/held-out split: tune + evaluate on `train_experiments/` only
  (3 maneuvers: circle_slope, brake_straight, sine; pinned recipe
  `VTM_CouplingForce/runTrainExperimentsDLL.m`, Seed=43, CaseIdBase=1e5);
  `experiments/` untouched as the held-out gate (Sobol seed 42, base 0 —
  disjoint by construction).

### Wheel-speed / tyre-radius integrity (key generation-side correction)
Old generation LEAKED the per-case effective rolling radius: WheelSpeeds
measurements used R_cal least-squares-fit to each case's own (ω, v) ⇒ meas ≈
v_true; radius error unobservable. FIX: R_cal = 0.49 FIXED at generation
(meas = ω·0.49, leaving the physical residual ω·(0.49 − R_eff(t)),
load-correlated ±1.6%); estimator nominal R = 0.49 with consider-R entering
the wheel-speed innovation via h = vx·0.49/R_param (linear option; the
angular formulation h = vx/R is the right choice for real encoder data —
deferred). Same consider-R covers the cfx torque/R residual.

### Chassis-to-road tilt consider offset (δ) — design rationale
Models assume the road plane world-aligned; on graded roads the grade projects
into the body frame as heading-varying roll/pitch, omitting an Fz·sin(tilt)
load projection ⇒ systematic cfy/cfx error with no covariance to cover it.
Design: CONSIDER-ONLY, not a deterministic compliance model — nominal δ=0
keeps the deterministic output unchanged; per-body σ(δ) injects the missing
covariance via the symbolic Jacobian (∂Fy/∂δ_roll = −Fz, ∂Fx/∂δ_pitch = +Fz).
Calibrates NEES; does NOT remove the cfy mean bias ("we don't model it, we
bound it"). Tuner independently recovered the measured roll-dominance
(trailer roll σ 0.73°→2.0°, pitch → ≲0.04°; measured body↔road tilt ≤2.7°
roll vs ≤0.55° pitch) — good faith-in-physics anecdote for the paper.

### Optimizer & methodology references (for §Method)
- CMA-ES (Hansen & Ostermeier 2001; Hansen 2016 tutorial; purecmaes variant),
  log₁₀ parameterization, box-clipped, rank-based (invariant to objective
  rescaling). 35 effective dims (8 shared σ + per-model Q + FS d_c); pop 16 ×
  18 gen ≈ 290 evals × 87 estimator runs, 8 workers (~7×, 2.5 h).
- NEES-consistency objective in the spirit of Chen/Heckman/Julier/Ahmed
  (FUSION 2018, BO-based, lower-dim); offline truth-supervised, complementary
  to online noise-covariance identification (Duník/Straka line).
- The joint search with the TIED physical block is the methodological novelty;
  CMA-ES itself is commodity.
- Caveats to state plainly: single run (restart protocol planned for final
  config: 2–3 perturbed restarts); winner is best-of-290 on one frozen noise
  realization per case ⇒ optimism bias expected (held-out shrinkage measured:
  negligible, FS cfy@sine 2.61→2.63); held-out gate certifies generalization
  across cases/noise draws and partially across maneuver class (circle absent
  from training), NOT broadly across unseen maneuver classes.
- Result: J 160.9 → 5.99 (FS 1.49 / DAE 1.90 / Lag 2.60), baked into prep
  files and verified exact (J = 5.99271). DAE vs Lag genuinely diverged in
  tuned Q (e.g. q.velX ×0.48 vs ×2.7) — supports the claim that formulations
  distribute unmodeled error differently under identical physics.

## 2. Ablation protocol: consider vs legacy parameter treatment (designed, NOT run)

Motivation: consider/Schmidt filtering is standard in aerospace navigation
(Schmidt 1966; Tapley/Born/Schutz; Zanetti & Bishop) but rare in vehicle
dynamics — the contribution claim needs the ablation to be credible.

| Rung | Name | Mechanism | Recompile? |
|---|---|---|---|
| 1 | none | all params.q = 0 (plain UKF, Q/R only) — typical VD baseline | YES (structural; distinct cache hash, coexists) |
| 2 | timevarying | same σ, per-step injection (parameter ≈ process noise; legacy) | no (tag-only) |
| 3 | consider | deployed (constant bias, maintained state-param cross-cov) | baseline |

Rung 2→3 = the scientific comparison (identical magnitudes, different
correlation treatment); rung 1→2 = "does parameter uncertainty matter at all."
Switch: `global MUSE_PARAM_TREATMENT` read at the END of each prep_params
(composes with CMA override; default byte-identical). Globals do NOT cross
process boundaries — batch compiles and workers must set it.

Fairness: deployed Q was tuned WITH consider active ⇒ per-rung Q retune
(rung 2: full 35-D, tag ablate_tv; rung 1: Q-only 27-D, needs tune_campaign
extension to skip shared knobs + set global in i_workerctx). Fallback if time
is short: run rungs 1–2 with deployed Q + state the caveat (biases against
them on RMSE, but the headline NEES effect is barely Q-sensitive).

Evaluation per rung: train EvalOnly (~15 min) → held-out sweep (~4 h) →
benchmark_runtime (idle machine). Delivers contribution 2 and the ablation in
ONE table: "consider costs X µs/step and buys NEES 160→~1."

Pre-registered predictions (falsifiable): RMSE nearly flat across rungs;
DAE/Lag cfx/cfy NEES rung 1 catastrophic (record: 16–43, historically 162),
rung 2 partial, rung 3 in/near band; FS effect present but smaller (cf are
states; DAE/Lag route cf through Pxc). Paper figure: per state, 3 rungs × 3
models; RMSE panel flat, NEES panel collapsing onto [0.5,2], runtime row.

Joint-estimation defense (text): Crr/axleEff/δ are weakly/un-observable from
IMU + wheel speeds on maneuver timescales; joint estimation of unobservable
parameters drifts. Consider is the established remedy for
constant-but-unobservable nuisance parameters. Cite aerospace lineage; claim
novelty of application to articulated-vehicle coupling-force estimation
(after a literature check).

Execution order (post wasm-truth regeneration): equivalence check old/new
truth → EvalOnly re-verify bake → consider-block re-anchor (m/Jz/L_CoG causal,
FS q.d_c re-seed) + restart-protocol retune → final rung-3 sweep → rung-2
retune+sweep → rung-1 compile+retune+sweep → benchmark ×3 → figure/table.

## 3. Supervisor-meeting decisions pending (2026-06-11 agenda; record outcomes here)

- **D1** Headline framing: "deepening and correcting" the conference result
  (damper Fc-RMSE edge REVERSED under matched tuning) + terminology fix (no
  estimator integrates a DAE; three classical ODE reductions:
  multiplier / embedding / penalty).
- **D2** Low-speed = OPEN PROBLEM in all formulations (damper fails bounded
  via implicit regularization cf = −d_c·Δv; exact forms unbounded; 70× severity
  gap; FS NEES 480 also invalid). Baumgarte-type principled regularization =
  future work, possibly separate paper.
- **D3** Winter2022 real data (16 ice-circle cases): in or out of scope?
- **D4** Model-equality rule sign-off (cost quantified above).
- **D5** Calibration-first trade sign-off (DAE/Lag art/vy2 RMSE doubled to buy
  NEES feasibility; cfx/cfy untouched).
- **D6a** Venue: AC proposes vehicle dynamics (VSD / MSD / IEEE T-VT).
  Consequences: multibody taxonomy = shared vocabulary; imported novelty =
  estimation machinery; Baumgarte treatment mandatory; short NEES primer in
  results; mechanics notation with ONE rigorous SDE statement.
- **D6** Ablation scope: is the observability argument in text enough, or must
  the joint-estimation alternative be run?

## 4. Writing alignment — SP/tracking dialect (main supervisor; also the home dept.)

Elevator framing: "process model selection under consistency constraints" —
three candidate process models for the same physical system, same measurement
model, evaluated as UKFs on accuracy AND filter consistency (NEES), consider
parameters for unobservable biases, noise covariances tuned by black-box
optimization on train and validated on a SEM-controlled held-out Monte Carlo set.

Vocabulary map (VD habit → SP equivalent): equations of motion/formulation →
process model f; measurement matching → measurement model h; maneuver →
scenario; case/.h5 → Monte Carlo run/realization; tuning campaign → noise
covariance identification; uncertain parameters → nuisance/consider
parameters; post-hoc force recovery → derived output (function of the state
estimate); damper d_c → regularization (Tikhonov analogy).

Collision warnings (words meaning something ELSE in tracking):
- "gating" = measurement-association gating ⇒ call ours **low-speed exclusion**;
- "maneuver(ing)" = unmodeled-acceleration/IMM problem ⇒ say scenario;
- "track" (verb) reserved; say follows / give RMSE;
- "stability" — filter divergence vs vehicle yaw stability: always qualify;
- "consistency" ×3 (NEES-consistent filter — HIS default; statistically
  consistent estimator; constraint-consistent accelerations) — qualify at
  first use, the multiplier derivation uses sense 3 in the same paper;
- "convergence" ×3 (filter transient / Monte Carlo SEM stop / CMA-ES) — never
  bare;
- "observer" (control/VD) → filter/estimator;
- "model" → simulator / process model / implementation, never bare;
- deterministic unmodeled effects are model error/bias, NOT noise (this
  distinction IS the consider-parameter argument);
- "robust" → say graceful degradation / bounded failure mode.

Notation: states are processes — one rigorous SDE statement
dx = f(x,u)dt + G dw (ẋ does not exist under process noise), then discrete
time and STAY there: x_{k+1} = f(x_k,u_k) + w_k, w_k ~ N(0, Q·Δt) (Euler;
own the large-Δt limitation). x̂_{k|k}, P_{k|k}; Bar-Shalom (Estimation with
Applications to Tracking and Navigation) is the shared NEES reference.
Our dynamics are autonomous — time enters only through u(t).

ODE/DAE ladder (the bridge sentence all three supervisors meet at):
explicit ẋ = g(t,x); implicit 0 = F(ẋ,x,t) with ∂F/∂ẋ invertible; DAE =
∂F/∂ẋ singular; semi-explicit DAE ẋ = f(x,z,t), 0 = g(x,z,t) with z = our λ
= Fc. Constrained mechanics in position coordinates = index 3; differentiate
twice → index 1. The pair {M q̈ = Q + Gᵀλ, g(q) = 0} is the DAE; the three
estimator models are its classical ODE reductions: multiplier/augmented
(pointwise 6×6 solve — f defined implicitly but IS a function; low speed: f
exists but conditioning and ∂f/∂x blow up, which the UKF propagates),
embedding/projection (Kane; identical algebra at derivation time ⇒ machine-
precision equal), penalty/compliance (damper; explicit ODE of a slightly
different system; bounded biased low-speed behavior). Drift note: no
redundant coordinates in our state vector (articulation is a state, trailer
velocity kinematically slaved) ⇒ position-level constraint enforced
structurally; classical Baumgarte drift does not arise, the solve only
produces constraint-consistent accelerations/forces.

Likely questions: CRLB/PCRLB — concede, scope as future; observability —
standstill Fc unobservability is exactly why nuisance parameters are CONSIDER
not jointly estimated; why CMA-ES not BO — 35-D, rank-based, noise-tolerant,
parallel population, no gradient (BO precedent = FUSION 2018 at lower dim);
overfitting — frozen realizations acknowledged, held-out shrinkage negligible,
restart protocol scheduled; why not learn the model — scope: which PHYSICAL
process-model structure inside a consistency-audited filter; learned dynamics
have no covariance story without extra machinery.

## 5. Where things live now (Code repo restructure 2026-06-11)

- root: `runEstimationConvergence.m` (held-out sweep; SEM stop, GateVx=2)
- `+analysis/` (MATLAB namespace, call as `analysis.<fn>`): `compute_case_metrics`,
  `compute_binned_squared_error`, `plot_convergence_results` (figures F1–F5 →
  `+analysis/figs_convergence/`), `plot_convergence_partial`, `benchmark_runtime`,
  `plotSobolSurface3D`
- `+utils/`: `utils.runEstimation`, h5 one-offs (`addTrailerIMU`,
  `patchManMetricsCaseMeta`, `removeArticulationAngleFromExperiments`)
- `+tuning/`: tuning harness (`tuning.tune_campaign`, runners, smoke/verify/compile
  scripts) + untracked run logs/.mat winners (notes/ retired). Batch invocation:
  `matlab -batch "addpath('...\Code'); tuning.<script>"` — `run('path')` does not
  work on namespaced scripts.
- `VTM_CouplingForce/`: wasm generation backend (single source) + pinned
  train recipe
- Compile times (logged): FS 72.2 s / DAE 9.4 s / Lag 9.2 s MEX (~3.1 min all
  three) — inversion narrative: the simplest formulation is the most expensive
  to compile. Sweep wall-times (contention-biased, RELATIVE only): FS 915 /
  DAE 813 / Lag 795 µs/step median; absolute numbers from `analysis/benchmark_runtime.m`
  on an idle machine (contribution 2).
