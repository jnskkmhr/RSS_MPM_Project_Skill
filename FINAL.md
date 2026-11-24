# Final results

Written by the lead. Only results with a passing check in `checks/` go here, and only results here go into the paper (`sections/evaluation.tex`).

| Question | Claim to support | Task | Output | Check | Status |
|---|---|---|---|---|---|
| Q1 | Streaming MPM against full-domain MPM: cost against terrain size and number of environments, and whether the tile cache preserves terrain history | T1 | [outputs/T1.md](outputs/T1.md), section "Results on the unified code"; slides [site/T1/index.html](site/T1/index.html) | [checks/T1.md](checks/T1.md): P1, P2, P3 pass with caveats; lead spot-check of nine table cells against the raw files on 2026-11-19 agrees | merged 2026-11-19 with the caveats below; not from one commit yet |
| Q2 | Policies train across embodiments and tasks | T2 | [outputs/T2.md](outputs/T2.md) | [checks/T2.md](checks/T2.md): G1 object towing passes with caveats | G1 towing merged 2026-11-24; G1 walking, Go2, and UR10 have no checked result |
| Q3 | When training on particle simulation helps over rigid and RFT training: yielding terrain (slope and material) and object towing; hardware decides | T3 | [outputs/T3.md](outputs/T3.md) | [checks/T2.md](checks/T2.md) for towing and [checks/T3.md](checks/T3.md) for walking: both pass with caveats | towing and slopes merged 2026-11-24; material merged in part; hardware not checked |
| Q4 | Retired 2026-11-18; merged into Q3 | — | — | — | — |
| Q5 | Particle NeRD gives a net speedup and transfers to MPM (hardware optional) | T5 | — | — | no output yet |
| — | Gate: each deployed policy passed sim-to-sim before hardware | T6 | — | — | no output yet |

## Merged findings

### Q1 / T1: streaming MPM benchmark (merged 2026-11-19)

Conditions for every number: box probe (0.2 x 0.2 x 0.1 m, 10 kg), material `poppy_seed_loose`, voxel 0.03 m, sand depth 0.25 m, pool 1.2 x 1.2 m plus a 0.2 m ring, sparse grid, RTX 5090 (32 GB, also driving the desktop, about 1.7 GB in use), one run per configuration, seed 42. Runs were made on IsaacLab `65093be1c` and Newton `6fee8b0b` with uncommitted changes, committed afterwards as IsaacLab `0013a0c2b` / `ddb9459f5` and Newton `7adb5be7`.

**Cost against terrain size** (corridor 1.6 m wide, one environment, 3.2 to 102.4 m):
- Stream without cache does not grow: 1,094 MiB and 16.6 to 17.0 ms per step at every length.
- Stream with cache grows only by its saved sand: 1,222 MiB and 17.0 ms at 3.2 m, 1,862 MiB and 19.3 ms at 102.4 m.
- Full grows with the terrain: 1,286 MiB and 19.6 ms at 3.2 m, 16,410 MiB and 309 ms at 102.4 m, which is 15 times the memory and 18 times the step time of stream without cache.
- Sleeping roughly halves full's step time on long terrain (164.9 against 309.1 ms at 102.4 m) and costs memory (21,146 against 16,410 MiB). On the streaming modes it adds up to about 1.8 ms per step and 66 to 98 MiB, and saves nothing.

**Cost against number of environments** (8 x 8 m of terrain per environment):
- Largest count that ran: full 4 (2 with sleeping); stream without cache 64; stream with cache 64 (32 with sleeping). Counts were doubled, so each limit lies between that count and the next.
- Per environment at the largest count: full 6,321 MiB and 126 ms; stream without cache 327 MiB and 5.2 ms; stream with cache 451 MiB and 5.8 ms.

**Terrain history** (box on a lemniscate, two laps, sleep off):
- Height of the revisited track against full: 0.96 cm rms with the cache, which is the level of a repeated full run (0.83 cm); 4.97 cm median without the cache, where the track is lost.
- Drag on the revisited lap: full -26.7 N, with cache -29.4 N, without cache -54.3 N. The cache reproduces the drop in drag on revisit to within 10%; without it there is no drop.
- G1 on the same path: footprints are kept with the cache and lost without it. The percentages in the output depend on the reference level and are not merged.

