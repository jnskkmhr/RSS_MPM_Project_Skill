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

> **On hold (2026-11-24, finding from T1, confirmed by `checks/T1.md`, check of 2026-11-24).** The box forces in this section are read at one moment of a 50 Hz cycle caused by the stepwise target of the box's gantry, and are lower than the mean force on the box (by a factor of about 1.6 to 2.5 in T1's rerun). The rerun is not a repeat of the merged runs: it ran at a 4 cm voxel (an uncommitted change of `VOXEL_SIZE` from 0.03 to 0.04 in the worktree), the merged runs at 3 cm. In that rerun, with the force taken at every physics step (one run per mode): the drag on the revisited lap falls to 0.50 of the first lap for full, 0.47 with the cache, and 1.02 without the cache, so the history result holds in kind. "The cache reproduces the drop in drag to within 10%" does not hold: the cache is 15% below full on the mean force. On fresh sand the cache is 8% below full and no cache 30% below. Absolute forces are not physical drag values. Not affected: memory, step time, environment counts, height maps, G1 runs.

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

**Sweep over sands from stiff to soft (merged 2026-11-24, `checks/T2.md` Check 3, pass with caveats).** Three tow policies, 15 kg cube, 0.5 m/s command, 16 trials per cell, rigid ground and 12 MPM sands (friction 0.7 and 0.9, densities 250 to 3000 kg/m3, and the named sands), with the cube and with the tether cut; 0.6 m bed, 4 cm voxel, sand kept awake, 12 s settling, start on each sand's settled surface. One sand left out (feet near the base).
- **The MPM-trained policy walks and tows on every sand:** 16 of 16 on all 12, with and without the cube.
- **The RFT-trained policy walks on the 7 stiffer sands and falls when the cube is attached.** With the tether cut 110 of 112 trials stay up; with the cube 12 of 112 reach the goal (8, 1, 2, 0, 1, 0, 0 of 16 per sand). It tows 16 of 16 on rigid ground (60 N) and on RFT sand (73 N); on these MPM sands it meets 83 to 94 N.
- **The rigid-trained policy stays up on none of the sands.**
- **Torso pitch of the MPM-trained policy rises with tension and then saturates.** 8.5 degrees at 60 N on rigid ground, 15 to 20 degrees at 83 to 106 N, 17 and 19 degrees at 126 and 140 N on the two softest sands, where the cube slows to 0.44 and 0.36 m/s. Rank correlation of tension and pitch +0.84 over 13 grounds.
- **Loose poppy seed in this sweep:** pull 94 N against the 103 N merged above (8 to 9% lower); pitch agrees.

Caveats:
- **"The RFT policy fails because sand resists more" is not shown.** Attaching the cube causes the falls, but the policy is already marginal on these sands without load: it walks at 0.63 to 0.71 m/s for a 0.5 m/s command with 13 to 15 degrees of torso pitch against 5.6 degrees on rigid ground. Its falls are forward pitch-overs; the tension is 55 to 70 N until 1.5 s before the fall. Goals fall with tension (rank correlation -0.95) but only over 83 to 92 N, and equally with sinkage and with overspeed. The missing control is a lighter cube on sand and a heavier cube on rigid ground or RFT sand.
- **The lean is not only a response to tension.** With the tether cut the MPM-trained policy's pitch already rises with softness (9 to 15 degrees); the extra pitch from the cube does not follow tension.
- **The baselines tow on too few grounds** (rigid 1, RFT 2) to say whether their pitch adapts less.

