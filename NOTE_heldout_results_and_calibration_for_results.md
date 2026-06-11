# NOTE: Held-out estimation results + calibration campaign (seed for Results / Method sections)

Status 2026-06-11: INITIAL findings — methodologically final, numerically interim.
All numbers below were produced on the variable-step truth pipeline; the full
sweep reruns on the fixed-step .dll regeneration (+ two new test-only lane-change
maneuvers). Write the section STRUCTURE and qualitative claims now; treat every
number as a placeholder with its final value expected within ~10–20% (the
train→held-out reproduction below justifies that expectation).

Data/figures: `Code/runEstimationConvergence_results.mat` (+`meta`),
`Code/notes/figs_convergence/F1–F5`, regenerate via `Code/notes/plot_convergence_results.m`.
Supervisor briefing with full context: `Code/notes/DISCUSSION_2026-06-11.md`.

---

## 1. What the Method section must establish (all implemented, citable to code)

1. **Joint calibration with model equality.** All three formulations share one
   set of physical uncertainty magnitudes (tire relaxation Cts, rolling
   resistance Crr, axle efficiency, wheel radius R, chassis-to-road tilt
   δ_roll/δ_pitch per body — consider/Schmidt treatment); only the process noise
   Q is per-formulation. Joint CMA-ES (35-D effective), objective = gated
   mean-NRMSE + asymmetric NEES barrier (band [0.5,2], over-confidence weighted
   5× under-confidence), J = Σ per-model. Train set: 28 cases × 3 maneuvers
   (brake_straight, circle_slope, sine) — note this is a PRIMITIVE basis
   (longitudinal, combined lateral+grade, lateral transient).
2. **Held-out evaluation protocol.** Separate pool (5 maneuvers × ~970 cases;
   Sobol-sampled payload 0–15 t, speed ×0.4–1.5, stiffness, CG shift), Monte
   Carlo sampling per maneuver until the relative standard error of each
   state's mean RMSE < 2.5% (stopped at 648 cases/maneuver/model, N=3240).
   Velocity gate |vx1| > 2 m/s on all metrics; the low-speed regime is reported
   separately (below).
3. **Sentence to use verbatim:** "Sampling continued until the relative
   standard error of each state's mean RMSE fell below 2.5%."

## 2. Headline result table (Results section, Table X)

Pooled over 5 maneuvers, 2 divergent brake_turn cases quarantined (§4),
RMSE ± SEM / mean NEES, N = 3238 per model:

| state | FakeSpring (damper) | DAE | Lagrangian |
|---|---|---|---|
| cfx [kN]  | 0.239±0.003 / 0.43 | 0.187±0.002 / 0.20 | 0.180±0.002 / 0.16 |
| cfy [kN]  | 2.21±0.03 / 1.09   | 0.82±0.01 / 0.15   | 0.91±0.01 / 0.13   |
| art [rad] | 0.0196 / 0.56      | 0.0174 / 2.03      | 0.0163 / 1.67      |
| vy1 [m/s] | 0.048 / 1.45       | 0.041 / 0.59       | 0.038 / 0.48       |
| vy2 [m/s] | 0.092 / 0.15       | 0.132 / 0.34       | 0.138 / 0.35       |

Claims this table supports:
- Exact-constraint formulations (DAE/Lag) deliver **2.4–2.7× lower lateral
  coupling-force RMSE** than the damper formulation; longitudinal advantage
  ~1.3×. DAE ≡ Lag in accuracy (consistent with their algebraic equivalence).
- The damper formulation wins trailer lateral velocity (~1.4×) — its finite
  compliance absorbs the kinematic-constraint error that DAE/Lag push into vy2.
- Calibration: no cell severely over-confident (worst ×2.6 over band, see §3);
  DAE/Lag coupling-force covariance is CONSERVATIVE (NEES 0.13–0.20) — state
  this honestly, the cause is identified (untuned mass/inertia/CoG consider
  block) and the final tune should improve it.

## 3. Calibration transfer (the result that makes the tuning section credible)

- FS cfy@sine NEES: train 2.61 → held-out 2.63. Quote this: the violation
  pattern REPRODUCES, not just the averages.
- DAE/Lag articulation: worst cell on **circle (NEES 4.0–5.2) — a maneuver
  class absent from training** — and it lands inside the independently
  documented steady-turn irreducible range. Frame as: held-out evaluation on an
  unseen maneuver class exposes the same structural mismatch identified during
  development, i.e. the tuning did not overfit the violation away.
- Known structural residuals to DECLARE (not hide): DAE/Lag articulation
  over-confidence in steady turning (2–5×); FS lateral-velocity 1 (~3× @sine);
  FS cfy@sine 2.6 = quantified price of the model-equality constraint (FS alone
  tuned to J=0.77; tying σ across models cost FS ~0.7 J to buy DAE/Lag ~156).

