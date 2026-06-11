# NOTE for the paper-writing agent — INDEPENDENT (adversarial) re-verification of the fast-DAE result

**Date:** 2026-06-07. Companion / second opinion to `NOTE_dae_verification_for_results.md`,
`NOTE_compile_cost_for_section7.md`, and `NOTE_dae_feasibility_reframe_for_intro_and_results.md`.
Produced by a skeptical verification pass whose remit was to **falsify** the claim, re-deriving
every number from primitives rather than trusting the prior agent's logs. It also **closes the two
open items** those notes left (extreme-mass conditioning; isolated per-step microbenchmark) and
**flags the per-step wording** that is now contradicted by measurement.

Harness + diary: `Code/notes/indepVerify.m` / `indepVerify.log` (this session). Environment:
MATLAB R2025b, MSVC, Win64, branch `option-c-runtime-solve` (dirty; reduced-Lagrangian MEX
`…B4073161` built from the uncommitted `Lagrangian.m`). No tracked source was modified by the
verification.

---

## 0. Bottom line

The fast-DAE result **holds**. The runtime-solve DAE is a genuine 6×6 numeric `mldivide` — a
distinct binary, linear in its unknowns, faithful to an independent symbolic solve to round-off,
well-conditioned across the full articulation range for every realistic mass, exactly equivalent
to the Lagrangian on coupling force and on **both** RMSE and NEES, and real-time feasible. The
"DAE is real-time infeasible" premise does not survive — it conflated *symbolically eliminating*
the constraint with *numerically solving* it.

**One claim fails and must not be made: any per-step "augmented/DAE beats reduced/Lagrangian."**
The apples-to-apples microbenchmark (both solved numerically, n = 9) is a **wash**, with the
reduced 4×4 marginally *faster*. **Two honest deflations** the §VII narrative must own: (a)
DAE/Lagrangian are frequently *less* accurate on coupling-force RMSE than FakeSpring; (b) the
DAE/Lagrangian post-hoc Fc covariance is wildly over-confident (NEES ~10⁴) and is **not** a usable
calibrated uncertainty.

---

## 1. Verification scorecard (independently re-derived)

| Claim | Verdict | Evidence (this pass) |
|---|---|---|
| Genuine 6×6 runtime `A\b`, `Fc` explicit unknown | **PASS** | source read of `Pred_9828C3CF_5D1A9191.m`: `Amat=reshape([…],[6,6]); sol=Amat\bvec` |
| Linear in unknowns (one solve/step, no Newton) | **PASS** | `symvar([A b])` ∩ unknowns = ∅; model builds `A=jacobian(eqns,unk)`, `b=-subs(eqns,unk,0)` |
| Distinct binary (not a Lagrangian alias) | **PASS** | hash `9828C3CF_5D1A9191` vs Lag `2F4F7449_0BE0BC69` / `9828C3CF_B4073161`; separate `.mexw64` |
| Runtime solve = independent symbolic elimination | **PASS** | max\|MEX − fresh symbolic `A\b`\| = **3.78×10⁻¹⁰** over 300 random physically-scaled pts |
| `A` depends on articulation only | **PASS** | fixed `tz12`, 40 random `(vx,vy,wz,u)` ⇒ rcond spread = **0.00** (bit-identical) |
| Well-conditioned over full ±180°, all masses | **PASS** | 0 singular; min rcond 4.2×10⁻⁶ (nominal); see §3 for the closed extreme-mass sweep |
| DAE ≡ Lagrangian on Fc | **PASS** | max\|Δcfx\| ≤ 9×10⁻¹² N, \|Δcfy\| ≤ 2×10⁻⁶ N (brake_turn) across 5 maneuvers |
| DAE ≡ Lagrangian on RMSE **and** NEES | **PASS** | identical to 4 sig figs (RMSE) and identical (NEES) in all 5 cases |
| Per-step augmented (6×6) faster than reduced (4×4) | **FAIL / WASH** | DAE **1.994 µs** vs reduced-Lag **1.907 µs** per Pred call (~4%); reduced marginally faster |
| Compile: runtime-solve ≪ symbolic elimination | **PASS** (corroborated, not re-timed) | logs 44 s / 1492 s / 46 s; on-disk Pred source 6 k vs 350 k chars |
| DAE/Lag most accurate on Fc vs truth | **NOT SUPPORTED** | FakeSpring lower cfx RMSE in circle/sine/uphill (see §4) |
| DAE/Lag Fc uncertainty is calibrated | **NOT SUPPORTED** | cfx NEES 10³–10⁵ vs target ≈1 (see §4) |

