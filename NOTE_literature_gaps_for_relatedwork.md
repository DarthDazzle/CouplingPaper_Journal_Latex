# NOTE — literature gaps for §II Related Work (what escaped us)

**Date:** 2026-06-07. Checked against: Latex/references.bib (97 cited entries), the reading store
F:\Projects\Overview\Papers (INDEX.md, 73 entries / 62 PDFs), and targeted web searches. Below:
the one framing gap that actually strengthens the paper, three smaller gaps, and what is already
well-covered (do NOT re-add). Specific candidates + URLs in the Sources list at the bottom.

---

## GAP 1 (HIGH — framing, not just a citation): constrained state estimation

**You are citing only the narrow DAE-EKF corner (Becerra 2001, Purohit 2018) and missing the
larger, more directly applicable literature on CONSTRAINED Kalman filtering.** This matters
because the coupling constraint is a *state equality constraint*, and the three formulations you
compare are three standard ways the constrained-estimation literature handles exactly that:

- **Damper / penalty (FakeSpring)** ≈ soft-constraint / penalty enforcement.
- **DAE / augmented solve** ≈ enforcing the constraint exactly each step (projection / "perfect
  measurement" family).
- **Lagrangian / Kane elimination** ≈ "model reduction" — eliminate the constrained DOF. Simon's
  survey lists this explicitly as one of the constraint-handling methods.

So your three-way comparison is not ad hoc — it is three points in an established taxonomy.
Saying so (and citing it) repositions the paper inside a recognized framework and pre-empts the
"why these three?" question. Key references to add:

- **Simon, D. (2010), "Kalman filtering with state constraints: a survey of linear and nonlinear
  algorithms," IET Control Theory & Appl. 4(8).** The canonical survey; cite as the taxonomy
  anchor. (Note for linear system + linear constraints all methods coincide; they diverge only
  under nonlinearity — exactly the regime that makes your comparison non-trivial.)
- **Teixeira, Chandrasekar, Tôrres, Aguirre, Bernstein (2009), "State estimation for linear and
  non-linear equality-constrained systems," Int. J. Control 82(5).** Defines the four
  constrained-UKF variants: equality-constrained UKF, **projected UKF**, measurement-augmentation
  UKF, constrained UKF. These are direct alternative ways to enforce your coupling constraint in a
  UKF — they belong in Related Work as the methods you are implicitly choosing among.
- **Simon & Chia (2002), "Kalman filtering with state equality constraints," IEEE TAC** (and/or
  Simon & Simon, equality+inequality constraints). The projection-onto-constraint baseline.

You already have one adjacent item — **Jeong et al. (2022), "…constrained lateral dynamics
model"** — but that is a constrained *model*, not the constrained-*estimation* theory. Use it as
the vehicle-domain bridge to the Simon/Teixeira theory.

## GAP 2 (MEDIUM-HIGH — pre-empt the "this is textbook" reviewer): augmented vs reduced MBD

The "solve the 6×6 descriptor system numerically each step" result is standard multibody dynamics
(augmented / descriptor formulations), and a reviewer from that community will say so. Cite it
*proactively* to show you know it is textbook and are porting it to estimation:

- **Bayo & Ledesma (1996), "Augmented Lagrangian and mass-orthogonal projection methods for
  constrained multibody dynamics," Nonlinear Dynamics 9.** Grounds the augmented per-step solve
  and the augmented-vs-reduced trade-off (real-time, O(N), constraint satisfaction).
- A **real-time / recursive-O(N) multibody** reference (coordinate partitioning, Wehage & Haug;
  or a recent real-time MBD work) to frame reduced/Kane vs augmented as a known choice.
- You already cite Shabana (Dynamics of Multibody Systems) and Lindgårde & Göfvert (9-DOF Euler) —
  good, but they do not cover the augmented-vs-reduced *numerical* trade-off specifically.

This pairs with the reframe note: the contribution is the estimation context + the comparison,
NOT "we discovered you can solve a DAE numerically."

## GAP 3 (MEDIUM — acknowledge the constraint-native alternative): Moving Horizon Estimation

MHE is the principled optimization-based way to handle state constraints in estimation, and it is
completely absent from the corpus. Related Work should at least acknowledge it and say why you
chose recursive UKF (real-time recursion vs per-step optimization / arrival-cost cost).

- **Rao, Rawlings, Mayne (2003), "Constrained state estimation for nonlinear discrete-time
  systems…," IEEE TAC** (or Rao & Rawlings, the moving-horizon approach).
- A **vehicle MHE** instance (e.g. Nonlinear Constrained MHE for vehicle position, Sensors 2019)
  to show it has been tried in-domain.

## GAP 4 (LOW-MEDIUM — currency / baselines): recent articulated-vehicle estimation

Your articulated-estimation coverage is already strong (Korayem hitch-forces + review, Ehlers,
Cheng & Cebon, Volkov functional observer). Candidates to consider for completeness:

- **Jeyed & Ghaffari (2019), "Nonlinear estimator design based on EKF… of articulated heavy
  vehicle," Proc. IMechE Part K.** A direct EKF baseline for the articulated HV — natural
  comparison point.
- **Yang et al. (2023), "An UKF-based velocity estimation method for articulated steering
  vehicle…," Proc. IMechE Part K.** Recent UKF-on-articulated; shows currency.
- Optionally a recent EKF-vs-UKF vehicle-trailer comparison and/or a DEKF state+parameter trailer
  paper.

**Good news worth stating in the Intro:** no 2023–2026 work surfaced that targets the coupling
force as a *direct estimation target* via competing constraint formulations. Your niche appears
unscooped — this supports the contribution-3 claim that coupling-force estimation has had limited
attention as a direct, real-time filtering target.

## GAP 5 (HIGH — your OWN methods need prior-art citations, NOT novelty claims): parameter-uncertainty propagation + output uncertainty

Two techniques currently presented in the paper as (implicitly) novel are established, named
methods. Cite them and claim the *application*, not the mechanism — otherwise a reviewer asks
"how is this different from the Schmidt-Kalman filter?"

**(a) "Uncertainty in parameter propagation" = the consider / Schmidt-Kalman filter family.**
- You already cite the seed (Mc Gee/Schmidt 1962). Connect it to the modern named methods.
- Augmented-state consider filter, unscented form = **Unscented Schmidt-Kalman Filter (USKF)**
  (Stauch & Jah, 2015). MUSE's "State Augmentation for Parameter Uncertainty" + parameter
  sigma-points (pvec mode) maps directly onto the augmented-state consider approach.
- Adjacent / alternative: **desensitized KF (DUKF / DCKF)** (Karlgaard & Shen and follow-ons) —
  minimizes *sensitivity* to parameter deviations via a penalty rather than propagating a consider
  covariance. Worth a one-line contrast.
- **RESOLVED (Axel, 2026-06-07): the CONSIDER case — parameter uncertainty is propagated, values
  held (no Kalman update on the parameters).** Primary anchor = **USKF (Stauch & Jah, 2015)** /
  Schmidt-Kalman consider filter (seed: Schmidt 1962, already in store). This is NOT the joint/dual
  UKF (Wan & van der Merwe), which is the *estimate* case — cite that only as the contrast you did
  NOT take. Position the method as "augmented-state consider (USKF)".

**(b) "Uncertainty in outputs" = the unscented transform applied to the output map.**
- Mechanism = Julier-Uhlmann unscented transform (already cited), pointed at g(x) → mean +
  covariance on derived quantities. Standard; do NOT claim it as novel.
- BUT it is *load-bearing for the comparison*: for the DAE and Lagrangian, Fc is an OUTPUT, not a
  state, so output propagation is the ONLY source of an Fc covariance. It is what makes the
  three-way uncertainty comparison fair (all three can report Fc uncertainty). Present it as the
  enabler, not a contribution.

**The defensible novelty (claim THIS, narrowly):** the *application/combination* — in
articulated-vehicle coupling-force estimation, propagate genuinely-uncertain, load-dependent
vehicle parameters through to a **calibrated uncertainty bound on the recovered coupling force**, a
quantity prior hitch/coupling-force work (Korayem et al. and the rest of the corpus) reports as a
bare point estimate with no uncertainty. Validate the calibration via NEES. This ties into the
constrained-estimation framing (Gap 1) and the consistency/NEES story, and is honest: established
machinery, novel target.

**Presentation & validation burden (this is the practical payoff of having the citation):**
- **Demote both from the contribution list to cited methodology.** "We propagate parameter
  uncertainty via the unscented Schmidt–Kalman / consider approach [Stauch & Jah 2015; Zanetti &
  Bishop 2010]" is a complete, reviewer-proof sentence. You do NOT validate a cited method (no more
  than you re-prove the UKF). This removes the burden of a dedicated "prove it's useful" study.