**Caveats that limit what the paper can say:**
- **With sleeping on, the cache's force does not match full:** 31% low on fresh sand and 17% low on the revisited lap. The history result holds for sleep off only.
- **The history runs skip the cache's settled tile template**, by an override in the probe. The task as shipped uses the template, which makes fresh cached sand 43 to 57% stiffer in drag than a full bed.
- **Both streaming modes are softer than full on fresh sand:** 18 to 21% lower drag in the straight-drag debug check, 8 to 16% on the first lap.
- **Not from one commit.** The session reports that the commits differ from the run state only by formatting; that is not verified.
- **Not merged:** the comparison of grid types for full (unchecked; it suggests the fixed grid is a stronger full baseline, about 10 times the memory and 14 times the step time of stream without cache at 102.4 m instead of 15 and 18), and step times of the lemniscate runs.

### Q2 and Q3 / T2 and T3: G1 object towing (merged 2026-11-24)

Checked twice in `checks/T2.md` (first runs, then the rerun of 2026-11-24). Every number below reproduces from the raw trial files. Conditions: G1 tows a 15 kg, 0.3 m cube by a tether modelled as a one-sided spring and damper; three tow policies with one recipe, at their final checkpoints (W&B `aqiwzrv0` trained on rigid ground, `9733ux8d` on rigid ground and RFT, `her588wk` on rigid ground and MPM); 16 trials per cell (2 runs of 8, seeds 42 and 43); goal is 10 m of path; MPM sand is loose poppy seed (640 kg/m3, friction 0.73) on a 0.45 m bed, where no trial brings the feet within 2 cm of the rigid base; RFT sand has density 640 kg/m3, internal friction 0.73, and surface friction 0.73.

**The MPM-trained policy tows on MPM sand (T2).** Goals 16 of 16 at the 0.5 m/s and the 1.0 m/s straight commands. Forward velocity error 0.08 m/s at 0.5 m/s. At the 1.0 m/s command it does not reach the commanded speed: robot 0.69 m/s, cube 0.67 m/s, error 0.36 m/s. Training took 46.2 hours on 40 L40 GPUs.

**Sand resists the towed cube about twice as much as rigid ground (T3).** At a cube speed of about 0.47 m/s the horizontal pull is 103 N on MPM sand, about 50 N on rigid ground (42 to 55 N depending on heading), and 62 N on RFT sand (RFT-trained policy). The pull on MPM sand no longer changes with bed depth between 0.35 and 0.45 m at that speed.

**Goals reached out of 16, at 0.5 and 1.0 m/s straight (T3).**

| Tow policy | Rigid ground | RFT sand | MPM sand |
|---|---|---|---|
| Trained on rigid ground | 16, 16 | 0, 0 | 0, 0 |
| Trained on rigid ground and RFT | 16, 16 | 16, 16 | 0, 0 |
| Trained on rigid ground and MPM | 16, 16 | 16, 14 | 16, 16 |

**Lean (T3).** For the MPM-trained policy, from rigid ground to the MPM sands the tether tension rises from 60 N to 93 to 136 N, the torso lean from about 8 degrees to 17 to 23 degrees, and the pelvis from 14 cm to 22 to 32 cm ahead of the stance foot.

**Caveats that limit what the paper can say:**
- **Compare forces at equal cube speed only.** "124 N against about 50 N at the 1.0 m/s command" compares a cube moving at 0.67 m/s with one at 0.99 m/s and is not merged. No policy moves the cube faster than 0.67 m/s on this sand.
- **The baselines' failure on MPM sand is not about the cube.** They fall within about 1.5 s of starting to walk, with or without the tether, and after standing still on the sand first. A follow-up run by the T2 session on the 0.45 m bed (unchecked, 16 trials per cell, tether cut) splits the cause: the RFT walking policy `6t0h2ud8` stays up in 16 of 16 trials at both speeds while the tow policy trained from it stays up in 0, so for RFT the tow training on flat ground removed walking on this sand; the rigid walking policy `3qymp37c` already stays up in only 6 of 16 at 0.5 m/s and 0 of 16 at 1.0 m/s, so for the rigid baseline the failure is mostly in the walking policy itself on deep loose poppy seed.
- **The tether-cut control is not a clean walking test for the MPM-trained policy at 1.0 m/s:** without the cube it stays up in 2 of 16 trials on the 0.45 m bed. The clean three-policy contrast is at 0.5 m/s.
- **The tow policy was trained on a 0.25 m bed** and from the earlier walking policy `eayrj79r`, not from `aga5ovkp`.
- **Recipe differences between the three tow policies** remain (mirror loss on for the two baselines and off for MPM, among others); see the differences table in `outputs/T3.md`.
- **Provenance:** two code states appear within single tables, and the evaluation scripts are not committed.
- **Not merged:** the lap (history) result, the turning rows, the start-up peak (1.02 to 1.11 times steady on the final checkpoint, not 1.15 to 1.21), and anything on the slides that still shows the earlier checkpoint.

