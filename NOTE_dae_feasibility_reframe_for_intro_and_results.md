# NOTE — DAE-feasibility reframe: from "trade-off / damper-enables-feasibility" to "comparison + inverted assumption" (Intro contributions, §II Related Work, §VII Results)

**Date:** 2026-06-07. Companion to `NOTE_compile_cost_for_section7.md` (the measured-evidence note). This note is the *narrative/contribution* reframe that the compile-cost numbers force.

---

## 0. The finding, in one paragraph

The augmented constraint-differentiation DAE — coupling force + accelerations as unknowns in a
fixed 6×6 linear system, **solved numerically each step** ("Option C") — is feasible and
accurate, and **cheapest to compile by a wide margin** (44 s vs ~25 min). It matches the
Lagrangian to 4 sig figs (mathematically equivalent). The "DAE is real-time-impractical" premise
— which currently motivates the damper formulation in the paper — does not hold. It conflated
**symbolic elimination of the constraint** (genuinely intractable: ~230 k-char expressions) with
**solving the constraint** (a microsecond per-step `A\b`). The paper's compile-cost / feasibility
narrative must invert.

**HOLD (per Axel, 2026-06-07) — the per-step "augmented beats reduced / minimum-order ≠
minimum-cost" claim is NOT apples-to-apples yet and is withdrawn pending measurement.** The
measured per-step ranking (6×6 < FakeSpring < Lagrangian-4×4) compares the augmented form solved
**numerically** against the reduced 4×4 solved by **symbolic inversion** (the 221 k-char bake).
That gap overwhelmingly reflects *symbolic vs numeric*, not *augmented vs reduced*. The honest
supported claim is narrower: **symbolic elimination (of either form) is the cost driver; solving
numerically is cheap.** Whether the augmented 6×6 or the reduced 4×4 is faster *per step when both
are solved numerically* is untested — see §2 contribution 3 and the fourth-cell note in §5.

## 1. What in the current `coupling_ieee.tex` this contradicts (line-referenced — surgical targets)

- **§II Related Work, line 82** (constraint-differentiation paragraph): *"Coupling force
  components appear as unknowns in an augmented linear system that must be solved at each time
  step. Although the mass matrix is constant, the resulting coupling force expressions tend to be
  large, limiting real-time practicality."* — **This is the falsified claim.** The largeness is
  only of the *symbolically eliminated* expression; solved numerically the per-step cost is
  negligible and in fact the lowest of the three. Rewrite to: this approach is real-time-feasible
  and, in our measurements, the most efficient — provided the augmented system is solved
  numerically rather than eliminated in closed form.
- **§I contribution 2, line 67** ("Quantified Computational Advantage" of the damper over the
  Lagrangian): the directional claim ("structurally simpler EoM … reducing per-step cost") is
  undercut — the DAE the paper sidelines beats the damper. Contribution 2 must change from
  "the damper is computationally advantageous" to "a computational characterization across all
  three, with an inverted conclusion."
- **§I Intro framing, line 61**: *"the … DAE system, posing significant challenges for standard
  nonlinear filters … We address this gap by proposing a damper-based coupling formulation …"* —
  the "challenge" was overstated. Reframe: the DAE is tractable three different ways; the
  contribution is the comparison and the structural distinctions, not rescue-from-infeasibility.
