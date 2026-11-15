# Decisions

Append-only. Newest at the bottom. One entry per decision: date, decision, why.

- **2026-11-14. Evaluation is organized around five questions (Q1 to Q5).** See `tasks/README.md`. The earlier "gait style" question is folded into Q3 as the explanation of the performance gap, since a gait difference alone does not support a claim.
- **2026-11-14. Hardware is the primary comparison for Q3.** In-MPM evaluation favors MPM-trained policies by construction and is supporting evidence only.
- **2026-11-14. The rigid baseline uses randomized friction and contact compliance.** Reviewers will ask for a strong rigid baseline.
- **2026-11-14. Box pushing is the loco-manipulation task; object carrying is not added.** A carried object never touches the terrain, so carrying is walking with a payload and a reduced-order model handles it equally well. A pushed box ploughs, sinks, and leaves disturbed ground, which only particles represent.
- **2026-11-14. Particle NeRD sim-to-real is optional.** The paper must not depend on it.
- **2026-11-15. T1 builds on the main line (`junnosuke/mpm_rl_task`), not the experimental particle-sleeping line.** The paper's method (recycling patch and particle cache) and all trained policies live on the main line. Sleeping (Max's work, `jnskkmhr/experimental-mpm-sleeping` under `~/isaac/experimental/`, with forked Newton and Warp) keeps full particle storage, so it does not bound memory, and its checkouts have uncommitted changes. It is parked; it may be added later as one controlled row in the cost table.
- **2026-11-15. The IsaacLab working tree was committed as `dcdc2ff3c` on `junnosuke/mpm_rl_task`** (local only, not pushed), and the T1, T3, and T4 worktrees under `~/isaac/worktrees/` were fast-forwarded to it. `exports/` (1.4 GB of artifacts) stays untracked.

## Open

- Quadruped task: include or soften the "diverse embodiments" claim?
- Particle NeRD: co-equal contribution or short final subsection?
- Revisit scenario for the cache ablation (candidates: turning in place, pushing the box back and forth).
- Page limit and deadline.