### Q3 / T3: walking on slopes and on softer sand (merged 2026-11-24)

Checked twice in `checks/T3.md` (first runs, then the final-checkpoint rerun). Every number below reproduces from the raw trial files. Conditions: G1 walking at a 1.0 m/s command; policies MJWarp `3qymp37c`, RFT `6t0h2ud8`, MPM `aga5ovkp`, all at iteration 19,999, run together in every workflow; evaluated in MPM on a 0.50 m sand bed unless stated; one training run per policy.

**Slopes on firm sand (beach sand, 1800 kg/m3, friction 0.80).** Goals reached uphill, 40 trials per cell from +15 to +30 degrees:

| Policy | +10 deg | +15 deg | +20 deg | +25 deg | +30 deg |
|---|---|---|---|---|---|
| MJWarp | 4 of 10 | 0 of 40 | 0 of 40 | 0 of 40 | 0 of 40 |
| RFT | 10 of 10 | 40 of 40 | 40 of 40 | 39 of 40 | 13 of 40 |
| MPM | 10 of 10 | 40 of 40 | 40 of 40 | 40 of 40 | 40 of 40 |

- MPM against RFT is separated at +30 degrees only (Fisher's exact test, p = 1.6e-11); at +25 degrees they are not separated. At +30 degrees the feet stay clear of the rigid base (1 of 120 trials within 2 cm).
- Downhill every policy reaches the goal; at -30 degrees MPM tracks worst (velocity error 0.28 against 0.22 m/s for RFT).
- On rigid ground the order reverses at the extremes: at +30 degrees MPM reaches 0 of 10 and MJWarp 9 of 10; at -30 degrees MPM 5 of 10 and MJWarp 9 of 10.
- At +20 degrees less sand moves under the MPM policy's sole than under RFT's (2.1 to 2.2 cm against 3.3 cm per stance, in every seed).

**Softer sand on level ground.** From hard ground to loose poppy seed, MJWarp tips its sole toes-down and falls in every trial on the two softest sands; RFT and MPM reach every goal on the 0.50 m bed. On a 0.65 m bed with loose poppy seed: MPM 12 of 12, RFT 9 of 12, MJWarp 0 of 12.

**Caveats that limit what the paper can say:**
- **MPM against RFT on materials is not separated in goals** (12 against 9 of 12 on loose poppy seed, p = 0.22). RFT's velocity error is 0.03 to 0.06 m/s higher on every sand regardless of softness: a small constant gap, not evidence that MPM copes better with softer ground.
- **The gap to MJWarp depends on bed depth.** MJWarp does worse on deeper beds and never stops changing with depth; training used a 0.25 m bed.
- **The slope runs start with a drop** onto the settled sand (4 to 10 cm). The +30 degree result has not been rerun without it; failures occur 4 s or more after the start.
- **The material ladder was run with 6 s settling and no drop, the setting in which dense sand does not yield under the foot.** MJWarp's numbers on dense sand differ between settings; the material figures mix bed depths, settling times, and start conditions, and the density-friction grid starts every sand from beach sand's settled bed. The material numbers are therefore not merged beyond the statements above.
- **Not merged:** per-sand velocity errors and gait quantities from the ladder, the density-friction grid, stance duration and peak-load comparisons, and anything from before the final checkpoint.
- **Hardware disagrees at 10 degrees:** every policy succeeded on a 10 degree slope on hardware, while MJWarp reaches 4 of 10 in this simulation.

**Update after the third check (merged 2026-11-24, `checks/T3.md` Check 3, pass with caveats).** The bed was found to keep compacting, and sleeping freezes it, so the tests were repeated in two bed settings on the 0.50 m bed, started on the settled surface: T (2.5 s settling, the task's sleeping) and W (12 s settling, sand near the robot awake). Statements are made only where T and W agree. This replaces the two caveats above on the start drop and on the material ladder's setting.

- **The +30 degree result does not depend on the start drop or on sleeping.** Goals at +30 degrees, MJWarp / RFT / MPM of 40: default start 0 / 13 / 40; on the surface with 2.5 s settling 0 / 9 / 40; with 6 s settling 0 / 18 / 40; W 0 / 1 / 40. MPM against RFT is separated in every setting (p from 8e-9 to 8e-22) and not at +25 degrees.
- **RFT's count at +30 degrees depends on the setting** (1 to 18 of 40), and so does its velocity error at +25 degrees (0.157 m/s in T, 0.260 in W).
- **Where MJWarp starts to fail depends on the setting:** at +15 degrees, 0 of 40 with the task's sleeping and 23 of 40 with the sand awake. The 4 of 10 at +10 degrees is not a firm result.
- **Less sand moves under MPM's sole than under RFT's in both settings** at +20 degrees: 2.2 against 3.5 cm (T, no drop), 1.5 against 2.6 cm (W).
- **Material ladder, level ground, 10 trials per cell, in both settings:** MPM 10 of 10 on every ground, velocity error 0.04 to 0.08 m/s; RFT 10 of 10 on every ground, 0.05 on hard ground and 0.09 to 0.13 on every sand; MJWarp 0 of 10 on loose poppy seed and walks on dense and beach sand. MJWarp on light sand and packed poppy seed differs between T and W and is quoted only with the setting.
- **Density-friction grid, each sand settled as itself, 5 trials per sand:** on the 14 sands whose bed holds in both settings (friction 0.7 and 0.9), MPM 70 of 70 and RFT 70 of 70 in both; MJWarp 54 of 70 (T) and 65 of 70 (W). RFT's velocity error is 0.03 to 0.13 m/s above MPM's on every one.
- **Low-friction beds collapse and are not material results.** The bed's own settling depends on friction only: 8 cm of 50 cm at friction 0.9, 30 cm at friction 0.1 (T). Friction 0.3 and below is excluded in T, 0.5 and below in W. The threshold (a third of the depth) was set after probing three friction values.

Caveats added by the third check:
- **Trials are not independent beds.** Each run has one bed template; only the robot start varies, and the grid uses the same five starts on all sands.
- **Whether the MPM-to-RFT error gap grows with softness is not settled:** it does not on the ladder; on the T grid it rises to 0.08 to 0.13 m/s at 250 kg/m3; W shows no trend.
- **Sampling density** (about 1.25 particles per cell edge) is a condition of every sinkage and sand-motion number; see `DECISIONS.md`, Open.
- **Still not merged:** gait quantities and sole-tip angles, the 0.65 m bed result in T and W, and the explanation of MPM's advantage, which T3's own rule does not pass in either setting.


### T8: MPM against DEM in a box drag (merged 2026-11-24)

Checked twice in `checks/T8.md` (pass with caveats). Every number below reproduces from the raw files. Conditions: box dragged at 0.5 m/s with its underside 6 cm below the mass-equivalent surface (one function for both simulators; 6.13 cm in MPM, 6.04 cm in DEM); MPM at task settings (3 cm voxel, about 1.25 particles per cell edge); DEM in Chrono DEM-Engine with material A calibrated to the task-sampled MPM sand; all runs on OSMO. No row of the results table depends on this section yet; it feeds the planned accuracy section.

- **Force.** MPM -59.4 N (four beds, -58.2 to -61.3). DEM -81.3 N with 15 mm grains (three seeds), ratio 1.37; -69.6 N with 9 mm grains (one run), ratio 1.17. The DEM force is still rising in the averaging window (9% over three seeds); on a longer bed the ratio is 1.42 (one run each).
- **Deformation.** Trench 8.0 cm in MPM against 6.0 cm in DEM. MPM builds no side berm (-0.2 cm); DEM builds 2.6 cm. The MPM bed sinks 0.4 cm far from the trench; the DEM bed does not move.
- **Moving sand.** 11.0 kg in MPM against 11.5 kg in DEM at equal depth; the moving zone is narrower in MPM (half-width 18 to 19 cm against 21 to 24 cm).
- **Voxel size.** At task sampling the MPM force goes from -68 N at 4 cm to -34 N at 1 cm.
- **Particle sampling.** At a 4 cm voxel the force rises from -68 N at 1.25 particles per edge to -155 N at 4 and -160 N at 5. With 1.6 or more per edge the bed keeps its density near 640 kg/m3 (700 to 780 at task sampling) and stops creeping in the tilt test; task-sampled sand creeps from 20 degrees.

Caveats:
- **No converged MPM value.** The voxel dependence persists when well sampled (factor 1.5 from 4 to 1.5 cm at 2 to 3 per edge). Well-sampled MPM holds slopes above its own 36 degree friction angle, so it is not a validated reference either.
- **Task-sampled sand is 2.3 to 2.8 times weaker in drag than well-sampled sand,** from single runs.
- **The calibration target is ambiguous:** DEM material A was matched to the task-sampled sand.
- **Most resolution and sampling points are single runs;** the four MPM beds share one grid alignment, and shifting the bed in z moves the force by up to 19%.
- **Vertical loading differs:** the MPM box presses with 222 N at the start of the drag (17 N after 5 cm; 2 to 3% of the force in the window); well-sampled runs carry up to 2090 N and reach depth only after about 0.2 m.
- **Provenance:** `~/isaac/dem_compare` (commit `e12656d`) has no remote.