**Load control: is it the tension or the ground? (merged 2026-11-24, `checks/T2.md` Check 4, pass with caveats).** RFT-trained and MPM-trained tow policies, 0.5 m/s command, 16 trials per cell, same settings as the sweep; lighter cubes on the 7 stiffer MPM sands, heavier cubes on rigid ground and RFT sand.
- **The RFT-trained policy carries on other grounds the tension it falls under on MPM sand.** Rigid ground: 16 of 16 with 21 kg (83 N), 11 of 16 with 24 kg (95 N, the rest at the time limit); RFT sand: 16 of 16 with 18 kg (88 N) and with 20 kg (98 N); no fall in these 64 trials. MPM sands: 111 of 112 with 8 kg (41 to 47 N), 92 of 112 with 10 kg (53 to 60 N), 12 of 112 with 15 kg (83 to 94 N); every miss is a fall.
- **Its falls on MPM sand grow with the load,** on every sand; the step from 10 to 15 kg is clear everywhere.
- **Why it falls there:** on MPM sand it walks faster than commanded and pitched forward (cube at 0.66 to 0.80 m/s for a 0.5 m/s command and 21 to 28 degrees of torso pitch with the 8 and 10 kg cubes), so a tow load it carries elsewhere tips it over. Its start-up pelvis pitch peaks at 22 to 29 degrees without the cube, 31 to 38 degrees with 10 kg and 41 to 44 degrees with 15 kg, against a fall limit of 45 degrees. The tension before a fall is no higher than what it survives.
- **The MPM-trained policy tows every cube on every MPM sand,** 16 of 16, at 0.53 to 0.56 m/s with 14 to 17 degrees of pitch.
- **Not supported: "the RFT-trained policy fails because MPM sand needs more force than it can produce."** The data contradicts it as the mechanism.
- **Goal definition.** A goal counts 10 m of robot path, not net distance. On RFT sand the MPM-trained policy's "goal" trials moved 6.3 m net with 15 kg, and 4.7 and 3.7 m with 18 and 20 kg (12 of 16 goals, cube at 0.10 to 0.12 m/s). "The MPM-trained policy works on RFT sand" in the goals table above holds as "stays up", not as towing the cube 10 m.
- Compared speeds are unequal in the heavy-cube cells (0.29 to 0.43 m/s).
- **Goal cells without real transport** (T2's computation from the saved trials, not yet checked; a goal trial counts as "not transport" when the cube's net travel is under 8 m, threshold fixed beforehand). In the goals table of the three policies: the MPM-trained policy on RFT sand at 0.5 m/s straight (16 of 16 goals, cube net travel 6.0 m) is the only straight cell; its 1.0 m/s cell there and every goal on rigid ground and on MPM sand have the cube above 8 m. In the sand sweep: on the softest usable sand (250 kg/m3, friction 0.9) 5 of the MPM-trained policy's 16 goals are below 8 m; every other cell with goals has a mean cube travel of 9.1 m or more, with no single goal trial under 8 m. Turning cells are not transport along a path (the cube pivots, 0.3 to 1.4 m).

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


**Why and how on slopes (merged 2026-11-24, `checks/T3.md` Check 5, pass with caveats).** Beach sand, 0.50 m bed, default start, 10 trials per cell; failed trials are included up to the fall.
- **More sand moves downhill under the loaded foot on steeper slopes, and the policies rank by it.** Motion of the sand within 3 cm under the sole, from dug-in to lift-off (median over that sand), at +10 / +20 / +30 degrees: MJWarp 2.0 / 5.0 / 10.8 cm, RFT 1.4 / 3.6 / 6.6 cm, MPM 1.0 / 2.2 / 5.2 cm; about 0 on level ground. Rank correlation with slope above 0.9 for every policy. MJWarp's values are from the stances before it falls (6 trials at +10 and +20 degrees; its +30 degree value rests on 2 trials and 6 stances). RFT's +30 degree value includes 7 failing trials.
- **Sand under MPM's sole moves 20 to 40% less than under RFT's,** in every seed and in all four bed settings; it is about a third lower for both with the sand kept awake.
- **Sole angle.** MJWarp holds the sole toes-down: 24 degrees on level ground (15 degrees with the sand kept awake), 44 degrees at +10, 57 degrees at +20. RFT and MPM hold it within 3 degrees of level on level ground and 26 and 28 degrees toes-down to the slope at +20 (6 and 8 degrees below level); both about 20 degrees below level at +30.
- **Motion of the sole during stance.** Over the whole stance, from the first to the last sample above 20 N, the bearing point of MJWarp's sole moves at 0.53 to 1.03 m/s on every slope (0.29 m/s on level ground with the sand kept awake); for RFT and MPM 0.11 to 0.16 m/s on level ground, and 0.84 and 0.70 m/s at +30 degrees. This does not show that MJWarp's foot never comes to rest: while it carries at least half the body weight it moves at 0.25 m/s on level ground. No order between RFT and MPM at +30 degrees is claimed.
- **Failure types.** MJWarp's 47 failed uphill trials: 25 collapses with the pelvis too low, 19 falls forward, 2 sideways, 1 lane exit. RFT's 7 failures at +30 degrees: 6 falls forward, 1 lane exit.
- **Step timing does not differ uphill:** from +10 degrees all three step in 0.19 to 0.24 s with 0.20 to 0.25 m steps.
- **Not merged, not supported by the check:** "RFT's foot grips and the sand carries it, MPM's foot slides over the sand". The sand and slide terms do not sum to the foot's motion without a dig-in term; MPM's 3.1 to 3.5 cm of slide is its toe moving at the lightly loaded end of stance; above half body weight MPM's foot moves 2.4 cm against RFT's 4.7 cm at +20 degrees; and with the sand kept awake the contrast vanishes at +15 degrees. No measured behaviour explains why less sand moves under MPM's sole than under RFT's.

