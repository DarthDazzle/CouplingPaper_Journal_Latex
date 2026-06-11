# MASTER — consolidated paper change & addition plan

**Date:** 2026-06-07. Single entry point that condenses all the session notes into "what to CHANGE"
and "what to ADD" in `coupling_ieee.tex`. Detailed evidence lives in the per-topic notes; this is
the index + plan. **Status pending the final matched-tuning + convergence run** — items tagged
[MEASURED], [PROVISIONAL] (confirm with matched tuning), or [PENDING].

Active source notes (this folder): `NOTE_independent_verification_for_results.md` (CANONICAL for
verification numbers), `NOTE_dae_feasibility_reframe_for_intro_and_results.md` (§-by-§ change detail),
`NOTE_literature_gaps_for_relatedwork.md` (citations), and the pre-existing `REVIEW_TODO.md`.
(The grade artifact is a resolved truth-gen bug, not a result — see PART C4; the stale
`NOTE_grade_confound_for_results.md` is archived in `old/`.)
Archived (`old/`, superseded — numbers folded into the canonical notes above):
`old/NOTE_dae_verification_for_results.md` (agent 1, superseded by the independent pass),
`old/NOTE_compile_cost_for_section7.md` (compile/per-step detail, now in §2 of the independent note
and PART C1 here).

---

## 0. The story in five lines (what the session established)

1. The "coupling DAE is real-time infeasible" premise — the paper's current motivation — is **wrong**.
   It conflated *symbolically eliminating* the constraint (intractable) with *numerically solving*
   it per step (microseconds). [MEASURED, independently verified.]
2. Solved numerically, **DAE ≡ Lagrangian** (Fc, RMSE, NEES, to machine precision) and per-step cost
   is a **wash** (reduced 4×4 marginally faster). No formulation wins on speed/compile/conditioning.
3. The **damper's real, surviving edge is estimation quality**: its measurement-correctable Fc gives
   far better-calibrated coupling-force uncertainty (NEES) [MEASURED, structural] and lower Fc RMSE
   on flat maneuvers [PROVISIONAL — matched tuning].
4. Several "novel" methods are established and just need citing (constrained-estimation taxonomy;
   consider/Schmidt-Kalman; unscented output transform).
5. A grade↔coupling-force artifact on graded maneuvers was traced to **two truth-generation bugs in
   VTMLibrary** (quaternion convention + force-export frame), now fixed and experiments regenerated.
   It was **NOT** an observability limit; graded results are valid post-fix and the earlier
   observability / trailer-accelerometer framing is dead. [RESOLVED 2026-06-06]

The paper's reason to exist survives; its **headline moves from feasibility/speed to a comparison +
correction + an estimation-quality result.** Frame vs the conference paper as *deepening and
correcting a preliminary result*, not a retraction.

> **UPDATE 2026-06-11 — matched tuning + held-out sweep DONE; item 3 partially REVERSED.**
> See `NOTE_heldout_results_and_calibration_for_results.md` (new canonical for Results/Method
> numbers; interim pending .dll regeneration). With matched joint tuning (model-equality σ,
> per-model Q) on 648 held-out cases/maneuver: the damper does NOT have lower Fc RMSE —
> **DAE/Lag win cfy by 2.4–2.7× and cfx by ~1.3×**; the damper's surviving edges are trailer
> lateral velocity (~1.4×) and near-unity cfy NEES (1.09 vs DAE/Lag over-conservative 0.13–0.20,
> cause identified and fixable). **Low speed (AC framing decision): an OPEN PROBLEM in all
> three formulations, not a damper win** — at standstill Fc is unobservable; exact-constraint
> forms fail unboundedly (ill-conditioned solve), the damper fails boundedly (cf=−d_c·Δv is
> implicit regularization: bias-to-zero instead of variance blow-up; its own worst case
> NEES 480 is also invalid). ~70× severity gap reportable as failure-MODE distinction;
> principled treatment (deliberate regularization, e.g. Baumgarte-type) = future work.
> The measurement-correctable-Fc framing survives via calibration, not RMSE.
>
> **TERMINOLOGY DECISION (AC, 2026-06-11): stop calling the 6×6 model "a DAE".** None of the
> three estimators integrates a DAE; the underlying constrained system is the DAE (index 3,
> index 1 at acceleration level), and the three models are the three CLASSICAL reductions of
> it to ODE form: (1) **multiplier/augmented** (per-step 6×6 solve; the model code-named
> FakeSpring_DAE), (2) **embedding/projection** (Kane, minimal coordinates — same algebra done
> symbolically, hence ≡ to machine precision), (3) **penalty/compliance** (the damper —
> regularized constraint, never exactly enforced). Use these names in the paper; code names
> stay out. Payoffs: the conference error becomes a terminology clarification (symbolic vs
> pointwise elimination); the comparison becomes the canonical multibody taxonomy (cite
> Baumgarte 1972; Laulusa & Bauchau 2008; García de Jalón & Bayo — ties to
> NOTE_literature_gaps); the low-speed open-problem framing (D2) lands on textbook ground
> (Baumgarte stabilization is the standard remedy for acceleration-level enforcement; the
> penalty form is its accidental cousin).

