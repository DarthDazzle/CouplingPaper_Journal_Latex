# NOTE for the paper-writing agent — symbolic complexity & compile cost (§VII computational claim)

**Finding (measured this session): the three formulations differ enormously in symbolic
complexity and one-time compile cost, and this is the concrete evidence for the Intro
contribution-2 / §VII computational benchmark.** The two *symbolic-elimination* formulations
(Lagrangian, and the symbolic-solve variant of the DAE) generate ~220 k-character closed-form
state-update expressions and take ~25 min to compile; the *runtime-solve* DAE keeps the
generated expression at ~60 characters and compiles in seconds, at the price of a small
per-step numeric linear solve. This is the cost/directness trade-off the paper should report.

## What to claim (supported by data)

Symbolic complexity is quantified as the character length of the symbolic expression handed to
`matlabFunction` (a faithful proxy for generated-C size): `expr_to_generate` for the prediction
(Euler state update `x + dt·f`), `eqns_subs` for the measurement/output model. All figures from
the same case (`circle`, Case001, ~12 t), MATLAB R2025b, MSVC 2022, full clean rebuild.

| formulation | prediction expr (max single / total chars) | output expr (max single) | clean compile |
|---|---|---|---|
| **FakeSpring** (damper ODE, c_fx/c_fy as states) | small (compiles in 36 s) | small | **36 s** |
| **Lagrangian** (Kane, 4×4 `M\F`, Fc recovered post-hoc) | **221,822 / 732,209** | **210,690** | **~25 min** |
| **DAE — symbolic solve** (6×6 `A\b` in closed form) | **231,410 / 695,345** | (~231 k pre-trim) | not viable in practice |
| **DAE — runtime solve** (6×6 built, `A\b` solved online) | **62 / 179** | A ≤ 33, b ≤ 1883 | **44 s** |
| **Lagrangian — runtime solve** (4×4 built, `M\F` solved online) | small | small | **46 s** |

**UPDATE (measured): the runtime-solve reduction applies equally to the
Lagrangian.** Exposing Kane's 4×4 system `A·sol = b` (the same `getCouplingSolve`
hook) and solving it online drops the Lagrangian clean compile from **1481.9 s
(24.7 min) to 46.3 s** (`Pred` scalar codegen 394 s → 8.2 s), with estimates
**identical** to the symbolic-elimination Lagrangian (≤ ~10⁻¹¹ N on cfx/cfy
across maneuvers). So the ~25-min compile is an artifact of *symbolic
elimination*, not of Kane's method — both formulations reduce to a small
per-step linear solve. **Compile cost therefore separates the implementation
strategy (symbolic-elimination vs runtime-solve), not the two formulations.**

Key points:

- **Lagrangian (221 k) ≈ symbolic-solve DAE (231 k).** Both eliminate/solve the coupling
  symbolically — Kane via a 4×4 mass-matrix solve recovering generalized accelerations (then
  Fc post-hoc); the DAE via a 6×6 solve for `[a1x,a1y,ẇz1,ẇz2,Fcx,Fcy]` — and both yield
  ~220–230 k-char closed forms. The symbolic blow-up is intrinsic to closed-form elimination of
  the coupled algebraic system, *not* specific to one formulation.
- **The Lagrangian recovered-coupling-force output is itself ~210 k chars**, i.e. recovering Fc
  post-hoc is as expensive as the dynamics. (In build terms this was a 57 s scalar + 416 s
  vectorized output build.)
- **The runtime-solve DAE collapses the prediction to 62 chars (~3,600× smaller).** It emits
  the small coefficient matrix `A` (6×6, entries ≤ 33 chars) and RHS `b` (≤ 1883 chars) and
  performs `A\b` numerically at each evaluation, rather than baking the inverse into source.