**Stance foot velocity (merged 2026-11-24, `checks/T3.md` Check 6; a description, not a quality measure).** Horizontal speed of the sole centre between consecutive 50 Hz samples at both of which the foot carries more than 20 N; mean over the trials that reach the goal; 0.50 m bed, 10 trials per cell. The two paper figures (`t3_slope_1x3_final.pdf`, `t3_material_1x3_final.pdf`) plot it; all 57 plotted cells reproduce.
- **Level beach sand:** 0.53 / 0.12 / 0.13 m/s (MJWarp / RFT / MPM); 0.01 m/s for all three on rigid ground. MJWarp's is the highest on every sand it walks on, in both bed settings.
- **It grows with softness and with slope:** RFT 0.07 to 0.64 and MPM 0.05 to 0.85 m/s from (3000, 0.90) to (640, 0.73); RFT 0.12 to 0.27 and MPM 0.13 to 0.35 m/s from level to +20 degrees; 0.56 m/s for both at +30 degrees, RFT on 3 trials.
- **Limits:** with the sand kept awake the values are 0.3 to 0.8 times these; the value includes the lightly loaded start and end of stance and rises by up to a factor of 1.9 if the touchdown and lift-off intervals are counted.
- **Under more than half the body weight,** on level ground RFT's and MPM's sole moves at 0.04 to 0.21 m/s on every sand and MPM's not faster than RFT's; uphill MPM's moves faster than RFT's (0.39 against 0.20 m/s at +20 degrees).
- **Not supported:** reading it as "lower is better"; ranking RFT and MPM by it; "MPM's foot slips more than RFT's on soft sand"; using it to explain the velocity error.
- The success-rate panels use 10 trials per point, so RFT's 30% at +30 degrees is 3 of 10 trials (13 of 40 with further seeds).

**Sand flow under the foot across materials (merged 2026-11-24, `checks/T3.md` Check 4, pass with caveats).** Level ground, awake bed (12 s settling), 10 trials per cell, 170 to 247 footprints per cell.
- **More sand leaves from under the sole on softer ground.** Sand that left the column under the sole per stance, MJWarp / RFT / MPM, in litres at nominal density: dense sand 0.16 / 0.17 / 0.18; beach sand 0.39 / 0.33 / 0.37; packed poppy seed 0.83 / 0.49 / 0.51; light sand 1.08 / 0.79 / 0.79; loose poppy seed none / 1.53 / 1.33 (MJWarp falls). These volumes are overstated by 22 to 50%, because the settled bed is denser than nominal.
- **RFT and MPM move the same amount of sand,** and on dense and beach sand all three policies do, while their velocity errors differ (0.11, 0.13 and 0.05 m/s on dense sand). The tracking gap between RFT and MPM has no measured cause.
- **Nothing rises beside the foot** (0.00 to 0.08 L), and around the footprint 65 to 88% of the sunk volume is compaction, a density rise that reaches the bed base. This is the compaction of the sparsely sampled bed.
- **Whether a policy's degradation follows flow is not shown.** Flow and sinkage have the same rank order over the grounds, the test has four to six grounds, and there are no footprints where MJWarp falls. Not merged: the rank correlations, and how much more sand MJWarp moves where it fails.