---

## PART A — CHANGES (corrections to existing claims)

### §I Introduction — contributions (l.61–67)
- **CHANGE the motivating premise (l.61):** the DAE is not a "significant challenge … infeasible"
  one. Reframe: the DAE is tractable three ways; the contribution is the comparison + the
  feasibility correction, not rescue-from-infeasibility. [MEASURED]
- **REWRITE contribution 2 (l.67, "Quantified Computational Advantage"):** the damper does NOT have a
  per-step advantage. Recast as a *three-way computational characterization* whose finding is:
  numeric solve is cheap for all; per-step is a wash; only compile *strategy* differs. [MEASURED]
- **REFRAME contribution 1 (damper, l.65):** keep the formulation, but its value is **structural**
  (Fc as a measurement-correctable state → better-calibrated coupling-force uncertainty), not
  feasibility. [MEASURED for calibration]
- **ADD a contribution:** first direct three-way comparison (penalty/projection/reduction =
  damper/DAE/Lagrangian) of coupling-force estimation, enabled for the first time by the
  numeric-solve DAE.
- **DEMOTE to cited methodology (not contributions):** parameter-uncertainty propagation and output
  uncertainty — see PART B / GAP 5.

### §II Related Work
- **CHANGE l.81–82 (constraint-differentiation):** the claim that the augmented linear system's
  "coupling force expressions tend to be large, limiting real-time practicality" is **FALSIFIED**
  (≈2 µs/call, 40–60× real-time). Flip to: real-time feasible, and the most efficient route *when
  solved numerically rather than eliminated symbolically*. [MEASURED] (Also REVIEW_TODO flags this
  paragraph as thin — fix content + add grounding, see PART B GAP 2.)
- Keep Ghandriz framing as *extension across the control→estimation boundary*, not refutation.

### §IV Modeling
- **CHANGE l.424 (Lagrangian mass-matrix inversion = "source of higher per-step and compile cost"):**
  true only for the *symbolic* inversion; the reduced 4×4 solved *numerically* is the same speed
  class as the DAE. Reframe as implementation strategy (symbolic vs numeric), not formulation. [MEASURED]
- **Foundation-1 (REVIEW_TODO):** reconsider "rigid damper" naming — `d_c` is a tuned regularization,
  not rigid. Now extra-motivated: the damper's value is calibrated Fc, not rigidity. Add the stability
  paragraph (`dt < 2m/d_c`).
- **Foundation-2 (REVIEW_TODO):** the velocity-only penalty = Baumgarte with position gain 0 — connect
  to the constrained-estimation taxonomy (PART B GAP 1): damper = penalty enforcement.

### §V Estimation Framework
- §V-D already frames augmented params correctly as *static consider parameters propagated via sigma
  points* (REVIEW_TODO §V-11 RESOLVED). Just **cite** the method (PART B GAP 5) and demote from novelty.

### §VI / §VII Evaluation & Results
- **CHANGE the computational benchmark framing (REVIEW_TODO item 2):** the promised "damper vs
  Lagrangian per-step + compile" table becomes a *three-way characterization*; report per-step as a
  wash and compile as the implementation-strategy separator. [MEASURED]
- **Graded maneuvers are VALID — do NOT split them out** (corrected 2026-06-07). The earlier "grade
  confound" was two VTMLibrary truth-gen bugs (now fixed; experiments regenerated), not an
  observability limit. uphill/circle_slope can be used in the coupling-force comparison like any flat
  maneuver. Supersedes the prior recommendation to present them as a separate grade-robustness study —
  that result no longer exists. See PART C4.
