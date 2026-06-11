# NOTE for the paper-writing agent — verification of the runtime-solve DAE estimator

> **RECONCILIATION (2026-06-07) — superseded in places by `NOTE_independent_verification_for_results.md` (CANONICAL for the corrected numbers).** An independent adversarial pass re-derived every number and corrects three items below:
> 1. **Per-step:** "DAE faster per step than Lagrangian at equal n" (§4/§5) holds only vs the *symbolic* Lagrangian. Vs the reduced-numeric Lagrangian (4×4 solved online) per-step is a **wash — reduced marginally faster** (1.907 vs 1.994 µs isolated). Do not claim augmented-beats-reduced.
> 2. **Conditioning:** "worst cond ≈1.9×10⁵" (§3) is the *nominal-mass* value; across the realistic mass range worst ≈4.5×10⁵ (still safe, never singular).
> 3. **Accuracy/consistency:** "pending matched tuning" (§4) is sharpened — the independent pass found FakeSpring has **lower Fc RMSE in most maneuvers** and the DAE/Lagrangian post-hoc Fc covariance is **wildly over-confident (NEES 10³–10⁵ vs ≈1)**. The damper's measurement-correctable Fc is its real, defensible edge.
>
> Use THIS note for the method/checks; use the independent note for the corrected per-step / conditioning / accuracy verdict.

**Purpose.** Records *exactly* what was done to verify that the compiled
FakeSpring_DAE estimator (Option C: runtime numeric 6×6 solve) is (a) genuinely
the coupling DAE, (b) a faithful implementation of the intended algebra,
(c) numerically well-posed including at jackknife, and (d) real-time feasible.
All checks were run on MATLAB R2025b / MSVC 2022 / this machine, against the
`muse.Experiment` `.h5` datasets under `Code/experiments/`. Scripts and diaries
live in `Code/notes/` (`verifyDAE.m`, `jackknifeCond.m`, `threeWay.m`, plus the
`*.log` next to each).

This is the foundation that overturns the earlier working premise that the DAE
is infeasible to apply in real time. That premise held only for *symbolic
elimination* of the algebraic system; it does not survive a runtime numeric
solve. See companion `NOTE_compile_cost_for_section7.md`.

---

## 0. What the DAE estimator is (so the checks are meaningful)

The coupling force `Fc = [cfx, cfy]` is kept as an **explicit algebraic unknown**
and solved *in* the system each step. The compiled prediction
(`Pred_9828C3CF_5D1A9191.m`) assembles a **6×6** linear system
`A(x,u,p)·sol = b(x,u,p)` with unknowns
`sol = [a1x, a1y, ω̇z1, ω̇z2, Fcx, Fcy]` and solves it with `sol = A\b` at
runtime (one `mldivide` per evaluation), then Euler-integrates the four
accelerations. This is the methodological distinction from the Lagrangian, which
*eliminates* `Fc` in minimal coordinates (4×4) and recovers it post-hoc.

---

## 1. Structural check — it is a genuine 6×6 runtime DAE solve

Direct read of the generated `Pred_9828C3CF_5D1A9191.m`:
- `Amat = reshape([...],[6,6])`; wrapper does `sol = Amat \ bvec` — a real 6×6
  system solved numerically at runtime, not a baked-in inverse.
- `Amat`/`bvec` are built from `(x,u,p)` **only**; the `sol` placeholders appear
  *exclusively* in the integration step. ⇒ the system is **linear in the
  unknowns**: one fixed linear solve per step, *not* a Newton iteration. This is
  the key reason the general nonlinear-DAE-KF cost argument does not apply here.
- The DAE's compiled hash `9828C3CF_5D1A9191` is **distinct** from the
  Lagrangian's `2F4F7449_…`; separate binaries — rules out a cache alias.

Numerically reconfirmed in `verifyDAE.log`: `A` is 6×6, `b` is 6×1, 6 unknowns,
and "solve placeholders present in A or b? **0**" (linear, as claimed).