- **§IV, line 424** (Lagrangian mass-matrix inversion as "the source of higher per-step and
  compilation cost"): still true *relative to the damper for the eliminated form*, but the
  framing must not imply the DAE/augmented route inherits that cost — it doesn't.
- **§VI Evaluation, line 614 / §VII Results**: the computational section currently set up to
  "demonstrate the benefits of the damper-based formulation" must become a three-way
  characterization.

## 2. Reframed contributions (drop-in replacement for the Intro list)

1. **First direct comparison of three real-time-feasible coupling-force estimation formulations**
   within one UKF framework, on common large-scale simulation and real-world data: (i) damper
   ODE with `c_fx,c_fy` as states; (ii) augmented constraint-differentiation DAE solved per step;
   (iii) minimal-coordinate Lagrangian (Kane) with post-hoc force recovery. This comparison was
   previously obstructed by the assumed infeasibility / symbolic-elimination compile cost; we
   remove that obstruction and report the comparison.
2. **Damper-based coupling formulation (retained, reframed structurally).** Coupling force as an
   explicitly propagated, **measurement-correctable** state with a constant block-diagonal mass
   matrix and no stiff-spring oscillation. The value is *estimation structure* (Fc carried as a
   state, candidate for direct measurement fusion; singularity-free) — **not** a feasibility
   enabler. [Honesty caveat: the UKF output transform gives Fc a covariance in *all* three, so
   "correctability" is the genuine distinction only if a direct Fc measurement is available, or if
   the conditioning/robustness result (§4) gives the damper a real edge. State this plainly.]
3. **Computational characterization along the symbolic-vs-numeric axis (supported claim only).**
   The cost driver is **symbolic elimination vs numeric solve**, not augmented vs reduced.
   Closed-form elimination of the coupled algebraic system — whether augmented (231 k chars) or
   reduced/minimal-coordinate (221 k chars) — blows up and dominates both compile and per-step
   cost. Solving the system numerically each step makes it cheap. The long-assumed-impractical
   constraint-differentiation (augmented) route, solved numerically, compiles in seconds and
   filters in real time — refuting the feasibility premise. **Do NOT claim "augmented beats
   reduced" or "minimum-order ≠ minimum-cost"**: the current per-step numbers compare
   augmented-numeric against reduced-symbolic and are confounded (see §0 HOLD). The reduced form
   solved *numerically* (Ghandriz-style implicit 4×4, or our Lagrangian with the 4×4 solved at
   runtime) is plausibly competitive or faster and is **untested** — it is the apples-to-apples
   cell needed before any augmented-vs-reduced per-step claim.

## 3. Why it was missed — grounding (extension, NOT refutation of Jacobson's group)

The departmental lineage (Ghandriz, Jacobson et al., IEEE Access 2020,
`ghandriz_computationally_2020`, already cited at line 80) is built on **minimum-order Lagrangian
models with no Lagrange multipliers**, optimized for MPC / optimal control / CasADi-ACADO, where
minimizing state count is the right objective. That paper states the paradigm explicitly:

> "the reaction forces cannot be directly calculated in the case of a minimum-order system and
> the absence of the Lagrange multipliers. Therefore, their calculation must be performed
> separately by postprocessing the ODE solution."

This is the citable anchor for the *prevailing assumption*. The augmented/descriptor form (the
6×6 with the coupling force as an explicit unknown) is precisely what that tradition is built to
eliminate — so it was never "tried and rejected," it was *designed around*. The infeasibility
intuition is a **domain transfer**: minimum-order is correct for MPC (fewer NLP variables over a
horizon), but in UKF **estimation** a fixed small per-step solve is negligible against
sigma-point overhead, so the justification does not carry. The one symbolic-elimination attempt
producing a 230 k-char monster *felt* like confirmation, but only proved elimination is bad.

**Framing line for the paper:** "We extend the minimal-coordinate modeling tradition of
[Ghandriz] across the control→estimation boundary: the state-count economy essential for
predictive control is unnecessary for recursive filtering, where the augmented constraint solve
is trivially real-time." Complementary, not contradictory — and the Ghandriz line is the
citation documenting the assumption we revise.

## 3b. Positioning vs the conference paper (self-correction = novelty, not retraction)

Frame the journal work as **deepening and correcting a preliminary result**, NOT as "the
conference paper was wrong." Recommended language: *"the conference paper proposed the damper
formulation under the prevailing assumption that the coupling DAE is real-time-infeasible; here we
test that assumption directly, find it does not hold once the algebraic system is solved
numerically rather than eliminated symbolically, and accordingly reframe the comparison."*
Self-correction framed as scientific progress reads as science working, not a retraction — it is a
credibility gain, and it decisively clears the "substantial new contribution beyond the conference
version" bar for the journal extension.

## 4. Vocabulary bridge (for §II / §IV): augmented vs reduced = descriptor vs Kane = 6×6 vs Schur

- **Augmented / descriptor (KKT) form** = 6×6, unknowns `[a1x,a1y,ẇz1,ẇz2,Fcx,Fcy]`, coupling
  force as a multiplier-like unknown. Simple per-entry expressions; cheap numeric `A\b`. = our DAE.
- **Reduced / embedded form** = 4×4 acceleration solve, coupling force eliminated and recovered
  post-hoc. = the Lagrangian/Kane baseline.
- The reduced system **is the Schur complement** of the augmented one. **Kane's method derives it
  directly** (generalized speeds / partial velocities) without forming the augmented system —
  same object, two communities' vocabularies. This dual vocabulary is the mechanism of the blind
  spot: the "just solve it per step" view lives in multibody-simulation/DAE-integrator work;
  the vehicle-dynamics group works in the reduced/Kane vocabulary where the solve is hidden inside
  symbolic reduction. Naming both, and bridging them, is part of the contribution.
- **Reviewer-defense (important):** the augmented descriptor solve is *textbook* in multibody
  *simulation*. Do NOT claim "we discovered you can solve a DAE numerically." Claim: the
  estimation context + correcting the imported infeasibility assumption + the enabled three-way
  comparison + the inverted computational verdict.

## 5. What actually distinguishes the three now (UPDATED 2026-06-07 — independent verification)

Most axes have collapsed to "equivalent." The one surviving real distinction is **coupling-force
estimation quality**, and it favors the damper. Canonical evidence:
`NOTE_independent_verification_for_results.md`.

- **Compile cost:** settled — numeric solve >> symbolic elimination (implementation strategy, not
  formulation).
- **Per-step cost:** SETTLED — a wash; the reduced 4×4 is marginally *faster* (1.907 vs 1.994 µs,
  isolated microbench). The fourth cell was built and measured. NOT a discriminator. Do not claim
  augmented-beats-reduced.
- **Conditioning:** SETTLED and NOT a discriminator. `A` depends on the articulation angle ONLY
  (velocities/rates enter `b`); well-conditioned over the full ±180° for every realistic mass
  (worst cond ≈4.5×10⁵, never singular). The earlier "damper is immune at jackknife, the exact
  forms fail" prediction is **FALSIFIED** — neither exact-constraint form degrades in any reachable
  configuration. Drop conditioning as the damper's edge.
- **Fc accuracy (MEASURED, provisional):** FakeSpring has *lower* coupling-force RMSE than
  DAE/Lagrangian in most maneuvers (cfx: circle 118 vs 447, uphill 394 vs 1565, sine 100 vs 384;
  only brake_turn favours the DAE on cfx, and there its cfy is far worse). PROVISIONAL —
  pre-matched-tuning, so partly a tuning artifact; the matched run confirms or kills it.
- **Fc calibration (MEASURED, structural — the real edge):** DAE/Lagrangian post-hoc Fc covariance
  is wildly over-confident, **NEES 10³–10⁵ vs target ≈1**, because Fc gets no measurement update.
  FakeSpring's Fc NEES (4.5–475) is far better. Structural (post-hoc recovery vs measurement-
  corrected state), so unlikely to be pure tuning → the damper's defensible, measured advantage.