### T8: MPM against DEM in a box drag (merged 2026-11-24, revised after round 6)

Checked seven times in `checks/T8.md` (pass with caveats each time). Conditions: box 0.2 x 0.2 x 0.1 m dragged at 0.5 m/s with its underside 6 cm below the mass-equivalent surface (one function for both simulators); sand preset `poppy_seed_loose`; DEM in Chrono DEM-Engine, material A (three-sphere clumps, 15 mm unless stated); all runs on OSMO. Two MPM discretizations: task settings (3 cm voxel, about 2 particles per cell, 5 ms step, 25 iterations), where policies train, and tuned settings (8 particles per cell, step scaled with the voxel, 250 iterations).

**Deformation.**
- **Tuned MPM reproduces the surface deformation of DEM.** At 1 cm: trench 5.7 against 6.1 cm, side berm 2.8 against 2.4 cm, correlation of the height-change maps 0.95, the level of one DEM seed against another (0.96 to 0.97). The bed does not compact (it stays at 640 kg/m3) and does not creep.
- **At task settings the deformation differs.** Trench 8.0 against 6.0 cm, no side berm (-0.3 against 2.6 cm), map correlation 0.85; the bed compacts from 640 to about 731 kg/m3, sinks during the drag, and creeps from a 20 degree tilt.
- **Tuned MPM sand is stronger at rest than specified:** it slides at 40 degrees, above the preset's 36 degrees and DEM A's 32.5 degrees. About 30% less sand moves in tuned MPM than in DEM.

**Force on the box (round 4, check 4: pass with caveats).** The MPM box forces of rounds 1 to 3 were recorded at the last physics step of each 20 ms control step, while the gantry target jumped once per control step; the box speed cycled (0.58 to 0.40 m/s on the stiff gantry) and the recorded value was the lowest of the cycle (-31 N recorded against -84 N over all physics steps at task settings). Those forces and the ratios DEM / MPM of 1.37, 2.3 and 1.58 are withdrawn. The forces below are from runs with the gantry target moved every physics step (box speed constant within 0.3%, height within 0.09 mm) and are the mean over all physics steps for drag distance 0.5 to 1.0 m; DEM is averaged over the same window. The recorded force equals the force implied by the gantry spring and the box motion within 0.01 N.

| MPM setting | MPM drag force | DEM A (15 mm) | MPM / DEM A | MPM / DEM B (one run) |
|---|---|---|---|---|
| Task settings, 3 cm (4 alignments); DEM at 733 kg/m3 | -86.7 N | -79.4 N | 1.09 | 0.80 |
| Tuned, 4 cm (4 alignments); DEM at 640 kg/m3 | -168.4 N | -71.1 N | 2.37 | 1.70 |
| Tuned, 2 cm | -123.1 N | -71.1 N | 1.73 | 1.25 |
| Tuned, 1 cm | -94.9 N | -71.1 N | 1.34 | 0.96 |
| Tuned, 0.75 cm (two single runs) | -86.4, -86.7 N | -71.1 N | 1.22 | 0.88 |