- **No separate validation campaign needed.** Any claim you still make (calibrated covariance,
  meaningful coupling-force uncertainty) is carried by the **NEES you already compute** in the
  matched-tuning sweep — it does double duty as "works in our setup." Not a new experiment.
- **ELEVATED (2026-06-07) — now has measured stakes (was "optional"):** the independent
  verification found the DAE/Lagrangian post-hoc **Fc NEES is 10³–10⁵ over-confident** (vs ≈1) —
  exactly the over-confidence consider-parameter propagation is built to fix, since Fc depends
  heavily on the uncertain masses/inertias/geometry. So a **consider-ON vs consider-OFF NEES
  comparison** is no longer just a nice demo: it quantifies how much of the post-hoc Fc
  over-confidence is parameter-uncertainty (fixable by USKF) vs structural (not), and bears
  directly on the §VII verdict (how deployable the DAE/Lag Fc uncertainty is). It is also the
  single most compelling one-figure demonstration of this GAP-5 method and likely **explains the
  brake_turn / M432 divergence** (parameters held at nominal is when a filter gets over-confident
  and diverges). **Currently BLOCKED:** the pvec (parameter-vectorized) MEX recompile fails with a
  RESHAPE codegen error when the parameter sigma-point count changes (`Code/notes/spikeTuning.log`)
  — fix before the ablation can run.