- **RESOLVE the NEES-thread decision (REVIEW_TODO §5b):** KEEP ANEES — it is no longer vestigial; the
  coupling-force NEES is the headline distinction (damper calibrated, DAE/Lagrangian post-hoc
  over-confident by ~4 orders). [MEASURED]

---

## PART B — ADDITIONS (new content + citations). Full cites + URLs in `NOTE_literature_gaps_for_relatedwork.md`.

- **GAP 1 (framing spine, HIGH) — constrained state estimation.** Add a §II paragraph casting the
  three formulations as penalty / projection / model-reduction in the constrained-KF taxonomy. Cite
  **Simon 2010 survey** + **Teixeira et al. 2009** (projected/measurement-augmentation UKF). Bridge
  via the Jeong constrained-model paper you already hold. Answers "why these three?" up front.
- **GAP 2 — augmented-vs-reduced MBD grounding.** Cite **Bayo & Ledesma 1996** (augmented Lagrangian)
  + a real-time/recursive-O(N) MBD ref, to pre-empt the "descriptor solve is textbook" reviewer and
  fix the thin §II paragraph (REVIEW_TODO).
- **GAP 3 — Moving Horizon Estimation.** One sentence acknowledging MHE as the constraint-native
  alternative and why recursive UKF was chosen (Rao/Rawlings; a vehicle-MHE instance).
- **GAP 4 — recent baselines.** Jeyed & Ghaffari 2019 (EKF, articulated HV), Yang et al. 2023 (UKF).
- **GAP 5 — your own methods → cite, don't claim novel.** (a) Parameter-uncertainty propagation = the
  **consider / Schmidt-Kalman filter** (CONSIDER case confirmed): cite **Stauch & Jah 2015 (USKF)** as
  method + **Zanetti & Bishop 2010** as concept + Schmidt 1962 (in store) as seed; desensitized KF as
  contrast. (b) Output uncertainty = unscented transform (Julier-Uhlmann, already cited) — frame as
  the *enabler* that gives all three an Fc covariance, not a contribution. Claim only the
  *application*: calibrated, parameter-uncertainty-aware coupling-force estimate.
- **Vocabulary bridge (§II/§IV):** augmented/descriptor (6×6, KKT) vs reduced/Kane (4×4) = the Schur
  complement; Kane derives the reduced form directly. Name both communities' terms.

---

## PART C — NEW RESULTS to present, and how to frame them

### C1. Computational characterization [MEASURED] → §VII
Compile cost (numeric ~44–46 s vs symbolic ~25 min) separates implementation strategy, not
formulation; per-step is a wash (DAE 1.994 µs vs reduced-Lag 1.907 µs isolated). DAE ≡ Lagrangian to
machine precision. Headline: feasibility folklore corrected; no formulation wins on cost.

### C2. Conditioning [MEASURED] → §VII (short)
`A` depends on articulation angle ONLY; well-conditioned over full ±180° for all realistic masses
(worst cond ≈4.5×10⁵, never singular). Report as "no formulation has a conditioning disadvantage in
any reachable configuration." NOT a discriminator. (Caveat: no real high-articulation trajectory
exists; jackknife well-posedness is analytic + synthetic, not from aggressive data.)

### C3. Estimation quality — the headline distinction → §VII
- **Calibration [MEASURED, structural]:** DAE/Lagrangian post-hoc Fc NEES = 10³–10⁵ (over-confident,
  ~4 orders); FakeSpring 4.5–475. The damper's measurement-correctable Fc gives usable calibrated
  uncertainty; the post-hoc forms do not.
- **Accuracy [PROVISIONAL]:** FakeSpring has lower Fc RMSE across maneuvers (cfx: circle 118 vs 447,
  sine 100 vs 384, uphill 394 vs 1565 — all on fixed post-bug truth). Confirm under matched tuning
  before claiming. brake_turn favours the DAE on
  cfx but its cfy is far worse — present with the M432 divergence caveat (all formulations diverge on
  that extreme ultralight Sobol sample; not formulation-specific, not conditioning).
