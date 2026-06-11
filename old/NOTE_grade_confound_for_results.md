# NOTE for the paper-writing agent — a proven result for Results/Discussion

**Finding (proven this session): the road-grade ↔ longitudinal-coupling-force confound on
the `circle_slope` maneuver is a FUNDAMENTAL single-IMU observability limitation, not a
tuning or modeling defect.** This is a positive, citable result — use it; do not present
`circle_slope` coupling-force errors as estimator/formulation performance without this caveat.

## What to claim (supported by data)

- On a turn traversed on a laterally/longitudinally tilted plane, the tractor body pitch
  oscillates at the yaw rate, so the longitudinal gravity projection `g·sin(θ)` is
  time-varying. The longitudinal specific force obeys
  `a_x = v̇_x − (ω×v)_x − g·sin(θ)`, and the coupling force `c_fx` enters through `v̇_x`.
  A single longitudinal accelerometer constrains only the **sum** of grade-gravity and
  coupling force; their split is unobservable.
- Direct evidence: per-case, `corr( c_fx error(t), m·g·sin(θ(t)) ) = 1.000` — the coupling-
  force error IS the unmodeled grade-gravity, time-resolved.
- The estimator's grade term is correct (gravity is projected via the estimated attitude,
  and at truth the attitude kinematics reproduce the pitch evolution exactly, corr 1.000).
  So this is observability, not a model error.
- Contrast that isolates the mechanism: constant grade (`uphill`, pitch std ≈ 0) is
  benign — the DC offset is absorbed into the steady longitudinal/torque equilibrium
  (coupling-force error ≈ 5% of a 6–8 kN gravity load). Only the **AC** (yaw-rate-
  modulated) grade corrupts the coupling force.
- It is **formulation-independent**: the grade enters the shared gravity/kinematic model,
  so the damper, DAE, and Lagrangian formulations are affected identically.

## The figure/table to use (a Pareto trade-off — this is the result)

Sweeping accelerometer trust (per-axis longitudinal `r_{a_x}`, with lateral kept tight so
roll/attitude phase is preserved), on a representative `circle_slope` case:

| accelerometer trust on a_x | pitch amplitude | coupling-force RMSE | coupling-force ANEES |
|---|---|---|---|
| tight (nominal) | frozen (≈5% of true) | large | hugely over-confident (≈10³) |
| loose | still frozen | smaller (plateaus) | less over-confident |

No setting recovers both pitch amplitude and coupling force: tightening the accelerometer
dumps the grade magnitude into the coupling force; loosening it relieves the coupling force
but starves the attitude and discards the coupling force's own longitudinal information.
The grade *phase* is recoverable (from the roll×yaw kinematics); the grade-vs-force
*magnitude split* is not, from IMU + wheel speeds alone.

## How to frame it

- Results: report flat maneuvers (circle, sine, brake_turn) for the coupling-force
  comparison; present `uphill`/`circle_slope` separately as a grade-robustness study, with
  the DC-vs-AC contrast and the corr≈1 evidence.
- Discussion: state the limitation explicitly and that it is intrinsic to the single-IMU
  sensor set, not the proposed damper formulation. Then present the resolution (below).

## Resolution — a trailer accelerometer makes it observable (PROVEN)

A second accelerometer on the trailer adds an independent gravity projection at the
articulation-rotated heading, breaking the tractor pitch↔coupling-force degeneracy.
Demonstrated (synthesized trailer IMU from truth, Case001 `circle_slope`):

| config | coupling-force RMSE | coupling-force ANEES |
|---|---|---|
| single (tractor) IMU | 3527 N | 1014 |
| + trailer accelerometer (realistic noise ≤0.05 m/s²) | ~190–215 N | ~30 |

Coupling-force RMSE drops 16–18×, back to near the flat-maneuver floor (~110 N), and is
robust to realistic accelerometer noise (degrades only above ~0.1 m/s²). Only the trailer
ACCELEROMETER is required. Frame as: the limitation is a single-IMU observability gap, and
adding a low-cost trailer accelerometer recovers coupling-force accuracy on graded turns.

## Status / caveats

- Resolution is PROVEN in simulation with a synthesized (truth-derived) trailer
  accelerometer + injected noise — phrase as "demonstrated in simulation," not validated on
  hardware. Residual ANEES ~30 (optimistic) would improve with a tuned trailer-channel R.
- Numbers are from the `FakeSpring` (damper) model, Case001-class `circle_slope`.
- Full technical record + reproduction: `Code/notes/grade_coupling_confound.md` §7b.