---

## 2. Per-step cost — the apples-to-apples cell, now measured (closes the §0-HOLD gap)

Isolated warm `timeit` of the scalar `Pred` MEX, **identical** `(x,u,p)`, both n = 9 / 19 sigma
points, both runtime-numeric:

| | per Pred call | pure `mldivide` |
|---|---|---|
| **DAE 6×6 (augmented / descriptor)** | **1.994 µs** | 0.686 µs |
| **Lagrangian 4×4 (reduced, runtime-numeric)** | **1.907 µs** | 0.174 µs |
| difference (6×6 − 4×4) | **0.086 µs (~4 %)** | 0.51 µs marginal |

The reduced 4×4 (`Pred_9828C3CF_B4073161.m`, also `Amat\bvec`) is the fourth cell the prior notes
said was missing. Result: **augmented is not faster — it is ~4 % slower**, and most of the ~2 µs
is the shared tire-model `bvec` assembly, not the solve. Absolute µs include MATLAB interpreter
call overhead (common-mode; the comparison is robust, the absolute is an upper bound).

**What to claim:** per-step cost does **not** discriminate the two formulations once both are
solved numerically; if anything the reduced (Schur-complement) 4×4 is trivially cheaper, as
expected. **What NOT to claim:** "augmented beats reduced," "minimum-order ≠ minimum-cost,"
"DAE is the fastest per step." The earlier "DAE 1.7–1.9× faster" was the symbolic-vs-numeric
artifact, now neutralised by direct measurement.

Compile cost (one-time, indicative, **not** re-timed here): DAE 44 s, symbolic Lagrangian
1492 s ≈ 24.9 min, reduced Lagrangian 46 s — corroborated by the generated-`Pred` source collapse
350 115 → ≈6 000 chars. The compile axis separates *implementation strategy*
(symbolic-elimination vs runtime-solve), not the formulation.

## 3. Conditioning — extreme-mass sweep (closes the open C6 item)

`A` depends on articulation and `{m1,m2,Jz1,Jz2,L_CoG_1,L_CoG_2}` only (proven: rcond invariant to
`(vx,vy,wz,u)` to the bit). Full ±180° sweep, four mass scenarios:

| masses [m1, m2] kg | min rcond | worst cond(A) | singular (<10⁻¹²) |
|---|---|---|---|
| ultralight [300, 200] | 5.0×10⁻⁴ | ~2.0×10³ | 0 / 361 |
| nominal [9919, 20452] | 4.2×10⁻⁶ | ~2.4×10⁵ | 0 / 361 |
| heavy [12000, 35000] | 2.2×10⁻⁶ | ~4.5×10⁵ | 0 / 361 |
| extreme-ratio [15000, 150] | 8.9×10⁻⁶ | ~1.1×10⁵ | 0 / 361 |

**Never singular** over the entire articulation range for any realistic mass. Conditioning is
dominated by mass-row scaling (worsens with heavier mass, best for ultralight), peaking at
≈4.5×10⁵ — i.e. the prior notes' "worst cond ≈1.9×10⁵" is the **nominal-mass** value; across the
realistic mass range the worst is ≈4.5×10⁵, still safe in double precision. This confirms the
`brake_turn` M432 kg divergence is **not** a DAE-solve conditioning failure (ultralight is in fact
the *best*-conditioned case); it is a filter/observability failure shared by DAE and Lagrangian.

**Caveat (state it):** no real trajectory in the dataset exercises large articulation — max
\|tz12\| = **3.26°** (circle_slope), <1° elsewhere. Jackknife well-posedness is established
analytically (rcond ⟂ velocities/rates) + synthetically (±180° sweep), **not** from aggressive
real data. Because conditioning is articulation-only, this is sufficient; do not over-state it as
"validated on jackknife maneuvers."

## 4. Accuracy & consistency — RMSE + NEES (the two deflations)