## 4. Low-speed subsection — frame as an OPEN PROBLEM, not a damper win

FRAMING DECISION (AC, 2026-06-11): low speed is **unsolved in all three
formulations**; the damper merely REGULARIZES the failure. Do not write
"FS wins at low speed" — FS's own worst case (art NEES 480, cfx 70 kN) is not a
valid estimate either, it is a bounded failure.

The sweep located the material: two brake_turn cases (Case486_M6869kg,
Case585_M6521kg; deceleration to standstill) diverge in ALL three formulations,
with a ~70× severity gap in HOW they fail:

| | FS | DAE | Lag |
|---|---|---|---|
| cfx RMSE (worst case) | 70 kN | 411 kN | 394 kN |
| art case-NEES | 480 | 6.9e3 | 3.4e4 |

Mechanism to write: as |v|→0 the coupling force becomes unobservable /
statically indeterminate from the available measurements. The exact-constraint
forms invert an increasingly ill-conditioned system (6×6 solve / Kane
projection) → unbounded variance. The damper's cf = −d_c·Δv pulls the estimate
toward zero as Δv→0 → **implicit regularization: bounded variance bought with
bias toward zero**. Neither is a solution; they are two failure modes of the
same indeterminacy (bounded-wrong vs unbounded-wrong).

Payoffs of this framing:
- Honest (matches the data — FS also fails the named cases).
- Positions principled low-speed treatment as FUTURE WORK / separate
  contribution: constraint regularization done deliberately (e.g.
  Baumgarte-type stabilization — connects to the §I/II Baumgarte positioning
  pin: the damper is the accidental version of it), covariance inflation, or
  explicit standstill detection/switching.
- The 70× gap remains reportable as a robustness-of-failure-mode property,
  a genuine formulation distinction (independently verified in the DAE
  feasibility study), without overclaiming validity.

Planned: ungated (GateVx=0) runs on the named cases + low-speed neighbors for
the dedicated figure; show estimate AND reported covariance through the
standstill so the bias-vs-variance trade is visible per formulation.

## 5. Computational cost (contribution 2 — §VII)

- Compile (cold cache, current config): FS 72.2 s / DAE 9.4 s / Lag 9.2 s MEX;
  ~3.1 min all-in for all three. Inversion worth one sentence: the conceptually
  simplest formulation (damper) is the most expensive to compile (2 extra
  states inflate codegen); the Lagrangian's symbolic complexity is front-loaded
  into derivation, not the generated code.
- Per-step (PENDING `benchmark_runtime` on idle machine — do not quote sweep
  medians as absolute): sweep-relative ordering FS > DAE ≈ Lag
  (915/813/795 µs/step under 24-worker contention; relative use only).
- DAE caveat to state: its coupling-force recovery runs uncompiled
  ('output-none' codegen) — per-step comparison must include the output pass
  (FS pays its Fc cost inside the filter loop; DAE/Lag pay post-hoc).

## 6. Claims discipline (what NOT to write)

- Do NOT claim generalization to arbitrary unseen maneuvers. Supported claim:
  transfers across cases/noise realizations and to maneuver classes COMPOSED OF
  TRAINED REGIMES (circle was unseen; its regimes were not). The upcoming
  test-only lane changes (ISO 14791-style single + double, frequency-shifted
  from the training sine) strengthen this to near the defensible maximum.
- Do NOT quote formal chi-square NEES band membership without an N_eff
  (autocorrelation) correction — quote mean NEES per cell instead.
- Single CMA run so far; restart protocol (2–3 perturbed) scheduled before
  final numbers. Winner-of-290 on frozen noise realizations → mild optimism
  bias; the held-out shrinkage observed was negligible (quote §3).
- All results are simulation (VTM truth). Winter2022 real-data set exists but
  is unused — scope decision pending with supervisors.

## 7. Planned before final numbers (affects which sentences are safe to draft)

1. .dll fixed-step regeneration (+ lane changes) → rerun sweep. SAFE to draft:
   structure, claims of §2–§4 directionally. UNSAFE: exact numbers.
2. Consider-block re-anchor (m/Jz/L_CoG causal) + restart-protocol retune →
   expect DAE/Lag cfx/cfy NEES to move from ~0.15 toward band; FS largely stable.
3. Ablation none/time-varying/consider (designed: `Code/notes/ablation_design.md`)
   → its own subsection: "consider costs X µs/step and buys NEES ~160→~1";
   predictions pre-registered from the development record, write in
   falsification style.
4. Per-step benchmark (idle machine) → fills §5 placeholder.