## 2. Check 4 — the runtime solve equals the intended elimination

`verifyDAE.m`. An independent symbolic `A\b` was built here via `matlabFunction`
(symbols remapped to clean ordered placeholders, same arg order as the MEX) and
compared against the **compiled** prediction MEX over 200 arbitrary
physically-scaled points (back out the MEX accelerations, compare to the fresh
solve):

> **max | MEX acceleration − independent symbolic A\b | = 3.18 × 10⁻¹²**  → PASS

So the compiled codegen toolchain faithfully implements the intended algebra to
round-off; the agreement is not coincidental and not an aliased binary.

## 3. Checks 3 & 5 — conditioning, including jackknife

`jackknifeCond.m`. First, an **asserted structural fact**: `symvar(A)` contains
**no** state other than the articulation angle `tz12` — A depends solely on
articulation and the fixed inertial/geometric params (`m1,m2,Jz1,Jz2,
L_CoG_1,L_CoG_2`). Velocities and yaw rates enter only `b`. Hence conditioning
is a **1-D function of articulation**; transient severity cannot affect
invertibility.

Sweep over the full ±180° with **real inertias** (m = [9919, 20452] kg,
Jz = [44043, 231039] kg·m²):

| articulation | 0° | ±30° | ±60° | ±90° | worst (−164.5°) |
|---|---|---|---|---|---|
| `rcond(A)` | 4.40e−6 | 4.36e−6 | 5.66e−6 | 7.17e−6 | 4.21e−6 |

- **0 / 721** points below 10⁻¹² — never singular. Worst `cond(A) ≈ 1.9×10⁵`
  (loses ~5–6 of 16 digits; safe in double precision).
- Conditioning is **flat-to-improving** with articulation: better at ±90° than
  upright. **The jackknife regime is not where A degrades.** The worst point is
  past any mechanically possible articulation.
- Conditioning is dominated by mass-row scaling (~10⁴ vs ~1 constraint rows),
  not articulation — trivially improvable by row-equilibration if ever needed,
  unnecessary at cond ~10⁵.
- On the real `brake_turn` trajectory (articulation 0.3–0.7°), `rcond ≈ 4.4×10⁻⁶`
  throughout — so the M432 kg `brake_turn` divergence (§4) is **not** a
  conditioning failure.

## 4. Stage B — equivalence, per-step cost, compile cost (3 cases × 5 maneuvers)

`threeWay.m`, FakeSpring vs FakeSpring_DAE vs Lagrangian, RMSE on the five
targets vs truth + filter-loop timing. (`threeWay.log`.)

**Equivalence (capstone).** In **14 of 15** cases the DAE and the independently
derived Lagrangian agree on the coupling force to
**max|Δ| ~ 10⁻¹¹ N (relative ~10⁻¹⁵)** — i.e. identical physics. The DAE solving
the 6×6 for `Fc` and Kane eliminating `Fc` give the same answer, as they must.

**Per-step cost (refutes the "infeasible online" premise).** Filter-loop
real-time factors, consistent across all cases:

| model | states / sigma pts | real-time factor |
|---|---|---|
| FakeSpring | 11 / 23 | 39–58× |
| **FakeSpring_DAE** | 9 / 19 | **46–60×** |
| Lagrangian (symbolic) | 9 / 19 | 27–32× |

At **equal n = 9**, the runtime-solve DAE ran **~1.7–1.9× faster** than the
*symbolic* Lagrangian. But that gap was an **implementation** artifact: applying
the same Option-C reduction to the Lagrangian (4×4 `M\F` solved online; clean
compile 1481.9 s → **46.3 s**, estimates identical to ≤10⁻¹¹ N) raised it to
**44–54×**, the **same speed class** as the DAE's **46–60×**. So once both solve
numerically, the per-step 6×6-vs-4×4 difference is lost in UKF overhead —
**neither per-step nor compile cost discriminates the two formulations.** (See
`lagReduce.m` / `lagReduce.log`; companion `NOTE_compile_cost_for_section7.md`.)