- **Concept vs method citation split:** cite **Zanetti & Bishop (2010), "On the Consider Kalman
  Filter"** as the *concept* anchor and **Stauch & Jah (2015) USKF** as the *unscented method* you
  use; Schmidt 1962 (in store) as the historical seed.

## Already well-covered — do NOT re-add
KF foundations (Kalman, Julier–Uhlmann, Wan–van der Merwe, Schmidt); tire (Pacejka, Magic
Formula, Giashi slip-velocity friction, adaptive tire); jackknife/stability (Dunn, Bouteldja,
Winkler, safe-operating-envelope, Aurell); articulated estimation (Korayem ×3, Ehlers, Cheng &
Cebon, Volkov, De Saxe vision); modeling (Ghandriz ×2, Lindgårde 9-DOF, Jacobson compendium);
sensors/IMU (Allan variance, HybVIO, GPS velocity); DAE-EKF (Becerra, Purohit).

## Suggested placement
- §II add a short "Constrained state estimation" paragraph (Gap 1) — this is the new framing spine
  and should come BEFORE the formulation-specific paragraphs, casting damper/DAE/Lagrangian as
  penalty/projection/reduction.
- §II "Articulated Vehicle Dynamics Modeling" paragraph: add Bayo & Ledesma + the MBD O(N) ref
  (Gap 2).
- §II add one sentence on MHE as the constraint-native alternative (Gap 3).
- §II "State Estimation for Articulated Vehicles": fold in Jeyed & Ghaffari / Yang (Gap 4).

---

## Sources (web-search; pull exact BibTeX from publisher/DOI)
- Simon, Kalman filtering with state constraints survey: https://digital-library.theiet.org/doi/10.1049/iet-cta.2009.0032 ; author copy https://engagedscholarship.csuohio.edu/enece_facpub/23/
- Teixeira et al., State estimation for linear and non-linear equality-constrained systems: https://www.tandfonline.com/doi/full/10.1080/00207170802370033 ; semanticscholar https://www.semanticscholar.org/paper/b8bd7856f0f96d541e6fab03249270d1dfa1876a
- Teixeira et al., Unscented filtering for interval-constrained nonlinear systems (CDC08): https://public.websites.umich.edu/~dsbaero/library/ConferencePapers/CDC08Papers/UKFIntervalTeixeiraCDC08.pdf
- Kalman filtering with equality/inequality state constraints (Simon & Simon): https://arxiv.org/pdf/0709.2791
- On Kalman filtering with linear state equality constraints: https://www.sciencedirect.com/science/article/abs/pii/S0005109818306162
- Bayo & Ledesma, Augmented Lagrangian / mass-orthogonal projection for constrained MBD: https://link.springer.com/article/10.1007/BF01833296
- Real-time simulation of multibody (Baharudin, LUT thesis): https://lutpub.lut.fi/bitstream/handle/10024/120728/MEB_A4.pdf
- Nonlinear Constrained MHE applied to vehicle position (Sensors 2019): https://www.mdpi.com/1424-8220/19/10/2276
- MHE of vehicle state and parameters (Extrica): https://www.extrica.com/article/22795
- Constrained Linear State Estimation — A Moving Horizon Approach (Rao/Rawlings): https://www.researchgate.net/publication/222699638
- Jeyed & Ghaffari, EKF state estimation of articulated heavy vehicle (2019): https://journals.sagepub.com/doi/10.1177/1464419318772173
- Yang et al., UKF velocity estimation for articulated steering vehicle (2023): https://journals.sagepub.com/doi/10.1177/14644193231174775
- Advanced Estimation Techniques for Vehicle System Dynamic State: A Survey: https://pmc.ncbi.nlm.nih.gov/articles/PMC6806602/
- Stauch & Jah, Unscented Schmidt-Kalman Filter Algorithm (J. Guid. Control Dyn. 38(1):117-123, 2015), DOI 10.2514/1.G000467: https://doi.org/10.2514/1.G000467 ; full text https://www.researchgate.net/publication/279292888_Unscented_Schmidt-Kalman_Filter_Algorithm
- Zanetti & Bishop, On the Consider Kalman Filter (AIAA GNC 2010) — concept anchor: https://arc.aiaa.org/doi/abs/10.2514/6.2010-7752
- Desensitized Kalman Filtering with Analytical Gain (Karlgaard): https://arxiv.org/pdf/1504.04916
- Desensitized Cubature Kalman Filter with Uncertain Parameter: https://arxiv.org/abs/1512.07675
- (consider filter seed, already in your store) Mc Gee/Schmidt 1962, statistical filter theory / circumlunar vehicle
- (joint/dual UKF, already cited) Wan & van der Merwe 2000, the UKF for nonlinear estimation
