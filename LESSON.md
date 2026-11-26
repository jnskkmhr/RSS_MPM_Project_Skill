# Lessons

What went wrong and how it was fixed. One entry each, written as a rule someone can follow. If a lesson keeps recurring, promote it to the Rules in `ONBOARD.md`.

Format:

```
- **YYYY-MM-DD, T<n>. <rule in one line>.** What happened: <one sentence>. Fix: <one sentence>.
```

- **2026-11-15, T4. Check the handoff's git state against the repo before trusting it.** What happened: outputs/T4.md said HEAD was bc77a1a41 with a dirty tree and untracked `contrib/velocity_mpm/`, but the work had since been committed as dcdc2ff3c ("Snapshot MPM RSS work"). Fix: the worktree was branched from the snapshot commit, so a clean checkout does contain those files.
- **2026-11-15, T5. Treat a handoff's untracked-file list as a lower bound; run `git status` yourself.** What happened: outputs/T5.md listed the dependent untracked files, and every path it named exists with HEAD `f9b9704fe` matching, but it omitted untracked `examples/particle_nerd/documentation/*local*` files, `exports/`, `skills/env_construction.md` and two `changelog.d/` fragments. Fix: commit from the full `git status` output, not the handoff's list.
- **2026-11-19, T1. A timing run must refuse to start when the GPU is not idle.** What happened: two runs of the environment sweep shared the GPU with another job, and one reported physics time was wrong until the check compared device memory with process memory. Fix: the runs were repeated alone; the benchmark script should check idle utilization and the memory baseline before it starts.
- **2026-11-19, T1. Fixed capacity defaults can set the result.** What happened: the sparse-grid reserve of 8,192 leaf nodes per environment (about 290 MiB) stopped the streaming modes at 32 environments; sized to the simulated sand they run 64. Fix: size reserves and cache capacities per run and report use against allocation.
- **2026-11-24, T3. Check that the feet do not reach the rigid base before reading a result on soft sand.** What happened: on the 0.25 m bed the loaded feet pressed through snow, clay, loose poppy seed, and most of the density-friction grid down to the rigid base, so every policy scored 10 of 10 there and the material results were not material results; the shallow bed also helped the rigid baseline on steep slopes. Fix: report the clearance between the loaded sole and the base for every cell and mark cells within 2 cm as invalid; test on a bed deep enough for the material.
- **2026-11-23, T2 and T3. Measure depths from the settled sand surface.** What happened: cube and foot sinkage were measured from the level the ground is generated at, which includes the sand's own settling of 4 to 9 cm, so sinkage was reported at about twice its real value. Fix: measure the settled surface in the same run and subtract it.

## 2026-11-24: a force sampled once per control step hid a 50 Hz cycle
- **What happened:** T1's box probe moved its gantry target once per control step and recorded the sand force at the last of four physics steps. The recorded force was 1.5 to 6 times below the mean. T1 and three rounds of T8 used it, and three independent checks reproduced the numbers without noticing, because they recomputed from the same recorded samples. It surfaced only when T8 varied the gantry stiffness.
- **Lesson:** when a force comes from a driven body, record it at the physics rate at least once and compare the mean with the reported value before using it. Ask checkers to question the measurement, not only to reproduce the arithmetic. A result that depends on how the body is held is a sign that the measurement is wrong.

## 2026-11-25: "slope" was a pyramid tile, not a planar ramp
- **What happened:** all slope evaluations used the training slope tile (Isaac Lab's pyramid slope, height = product of two ramps) walked along its axis, so the robot climbed a valley with side slopes of up to 20 degrees under its feet. Outputs and slides called it a slope of X degrees; an early planning row said "planar ramp". Ten checks did not notice, because they recomputed from the trial files and did not look at the terrain. It surfaced when the tile was enlarged for a longer run and the MPM policy, which had never fallen, fell in 3 of 3 trials.
- **Lesson:** state the terrain's geometry from the generating code, and plot or measure the surface under the robot once, before reporting results on it. When an evaluation reuses a training terrain, say so and say what else about it differs from the named condition.

## 2026-11-25: a contact margin set for the sand changed the robot's rigid contacts

The 2 cm contact margin on the foot box, set so that the sand sees a thicker plate, also made the foot touch the shin 2 cm early. That stopped the ankle at 26 of its 50 degrees on MPM sand only, in training and in every MPM evaluation, for weeks. Eleven checks of T3 and seven of T2 did not see it; it was found by a link-equivalence test in T5. Lesson: when a setting exists in one solver's environments only, list every contact pair it changes and compare joint ranges used across the solvers before comparing policies; a checker should ask "what differs between the compared simulators besides the ground model".
