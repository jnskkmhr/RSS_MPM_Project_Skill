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