DAE vs Lagrangian agree to 4 sig figs on RMSE **and** are identical on NEES in every case
(built-in honesty check passes). FakeSpring (n = 11, Fc measurement-updated) legitimately differs
and does **not** diverge on the Case001 maneuvers. Two findings that constrain the §VII verdict:

1. **Coupling-force RMSE — DAE/Lagrangian are often the *worse* models.** cfx RMSE: circle 447
   (DAE/Lag) vs **118** (FakeSpring); uphill 1565 vs **394**; sine 384 vs **100**. Only brake_turn
   favours the DAE on cfx (1063 vs 1626), and there its cfy is far worse (2.39×10⁴ vs 878). Do
   **not** claim the exact-constraint forms are more accurate on the coupling force.
2. **Coupling-force uncertainty — DAE/Lagrangian are wildly over-confident.** mean cfx NEES =
   7.8×10³ (circle), 2.4×10⁴ (sine), 4.5×10⁵ (uphill), 1.4×10⁴ (brake_turn), 2.6×10⁴
   (circle_slope), against the calibrated target ≈1. Fc gets **no** measurement update, so the
   propagated post-hoc output variance underestimates the true error by ~4 orders. FakeSpring's
   cfx NEES (4.5–475) is far better. **The DAE/Lagrangian Fc covariance must not be presented as a
   usable calibrated uncertainty.** State NEES (art ≤ 57, lvy ≤ 5.7 in transients) is mildly
   over-confident and, again, DAE ≡ Lagrangian.

This sharpens the prior notes' "accuracy pending matched tuning": even before retuning, the
consistency picture is unambiguous and is a genuine point *against* the post-hoc-recovery forms on
the uncertainty axis — the damper's measurement-correctable Fc is its real, defensible edge here.

## 5. Overclaims to fix (surgical list)

- **`coupling_ieee.tex:82`** — DAE "limiting real-time practicality": **falsified** (≈2 µs/call,
  40–60× real-time). [Already targeted by `NOTE_dae_feasibility_reframe`.]
- **`coupling_ieee.tex:67, :424, :614`** — damper per-step advantage / Lagrangian "higher
  per-step cost" / "demonstrate the benefits of the damper": the **per-step** direction is
  unsupported once both solve numerically. Reframe to a three-way characterisation.
- **`NOTE_dae_feasibility_reframe_for_intro_and_results.md` §7 (lines 176–177)** — "6×6 per-step <
  both FakeSpring and Lagrangian (MEASURED)": **contradicts its own §0 HOLD and this
  measurement.** Strike it; the 6×6 is not < the reduced 4×4.
- **`NOTE_dae_verification_for_results.md` §4/§5 (lines 107, 152, 157)** — "DAE faster per step
  than [symbolic] Lagrangian at equal n": true only vs the *symbolic* baseline (confounded). Vs
  the reduced-numeric Lagrangian the DAE is marginally slower. Reword to "same speed class; reduced
  4×4 marginally faster."
- **`NOTE_dae_verification_for_results.md` §3** — "worst cond(A) ≈1.9×10⁵": that is the
  nominal-mass value; across realistic masses worst ≈4.5×10⁵ (still safe). Minor.
- For balance — **understatement, not overclaim:** "matches the Lagrangian to 4 significant
  figures" is conservative; the actual agreement is ~10⁻¹¹ N absolute / ~10⁻¹⁵ relative
  (machine precision).

## 6. Status / caveats

- 6×6 identity, linearity, distinctness, independence (3.8×10⁻¹⁰), conditioning (all masses),
  equivalence (Fc, RMSE, NEES), and the isolated per-step microbenchmark: **MEASURED this pass.**
- Compile times: **not** re-run (≈30 min of clean rebuilds); relied on this session's logs +
  corroborating source sizes. Hardware-dependent — report as indicative.
- No real high-articulation/jackknife trajectory exists; conditioning there is analytic +
  synthetic.
- Per-step absolute µs include MATLAB call overhead; the relative (augmented-vs-reduced) result is
  robust to it.
- Technical record: `Code/notes/indepVerify.m` / `indepVerify.log`; cross-refs
  `NOTE_dae_verification_for_results.md`, `NOTE_compile_cost_for_section7.md`,
  `NOTE_dae_feasibility_reframe_for_intro_and_results.md`.