- **Per-step (online) cost trade-off:** the runtime-solve DAE pays one 6×6 `mldivide` per sigma
  point in each of prediction / measurement / output (microseconds), versus evaluating a giant
  pre-derived expression in the symbolic formulations. Online estimate timings from this
  session: FakeSpring 1.8 s (36× real-time), Lagrangian 2.4 s (28× real-time); runtime-solve
  DAE 1.6 s (40× real-time) for the filter loop + 14.3 s output-covariance calc (the output
  model's per-sigma-point 6×6 solve via a column-loop wrapper; in family with FakeSpring's
  15.5 s). All three exclude one-time compile. **CAVEAT: these are filter-loop wall-clock figures,
  confounded by state count (FakeSpring n=11 vs 9) and interpreter overhead — do NOT read "DAE
  fastest" from the 1.6 < 1.8 < 2.4 ordering; see the fair comparison below and the isolated
  microbenchmark.**
- **Per-step, fair comparison (both runtime-solve), measured this session over 3×5 cases:**
  once the Lagrangian also solves its 4×4 online, filter-loop real-time factors are
  FakeSpring_DAE **46–60×** (6×6) and Lagrangian **44–54×** (4×4) at equal state dimension
  n = 9 — i.e. the **same speed class**; the 2-row difference is lost in UKF overhead. The
  earlier apparent "DAE 1.7–1.9× faster than Lagrangian" gap (DAE 46–60× vs symbolic-Lagrangian
  27–32×) was an *implementation* artifact (runtime solve vs evaluating the 221k-char monolith),
  **not** a property of either formulation. Conclusion: **neither compile cost nor per-step cost
  discriminates DAE from Lagrangian once both are solved numerically.** The independent isolated
  `timeit` microbenchmark (warm, identical inputs) confirms it directly: per `Pred` call **DAE 6×6
  = 1.994 µs vs reduced 4×4 = 1.907 µs** — a wash, with the reduced form *marginally faster*. So do
  NOT claim the 6×6 is fastest per step. Canonical per-step source:
  `NOTE_independent_verification_for_results.md` §2.

**VALIDATION (measured): the runtime-solve DAE reproduces the Lagrangian estimates exactly.**
On `circle` Case001 the two formulations agree to 4 sig figs on all five targets — cfx 447.1,
cfy 568.5 N, articulation 0.002238 rad, lat-vel tractor 0.01221, trailer 0.01114 m/s — which is
expected (mathematically equivalent coupled dynamics; DAE solves the 6×6 for Fc, Lagrangian
eliminates Fc) and confirms the runtime `A\b` is correct. So Option C buys the ~3,600× smaller
expressions / 44 s compile at zero accuracy cost.

## How to frame it

- §VII: present compile cost (development/iteration cost) and per-step cost (deployment cost)
  as two distinct axes. The symbolic-elimination methods front-load cost into a multi-minute
  compile and a large binary; the runtime-solve DAE trades a negligible online linear solve for
  a trivial compile.
- This is a genuine, quantified distinction between the DAE (runtime-solve) and Lagrangian
  formulations even though they are mathematically equivalent at equilibrium — supports keeping
  all three as methodologically distinct contributions.
- Use the char-length proxy as "symbolic expression size"; report compile times as indicative
  (hardware-dependent), not as precise benchmarks.

## Status / caveats

- Lagrangian and symbolic-solve-DAE numbers are MEASURED (symbolic-size diagnostics +
  Checkpoint-1 clean-rebuild timings, this session).
- Runtime-solve-DAE is now fully MEASURED end-to-end (Checkpoint 3): 62/179-char prediction,
  44 s clean compile, runs and matches Lagrangian exactly.
- Compile times are one-time and cached; they are R2025b / MSVC 2022 / this machine, full clean
  rebuild. State counts: FakeSpring 11, Lagrangian 9, DAE 9.
- Technical record + diagnostics: `Code/notes/diagDAE.m`, `Code/notes/diagLagrangian.m`,
  `Code/notes/regressionCP1.log`; implementation branch `option-c-runtime-solve`.
