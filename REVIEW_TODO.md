# Coupling Paper — Review TODO / Open Items

Tracking document for `coupling_ieee.tex`. Last updated: 2026-06-05.
Inline markers in the `.tex`: `DECISION[needs-AC]` (author must answer), `PIN[foundation-...]` (deferred to post-draft). Grep those tags to jump to context.

Review status: §I ✅ · §II ✅ · §III ✅ (prose) · §IV ✅ (reviewed, decisions pending) · §V–§VIII ⬜ not yet reviewed.

---

## 1. Decisions needed from author (blocking — confirm against code)

Each is pinned inline as `DECISION[needs-AC]`.

- [ ] **§IV-1 Gravity sign** (`eq:Kinematicacceleration`, ~l.320). Transport theorem gives `v̇ = a_CG + a_gravity − ω×v` (gravity ADDED); paper subtracts. Flip here, or redefine `a_gravity = −R·g` at `eq:gravForce`.
- [ ] **§IV-2 Articulation rotation direction** (eqs ~220, ~297, `eq:Damper`). With CCW `R` and `ψ̇_{2→1}=ω1−ω2`, the 2→1 transform should be `R(−ψ_{2→1})=Rᵀ`, not `R(+ψ_{2→1})`. Negate angle in all three, OR fix sign of `eq:dotArticulation`.
- [ ] **§IV-3 Wheel velocity** (eq ~380). (a) Cross product `r×ω` reversed → should be `ω×r` (cf. ~l.212). (b) Frame mixing: form `v_CG + ω×r` first, then rotate by `δ`.
- [x] **§IV-4 Lateral tire force** ✅ RESOLVED (2026-06-10) — reverse motion declared out of scope (forward-driving scope added to §III; all metrics gated to `|vˣ| > 2 m/s`, since slip `vʸ/vˣ` is ill-defined near standstill). `vˣ` kept without absolute value; inline pin replaced with RESOLVED note.
- [ ] **§IV-7 Normal-load source (REOPENED)** — code (`computeVerticalForcesFromCOG`, identical in `FakeSpring.m` + `Lagrangian.m`) SOLVES vertical/normal loads from a static equilibrium `Ax=b`, NOT from measurement. Contradicts §III l.150 ("measured once at standstill") and §IV l.371 ("measured normal loads"). Reconcile: describe the static solve (match code), or change code to consume measured loads. Affects both models equally. [Earlier "Q1 resolved" was wrong — checked against paper only, not code.]
- [x] **§VI-8 Real-world validation scope** ✅ RESOLVED — "IceCircle" files are high-friction circle + brake tests (dataset naming only); data is in-scope, "validation" legitimate. Pin removed. Low-friction failure-mode data also exists (§VI-C framing stays) but is NOT yet staged in `experiments/` — must be added before §VII failure-mode results can be generated.
- [x] **§VI-9 Longitudinal stiffness variation** ✅ RESOLVED — clarified as simulator-only mismatch (estimator neglects longitudinal slip; not an estimated parameter).
- [x] **§VI-10 Cornering-stiffness units** ✅ RESOLVED — relabeled as load-normalized cornering coefficient, `[5,18] rad⁻¹`.
- [x] **§V-11 Augmented params** ✅ RESOLVED — static "consider parameters," uncertain, propagated via sigma points (§V-D correct as written). Stale `random-walk per step` line in §VI TODO to be removed when filling that section.
- [x] **§VI-12 Scenario/real-world consistency** ✅ mostly RESOLVED — real-world = high-friction circle + brake (matches §VI-C). Minor residual: ensure the maneuver/MC counts (4 scenario types vs. 5 convergence maneuvers vs. 400-case MC in §I) are made consistent when §VII results are finalized.
- [x] **§IV-6 Velocity reference point**. ✅ RESOLVED: `P_i` (first axle) is the frame origin / geometric reference; the velocity STATE is the CoG velocity (for Newton-Euler). §IV was already correct (CoG state); fixed §III l.105 + l.143 to match. Baseline draft (CoG) consistent. No equation changes needed.
- [x] **§IV-5 Baseline definition** (`sec:baseline_model`). ✅ DRAFTED as the Lagrangian minimal-coordinate (Kane's method) baseline, from `Lagrangian.m`. DAE now framed only as what it avoids. Title aligned with §I/§II. Inherits §IV-1 (gravity) + §IV-2 (rotation) conventions; cost numbers deferred to §VII. Review the new prose.

## 2. Promised deliverables (committed in text, not yet delivered)

- [ ] **Abstract** — currently fully commented out (§I, ~l.42–46). Restore before submission.
- [ ] **Computational benchmark** (§VII) — Intro contribution 2 promises **per-step filter execution time** + **symbolic compilation time** (damper vs Lagrangian). Results section must deliver a table. (Planned at ~l.646–648.)

## 3. Deferred foundational issues (post-draft — fix once structure is settled)

Pinned inline as `PIN[foundation-...]`.

- [ ] **Foundation-1: damper-stiffness / overclaim.** Stiff damper has fast mode `~ −d_c/m`, Euler-stable only for `dt < 2m/d_c` → swaps oscillatory for dissipative stiffness, not free. `d_c` is a tuned regularization, NOT rigid → reconsider "rigid damper" naming. Add a stability paragraph (plug in tuned `d_c`, 10 ms step). Reconcile velocity-only damper vs position constraint with kinematically-slaved trailer velocity (geometry carried by kinematics; state it to pre-empt the reviewer).
- [ ] **Foundation-2: Baumgarte positioning.** Velocity-only penalty on a differentiated constraint = Baumgarte stabilization with position gain 0. One sentence + cite, differentiate (drift control vs exposing coupling force as a filtered state). Place in §IV; may shrink under estimation-first framing.

## 4. In-section TODOs (pre-existing `\textbf{TODO}` / placeholders in the .tex)

- [ ] **Figure `fig:frames`** (`imgs/ModelDrawings.pdf`, ~l.188) — placeholder caption "TODO: Replace with final figure and caption".
- [ ] **Input vector `u`** (§IV, ~l.369) — define components explicitly + summary table (torques, steering, normal loads).
- [ ] **Parameter vector `θ`** (§IV, ~l.373) — formally define components; justify fixed/uncertain/augmented partition.
- [x] **Baseline expansion** (§IV) — ✅ drafted (9-state structure, `M(ψ)` mass matrix, post-hoc force recovery). Remaining: cost-vs-damper numbers, which belong to §VII (item 2).

## 5. Minor / bibliography / build

- [x] **Document body compiles** ✅ — 0 LaTeX errors in the text, 0 undefined refs. `\mathbf` blocker fixed at the ROOT: removed the dead `\gdef\r{\mathbf{r}}` / `\gdef\l{\mathbf{l}}` from `myDefs.tex` (unused anywhere; equations use `\bm r`/`\bm l`). `\r` is now the standard ring accent again, so `\aa` and literal `å` work document-wide. Literal `Lindgårde`/`Göfvert` compile. Added explicit `\usepackage[utf8]{inputenc}`.
- [x] **Accent landmine (`\r`,`\l`)** ✅ RESOLVED at root (removed). Note: `\c \t \s \w \P \A` are still redefined in `myDefs` — only `\A`/`\CG`/`\Cr`/`\Cf` are actually used; `\c \t \s \w \P` remain unused latent landmines for `ç`, ties, `ł`, `¶`, but do NOT affect å/ä/ö. Remove later if desired.
- [x] **`references.bib` encoding** ✅ RESOLVED — file is actually UTF-8 (most accented names, e.g. Fröjd, are valid UTF-8 and render fine under `inputenc utf8`). The only corruption was line 1192, where å/ö in "Lindgårde, Olof and Göfvert" had been mangled to literal `U+FFFD` chars; fixed with robust LaTeX commands `Lindg{\aa}rde`, `G{\"o}fvert`. (Other entries with non-ASCII not currently cited — if cited later and they error, convert those to accent commands too.)
- [ ] **Missing figure `imgs/Winter2022.pdf`** (real-world results, §VII ~l.661) — file absent → graphicx draft box; the draft box also triggers the `OT1/pcr` (Courier) "TFM not found" error (TinyTeX lacks Courier metrics). Both vanish once the figure exists or the `\includegraphics` is commented.
- [ ] **Missing `.bib` entries** — `ceder_bayesian_2025` (conference self-cite, §IV l.162) and `berntorp_tire-stiffness_2019` (§IV l.233) are not in `references.bib`. Add them.
- [ ] **`dahlberg_influence_nodate`** — empty `journal` AND `year` fields in `references.bib`. Fill in.
- [ ] **§II constraint-differentiation paragraph** (~l.81) — thin (one textbook cite, Shabana). Optional: add a vehicle-specific reference for robustness.

## 5b. Structure / packaging (cleanup pass — story path is sound, these are packaging)

Overall narrative path and 8-section split assessed as clear and correct; no resequencing needed. Two packaging items + one thread decision:

- [ ] **§VI over-subdivided / self-overlapping** (self-flagged at l.495). Five subsections with scenarios split across sim and real-world. Consolidate to ~three: *Setup* (sim + real-world), *Scenarios & Variations*, *Metrics*.
- [ ] **Tuning/noise parameters scattered** across §V-E (qualitative), §VI-D (variations), and the Q/R/P₀ TODO blocks. Consolidate the actual numeric values into one tuning table (§VI or short appendix); reduce §V-E to the principle.
- [ ] **NEES/uncertainty thread — decide in §VII.** Dropped from the contribution list but ANEES still computed (§VI-E) and leaned on in the baseline (damper gives coupling-force covariance, Lagrangian post-hoc does not). If §VII exploits ANEES on coupling force (damper-only capability) → keep as a supporting strength; if not → trim ANEES as vestigial.
- [ ] **(optional) §IV signposting** — heavy section; add lightweight run-in `\textbf{}` headers to the proposed-model subsections, matching the baseline draft.

## 6. Sections not yet reviewed

- [x] **§V Estimation Framework** — ✅ reviewed. Clear-cut fixes applied (typos, `Q_k=Q_c T_s`, noise-vs-parameter augmentation wording). Open: §V-11 (static vs random-walk params). TODOs remain: explicit measurement equations (l.464).
- [x] **§VI Evaluation** — ✅ reviewed. Clear-cut fixes applied ("Lagrangian baseline" terminology). Open: §VI-8 (real-world scope, MAJOR), §VI-9 (longitudinal stiffness), §VI-10 (cornering units), §VI-12 (scenario consistency). Self-flagged structural duplication (l.495) + many content TODOs (VTM details, UKF specifics, sensor noise).
- [ ] **§VII Results and Discussion** (~l.616) — simulation results, real-world results, discussion. (Computational benchmark lands here, item 2.)
- [ ] **§VIII Conclusion** (~l.705).

---

## Resolved (for reference)
- ~~Normal loads: measured inputs; no `Ax=b`. Consistent.~~ **WRONG — reopened as §IV-7** (code solves `Ax=b` statically in both models).
- Frame convention: ISO 8855 (x-fwd, y-left, z-up) confirmed authoritative; project `Code/CLAUDE.md` corrected.
- §I/§II: voice normalized to "we"; em-dashes removed; "essential states" defined; contributions restyled; gap-claim primacy ("to the authors' knowledge") dropped.
- §IV clear-cut fixes: `eq:Damper` malformation, `⊙` added, missing dots, typos.