- **CAVEAT:** the calibration gap may *narrow* once consider-parameter propagation is on (it inflates
  the post-hoc Fc covariance); the consider on/off ablation quantifies fixable-vs-structural. The
  pvec RESHAPE crash that blocked this is **now fixed** — run the ablation.

### C4. Grade artifact — RESOLVED as a truth-gen bug (NOT a paper result)
The grade↔coupling-force artifact on graded maneuvers was traced (2026-06-06) to **two bugs in
VTMLibrary truth generation**, both fixed: (1) quaternion scalar-first/last in the road
slope-compensation, so `road_dzdx` was applied world-fixed instead of heading-swept; (2)
`SensorOutput.Force` exported slope-compensated instead of raw, omitting the `Fz·dzdx` grade term.
Post-fix the grade-correlated cfx residual is eliminated (body x-resid 0.81→0.134, grade corr
−0.999→+0.27). **Experiments were regenerated; the 06-07 graded results use fixed truth.** There is
**no observability limitation and no trailer-accelerometer result** — that framing was an artifact of
the bugs and must NOT go in the paper. Graded maneuvers are now ordinary valid test cases. (Minor
open item: a residual body-frame closure floor ~0.13 m/s², grade-independent.) Canonical record:
`Code/notes/grade_confound_findings_2026-06-05.md` (the 06-06 "RESOLVED" section).

### C5. Output uncertainty / noise floor [DESIGN — to finalize after the ablation]
Three non-overlapping uncertainty tiers (no double-counting): (i) **augment** the complex,
operating-point-dependent params (Cts, tire/geometry) — consider/sigma-points; (ii) **additive-
multiplicative** `(σ_m/m)²·cfy²` for mass/inertia (simple scaling; keeps the augmented sigma-count
down — no need to re-trigger pvec); (iii) **constant `R_model`** for the unexcited-regime floor
(straight-braking cfy), justified by omitted physics (tire conicity/relaxation, frame flexibility,
steering compliance — the tire-imperfection clause specifically earns the zero-excitation floor).
Size `R_model` from the *measured* unexcited residual, not by tuning to NEES; report NEES as the
independent check (target: bring cfx NEES from ~10⁴ into a calibrated range, not exactly 1).

---

## PART D — OPEN / PENDING (gated on the running matched-tuning + convergence)

1. **Matched-tuning RMSE + NEES** (same auto-tuning procedure per model — your "Weak in the NEES"
   Bayesian-opt; train on a Sobol spread over {circle_slope, sine, brake_straight}, test on the full
   suite, in-distribution vs held-out reported separately). → Confirms/kills the accuracy edge (C3),
   makes the FakeSpring-vs-DAE comparison defensible.
2. **Consider ON/OFF ablation** (pvec fix landed). → Sizes `R_model` (the residual after parameter
   propagation), tests how much Fc over-confidence is parameter-uncertainty (fixable) vs structural,
   and likely explains the brake_turn divergence. Single most compelling UQ figure.
3. **Parameter-sensitivity sweep** (`d_c`/`k`). → The honest cost side of the damper's calibration
   edge (its accuracy depends on a non-physical parameter; DAE/Lagrangian are coupling-parameter-free).

**Do not finalize the §VII contribution wording until 1 and 2 land.** Today's defensible claim:
"computationally equivalent; the damper's measurement-correctable Fc gives substantially
better-calibrated coupling-force uncertainty," accuracy edge provisional.

---

## PART E — pre-existing REVIEW_TODO items this session touches

- **RESOLVED by this session:** NEES/uncertainty thread decision (§5b → KEEP, it's the headline);
  computational-benchmark direction (item 2 → three-way, per-step wash).
- **NEWLY MOTIVATED:** Foundation-1 (damper naming/stability), Foundation-2 (Baumgarte ↔ constrained-
  estimation taxonomy), §II thin constraint-differentiation paragraph (content fix + GAP 2 grounding).
- **STILL OPEN, INDEPENDENT (not changed by this session — keep tracking in REVIEW_TODO):** §IV physics
  decisions (gravity sign §IV-1, articulation rotation §IV-2, wheel velocity §IV-3, tire-force sign
  §IV-4, normal-load source §IV-7), the commented-out Abstract, missing figures/bib entries, §VI
  over-subdivision, the tuning-table consolidation. These are orthogonal to the DAE/estimation-quality
  story and should be carried forward as-is.