- **Damper's COST to characterize (the honest counterweight):** FakeSpring's coupling accuracy
  depends on a non-physical `d_c`/`k`; DAE/Lagrangian are parameter-free for the coupling. Sweep
  `d_c`/`k` to show the sensitivity.
- **DAE ≡ Lagrangian on RMSE *and* NEES** — the built-in honesty check; passed.

## 6. §VII (Results & Discussion) narrative skeleton — UPDATED to the measured verdict

1. **Computational characterization (MEASURED).** Closed-form elimination (augmented *or* reduced)
   is the cost driver; numeric solve is cheap; the augmented constraint-differentiation route,
   solved numerically, is real-time-feasible — refuting the premise. Per-step is a wash (reduced
   4×4 marginally faster); compile is the clean separator (implementation strategy, not formulation).
2. **Accuracy (MEASURED, provisional).** FakeSpring often *lower* Fc RMSE than DAE/Lagrangian;
   confirm under matched tuning before claiming. DAE≡Lagrangian (sanity).
3. **Conditioning (RESOLVED — not a discriminator).** Articulation-only; well-conditioned full
   ±180°, all masses; never singular. Report as "no formulation has a conditioning disadvantage in
   any reachable configuration." Do NOT frame as the damper's edge.
4. **Calibration / consistency (MEASURED — the headline distinction).** DAE/Lagrangian Fc NEES
   10³–10⁵ (over-confident, structural); FakeSpring far better. The damper's measurement-correctable
   Fc gives usable calibrated uncertainty; the post-hoc forms do not.
5. **Parameter sensitivity (PENDING — sweep).** Damper `d_c`/`k` vs the parameter-free forms — the
   cost side of the damper's calibration advantage.
6. **Discussion → recommendation (no longer branches on conditioning):** the three are
   computationally equivalent (feasibility corrected; per-step + conditioning a wash; only
   compile *strategy* differs). The damper is preferable for **coupling-force estimation quality** —
   decisively on calibrated uncertainty (structural), and on accuracy pending matched tuning.
   DAE/Lagrangian remain valuable as the exact, parameter-free reference and for the non-Fc states,
   but their post-hoc Fc uncertainty is **not deployable** (NEES ~10⁴). CAVEAT: the calibration gap
   may *narrow* once consider-parameter uncertainty propagation is enabled (USKF — see lit-gap
   GAP 5), which inflates the post-hoc Fc covariance toward calibration; currently **blocked by the
   pvec RESHAPE codegen bug**. The consider-ON/OFF ablation quantifies how much of the
   over-confidence is parameter-uncertainty (fixable) vs structural (not).

## 7. Status / caveats

- Compile cost: MEASURED, clean — numeric solve (~44-46 s) << symbolic elimination (~25 min);
  separates *implementation strategy*, not formulation.
- Per-step: CORRECTED 2026-06-07 by the independent microbenchmark. Apples-to-apples (both solved
  numerically, n=9) is a **wash — the reduced 4×4 is marginally FASTER** (1.907 vs 1.994 µs/Pred
  call). The augmented 6×6 is NOT fastest. This **supersedes** the earlier "6×6 per-step < both
  FakeSpring and Lagrangian" line, which was the symbolic-vs-numeric confound. Do not make any
  augmented-beats-reduced per-step claim.
- Accuracy-vs-truth (3-way), conditioning sweep, sensitivity sweeps: NOT yet measured. The final
  §VII verdict (esp. the damper's standing) branches on the conditioning result — do not finalize
  the contribution wording until §5.2 lands.
- Politics: Ghandriz/Jacobson framing is *extension across control→estimation boundary*; the
  Ghandriz quote is the assumption-documenting citation, not a target. Axel talks with Jacobson
  often — keep the language complementary.
- Cross-refs: `NOTE_compile_cost_for_section7.md` (numbers), `Code/notes/` diagnostics, branch
  `option-c-runtime-solve`.