**Compile cost (measured fresh).** Lagrangian clean rebuild **1481.9 s ≈ 24.7
min**; FakeSpring 35.2 s; DAE 1.2 s (cache) / 44 s (clean). Corroborates
`NOTE_compile_cost_for_section7.md`.

**Outlier — `brake_turn` Case002 (M432 kg).** DAE and Lagrangian diverge
(rel 1.33); both filters actually diverge on this extreme ultralight Sobol
sample under hard braking and then take different unstable paths. Not
DAE-specific; not conditioning (§3). **Confirmed not an implementation artifact:**
the *reduced* (runtime-solve) Lagrangian still diverges from the DAE here
(rel 1.63) and even differs slightly from the *symbolic* Lagrangian — the
hallmark of a filter diverging in an ill-posed regime, where roundoff between
`A\b` variants amplifies into different unstable trajectories for every numerical
variant. Flag for Phase-2 root cause (matches the prior "Lagrangian brake_turn
cfy divergence" note).

**Accuracy — PRELIMINARY, not yet apples-to-apples.** RMSE differences between
FakeSpring and the DAE/Lagrangian are mixed and maneuver-dependent (FakeSpring
tends lower coupling-force RMSE in uphill; DAE/Lag better on cfy in
high-lateral-excitation cases). This is **confounded**: the three models use
different `prep_uncertainties` tunings, and FakeSpring uniquely carries
`cfx,cfy` as states with a measurement update. A defensible accuracy verdict
requires matched tuning (Phase 2). Do **not** draw accuracy conclusions from
Stage B yet.

---

## 5. Verification scorecard

| Claim about the DAE estimator | Status | Evidence |
|---|---|---|
| Genuine 6×6 algebraic solve, `Fc` explicit unknown | ✓ | §1 source read + `verifyDAE.log` |
| Linear in the unknowns (one solve/step, no Newton) | ✓ | §1 (A,b free of `sol`) |
| Runtime solve = intended symbolic elimination | ✓ | §2 (3×10⁻¹²) |
| Distinct binary (not a Lagrangian alias) | ✓ | §1 (hashes differ) |
| Equivalent to an independent formulation | ✓ | §4 (10⁻¹¹ N, 14/15) |
| Well-conditioned incl. full ±180° / jackknife | ✓ | §3 (cond ≤ 1.9×10⁵, 0 singular) |
| Real-time feasible per step | ✓ | §4 (46–60×; **same speed class** as the reduced Lagrangian — reduced 4×4 marginally faster, see independent note §2) |
| Accuracy vs the other models | ⏳ pending | needs matched tuning (Phase 2) |

**Bottom line for the paper.** The runtime-solve DAE is verified correct,
numerically sound across the full articulation range (jackknife included), and
real-time feasible — faster per step than the symbolic Lagrangian at equal state
dimension. The earlier "DAE infeasible in real time" position is not supportable
once the algebraic system is solved numerically rather than eliminated
symbolically. The honest remaining distinctions between the formulations are
structural (6×6 saddle-point with explicit `Fc` vs 4×4 SPD minimal-coordinate;
measurement-updatable `Fc` in FakeSpring) and, potentially, embedded
certifiability — not per-step or compile cost.

## Caveats / open items
- Accuracy comparison pending matched tuning (Phase 2).
- `brake_turn` M432 kg divergence pending root cause.
- Check-5 real-mass conditioning used the nominal vehicle params; extreme Sobol
  masses (e.g. 432 kg) are a separate regime and were not swept for conditioning.
- Per-step numbers are filter-loop wall time on this machine. The fair
  runtime-solve-vs-runtime-solve comparison (6×6 vs 4×4) is now done (§4); an
  isolated per-step microbenchmark (Stage C — time the `Pred`/`Update` MEX in
  isolation, warm, many reps) would refine it but is not required for the
  conclusion.