- **At task settings MPM and DEM A agree within about 10%** (1.09; 1.13 on the 2.4 x 1.2 m bed, one run). This is the only row in which the DEM material was calibrated to the MPM sand. The MPM bed is 1.5% lighter and its surface sinks 0.4 cm during the run.
- **The tuned MPM force is not converged in voxel size:** -168.4 / -148.1 / -123.1 / -105.0 / -94.9 N at 4 / 3 / 2 / 1.5 / 1 cm (steps of -12 to -17%, -10% on the last) and about -86.5 N at 0.75 cm. Grid alignment moves it by 14 to 23% at one voxel size. No limit can be extrapolated: fits give 35 to 90 N depending on the assumed order.
- **Tuned MPM is above DEM A at every voxel size, but A is not its matched material.** Tuned sand slides at 40 degrees, DEM A at 32.5, DEM B at 37.5. Against B at the same density the ratio falls from 1.70 at 4 cm through 0.96 at 1 cm to 0.88 at 0.75 cm.
- **Solver settings at 1 cm (one run each):** 1000 iterations +2%, 25 iterations -5%; half the time step +4%, twice -4%. The time step is not converged.
- **Gantry:** at constant speed the force changes by at most 4% from 1e6 to 1e7 N/m; the T1 gantry (1e5 N/m) gives +8% at task settings. The factor of 1.7 to 1.9 reported after round 3 was the recording artefact, and so was the reason given for withdrawing round 2's dense-sampling forces.
- **Not steady:** the force rises 5 to 7% across the window in MPM and 5% in DEM A at 733 kg/m3.
- **Open:** dependence of the MPM force on the box mass (the sand solver treats the box as a free 10 kg body within a step; not tested); the saved joint velocity reads 0.2 to 3.8% below the box's position rate, cause not identified; DEM is not converged in grain size (-71.1 N at 15 mm, -63.5 N at 11 mm).
- **Effect on T1:** T1's box forces were recorded the same way and are too low by a factor that depends on the gantry (1.6 on the T1 gantry, 2.7 on a stiff one at task settings). They need the corrected recording before use.

**Other motions (round 5, corrected; checks 5 and 6).** The same box in four motions, each in MPM and in DEM material A at the matching bed density: horizontal push (1 m), push downward to a set depth, push upward out of the sand, and a 90 degree twist at fixed depth; two speeds and two depths each, three MPM beds and three DEM seeds, MPM at task settings (3 cm) and tuned (1 cm, 8 particles per cell). The box is at the same depth (within 0.7 mm), speed, angle and timing in both. Cases and metrics were committed before any comparison existed. After check 5 the cells that the box covers are left out of every map measure in both simulators, because about 800 of 2,000,000 MPM particles rest up to 1.4 mm inside the box faces and set the surface height of those cells; penetration is reported only where it is a result.

Tuned MPM against DEM, error relative to DEM, mean over the pairs of one MPM run and one DEM seed, with DEM seed against seed in brackets:

| Quantity | Horizontal push | Push downward | Push upward | Twist |
|---|---|---|---|---|
| Dispersion: displacement of the sand by 4 cm cube | 27% (15%) | 33% (21%) | 61% and 64% from 6 cm (41%, 35%); 3 cm case too small to measure | 42% (25%) |
| Deformation: berm or rim height | 12% (7%); 2.2 against 2.0 cm | 20% (6%); 0.7 against 0.8 cm | 13% (10%); 0.7 against 0.7 cm | 60% (14%); 1.25 / 1.35 / 1.47 against 1.01 / 0.98 / 0.72 cm |
| Penetration: trench or residual pit depth | 7% (3%) | depth is commanded | 25% (4%), upper bound; 3.3 against 4.2 cm | depth is commanded |
| Height-change map outside the box, correlation | 0.97 (0.98) | not informative | 0.90 (0.91) | not informative |

- **Tuned MPM is above the DEM seed-to-seed level in the displacement of the sand in every motion** and closest in the horizontal push. The seed-to-seed level is a generous reference (it carries the grain noise twice and contains neither grain size nor material).
- **Twist:** MPM piles sand at the corners of the turning box, 0.2 to 0.8 cm higher than DEM. The excess is confined to the 4 cm ring the corners sweep; one cell further out the rim agrees at the DEM seed level (14% against 14%). DEM with 15 mm grains does not resolve that ring.
- **Pull-out:** the tuned MPM sand moves 0.50 and 0.39 of the DEM displacement during the lift (6 cm cases). The pit floor is at the same depth (5.8 against 5.9 to 6.1 cm); the footprint mean is 0.8 to 1.2 cm shallower in MPM, of which a part of the order of the grain radius is the DEM surface measure on the sloping pit wall.
- **Press and twist maps:** outside the box the surface changes by about 1 cm, the cell noise of a DEM map with 15 mm grains; map correlation there does not distinguish the simulators and is not reported. The first-version results "press penetration error 42%" and "twist map error 82%, correlation 0.63" were artefacts of the box cells and are withdrawn.
- **Task settings** are further from DEM in the displacement in every motion (44 / 67 / 103 / 69%) and build no berm or rim (-0.3 to -0.1 cm against 0.7 to 2.1 cm).
- **Paper figure `t8_mpm_dem_stats.pdf`** (redrawn after check 6): penetration, deformation, dispersion; tuned MPM; hatched DEM seed level. Deformation there is the berm or rim height one cell away from the box, so that it does not hinge on the ring the corners sweep: 12% (7%) / 23% (10%) / 14% (12%) / 14% (14%) for push, push downward, push upward, twist. The twist value was confirmed by check 6; the other three are the T8 agent's recomputation with that measure and have not been rechecked (check 6 found them unchanged by excluding one more ring). Push-upward dispersion in the figure is from the 6 cm cases, 62% (38%). Error bars: spread within a case; dots: case means.

**Fixed-weight press (round 6; check 7, pass with caveats; website only).** The box (0.2 x 0.2 x 0.1 m, 10 kg) rests on the sand, is free vertically in both simulators and is pressed by a set total load of 50, 150, 350 or 700 N (1.25 to 17.5 kPa; a G1 sole is about 14 kPa in double stance and 29 kPa in single stance). Three beds or seeds per case, 48 runs. That the box is free was checked from its motion (sand force equals load plus mass times acceleration throughout) and at rest (within 0.11%).

| Total load | MPM task settings (3 cm) | DEM A, 733 kg/m3 | MPM tuned (1 cm) | DEM A, 640 kg/m3 |
|---|---|---|---|---|
| 50 N | 1.64 cm | 0.10 cm | 0.06 cm | 0.07 cm |
| 150 N | 3.46 | 0.21 | 0.09 | 0.22 |
| 350 N | 6.81 | 0.47 | 0.18 | 0.53 |
| 700 N | 9.49 | 3.38 | 0.60 | 4.77 |

- **Task-setting MPM compacts under load.** It sinks 13 to 17 times deeper than DEM up to 350 N and is still sinking after 2 s (0.1 to 0.3 cm in the last 0.5 s). Nothing rises around the box; the density under it rises by about a quarter at 350 N. About 0.4 cm of each value is the bed settling by itself during the run.
- **DEM A gives way between 350 and 700 N, with heave,** where a bearing-capacity estimate for a 32 deg sand of this density puts it (about 450 to 850 N). Its light-load sinkages follow a pre-press of up to 77 N during placement. One grain size (15 mm).
- **Tuned MPM carries 700 N with 0.6 cm.** This is below the failure load expected for its 40 deg sliding angle (1.6 to 3.4 kN) and for the specified 36 deg, so the difference from DEM A at 700 N is the known mismatch of the two materials. Not converged in the voxel (0.28 cm at 2 cm against 0.18 cm at 1 cm, 350 N, one run).
- Not established: which of sampling, iteration cap and time step causes the compaction under load; DEM grain-size dependence. In DEM the load rose in 0.4 s and acted 1.9 s (MPM: 0.5 s and 2.0 s).
- **For the paper's limitations:** at the training discretization the sand compacts under a static foot-sized load and overestimates sinkage by an order of magnitude against DEM.

Caveats:
- **Neither simulator is the truth,** and there is no experiment.
- **Provenance:** `~/isaac/dem_compare` (commit `d52aa4d`) has no remote.
