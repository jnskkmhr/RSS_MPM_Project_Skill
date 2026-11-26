# Check (2026-11-25/26): foot margin fix and convex-collider option, before the walking retrains

- **Checker / date:** Claude agent, independent checker session (did not produce the fix), 2026-11-25 about 22:50 to 23:35 PST.
- **Scope:** `outputs/T2.md` block T2-MARGIN; `outputs/T5.md` 10h, 10i; unified worktree `~/isaac/worktrees/mpm-unification/IsaacLab` (HEAD `0007b2e67`, dirty), Newton `48231a98`; OSMO workflows `g1-mpm-mixed-cache-fix-1` and `g1-mpm-mixed-no-cache-fix-2` and their code snapshots.
- **Verdict:** **let the cache training run; relaunch the no-cache training unchanged, but note the points under Issues.** Nothing in the fix, the mechanism or the setup argues for cancelling. `g1-mpm-mixed-no-cache-fix-2` is **not running**: it FAILED at 23:18 PST while importing the task packages (a file of the code snapshot did not arrive on 11 of 40 trainers; not the fix). `g1-mpm-mixed-cache-fix-1` showed all 40 trainers RUNNING at 23:27 PST; its learning progress was not read (log stream timed out).

## Per item

| # | Item | Result | Evidence |
|---|---|---|---|
| 1 | Mechanism: margin reaches the sand only | **confirmed** | Newton reads `shape_margin` in one place of the implicit MPM (`implicit_mpm_model.py:211`, `_get_shape_collision_materials`), called only from `setup_collider`, which runs in the model's constructor (`:335`) and through `SolverImplicitMPM.setup_collider` (`solver_implicit_mpm.py:2190`); nothing in IsaacLab calls the latter. `material_thickness` and `collider_max_thickness` are assigned only there. `notify_model_changed` refreshes particle materials only (`:3299`); reset, streaming and the tile cache do not touch them; `query_max_dist` is changed temporarily in two places and put back. Sleeping wake distance defaults to 2 voxels, independent of shape margins. In the coupled setup `MPMSolver.build` receives the sand entry's `ModelView`; its `shape_margin` is a separate array from the full model's (pointers differ, measured). Measured during the MPM constructor: the view holds {0, 0.02}, the full model {0} on every shape. The rigid collision pipeline and MJWarp read the full model and the rigid entry's view, never written. The restore is in a `finally`. Rigid-tile environments get 0.02 in the sand solver too (before: 0); they hold no particles (`_set_contact_margin` raises otherwise), so it has no effect. |
| 2 | Scene: entry kept with `contact_margin=0.0`; asset untouched | **confirmed** | `git status` and `git diff HEAD -- source/isaaclab_assets`: empty. Against the code snapshot `aga5ovkp` was trained on, `streaming_scene_cfg.py` differs in that value and a comment only. Resolved: `collision_props = {"/.*_ankle_roll_link/.*": [(margin 0.0, gap 0.0)]}`. |
| 3 | `_set_contact_margin` | **confirmed** | Writes `rigid_contact_margin` (0) on every shape of the foot bodies in every environment, on the builder at `MODEL_INIT`. Run time: full model, rigid entry view and MuJoCo `geom_margin` are 0 for all geoms; `includemargin` of every MJWarp contact that involves a foot is 0 in every step of both probes. |
| 4 | Own probe | **confirmed**, numbers below | |
| 5 | Foot shapes | **confirmed, with a clarification** | The MESH shape of each `ankle_roll_link` is the link's visual mesh: visible, no `COLLIDE_SHAPES`, no `COLLIDE_PARTICLES`, margin 0. It comes from the asset, is in the rigid and RFT tasks too, and collides with nothing. The sand sees one collider per foot with one material (the box), thickness 0.02. The pattern sets 0.02 on both shapes for the construction; only the box is a collider. |
| 6 | `convex_collider_bodies=[]` | **confirmed for the mixed task; fixed-bed preset not built** | "Static" in `classify_convex_colliders_as_meshes` means `builder.shape_body < 0` on the full builder, after replication. The mixed task has 2 static shapes (terrain, `mpm_ground`), both MESH already. Sand colliders: 2 foot boxes per robot and 1 static collider; no hull among them. In the sand entry's view the other links appear as static CONVEX_MESH shapes, but the view clears their collision flags, and the solver builds and steps (a CONVEX_MESH collider would raise in this Newton). Patterns: full match on the body label, error on no match, empty list is a no-op loop. No error found in the patch logic. |
| 7 | Sameness of the setup | **confirmed, with two notes (issues 2, 3)** | Below. |
| 8 | Other differences to the code of `aga5ovkp` | **none found in the walking task** | Below. |
| 9 | Tow preset | state only | `physics_cfg.py` of the tow task: the `collider_margins` line, no `convex_collider_bodies`. Feet entry 0.0. The sled keeps `contact_margin=FOOT_CONTACT_MARGIN` in the scene and `tow_mixed_env.py` still writes 0.02 (sand) / 0 (rigid) on it as a shape margin, so the sled's rigid contact still starts 20 mm early in sand environments. |
| 10 | Robot collision geometry, MPM tasks against rigid and RFT tasks (added by the lead) | **same geometry; the type differed for `aga5ovkp`, not any more** | Below. |

## Probe (mine; local RTX 5090, policy `aga5ovkp` 19,999, one reset half-way)

Script `probe.py` in the scratchpad; reads the models, MuJoCo's own arrays and the MJWarp contacts, and records what the MPM constructor sees.

| | no cache, 8 environments, 300 steps | cache, 4 environments, 240 steps |
|---|---|---|
| Voxel / particles per cell / depth | 0.04 / 1.25 / 0.25 | same |
| Foot box margin: full model, rigid entry, sand entry (after build and after the walk) | 0 / 0 / 0 | 0 / 0 / 0 |
| MuJoCo `geom_margin`, all geoms | 0 | 0 |
| Sand collider thickness of the feet, sand / rigid-tile environments | 0.02 / 0.02, 1 material per foot | 0.02 / 0.02 |
| Static sand collider (`mpm_ground`) thickness | 0 | 0 |
| During MPM construction: view / full model margins | {0, 0.02} / {0} | not captured (the cache builds a second, helper solver of 5 shapes afterwards, which my hook recorded instead) |
| Ankle pitch on sand: min / 1st / 5th / median [rad], share below -0.50 | -0.89 / -0.87 / -0.82 / -0.57, 0.59 | -0.92 / -0.85 / -0.79 / -0.51, 0.52 |
| Ankle pitch on rigid tiles | -0.87 / -0.74 / -0.70 / -0.53, 0.57 | -0.90 / -0.87 / -0.79 / -0.59, 0.70 |
| Shin-foot MJWarp force, share of robot steps above 1 N / max | 0 / 0 N | 0 / 0 N |
| Shin-foot candidate contacts: steps listed, smallest distance | 45 of 300, 8.0 mm, none penetrating | 11 of 240, 8.6 mm |
| Terminations (falls) | 0 | 0 |

Agrees with T2's tests 1 and 2. Old code for reference (Check 3 of `checks/T5.md`): force above 1 N in 99% of sand robot steps, ankle stopped at -0.46 rad. Not measured by me: travel per robot (T2: 1.5 to 4.3 m), sole depth and foot force (T2's test 3).

## Setup against `aga5ovkp` and `cfbj8jpx` (items 7, 8)

Snapshots are in object storage (`swift://…/mpm-moving-patch/runs/snapshots/`), not on this machine. I downloaded the Python, stub, TOML and USDA files of four of them (`osmo data download`, read-only) and the Newton `_src` tree of each: the two new ones, `20261121T234409Z-9Zmvu3i0Sy` (`aga5ovkp`) and `20261122T213850Z-yqMqHHb7Ai` (`cfbj8jpx`).

- **New snapshots = working tree.** All 2,975 files of the cache snapshot and 2,974 of the no-cache snapshot are byte-identical to the worktree now, Newton's 463 files to the local Newton; the 14 hashes of `sha256.txt` verify. The two snapshots are identical to each other (one file missing from my no-cache download, see issue 1).
- **Voxel size, particles, material: equal to the reference runs.** Both reference configs log voxel 0.04 (solver and sand), 1.25 particles per cell, depth 0.25 m, density 640, friction 0.73. The new runs resolve to the same. The uncommitted `VOXEL_SIZE 0.03 -> 0.04` is against HEAD only: the snapshots of `aga5ovkp` and `cfbj8jpx` already contain 0.04 and `FOOT_CONTACT_MARGIN = 0.02`.
- **Walking-task code against the `aga5ovkp` snapshot:** differs in `mpm_solver.py`, `mpm_solver_cfg.py`, the three lines of the fix in `physics_cfg.py`, `scene_cfg.py`, `streaming_scene_cfg.py`, the mixed environment (fix) and `commands_cfg.py` (`rel_standing_envs` 0.2 -> 0.0, overridden back). `mpm_env_cfg.py` (fixed bed, not used) and `scene_cfg.py`'s `MATERIAL_NAME` (fixed bed) also differ. Rewards, terminations, events, observations, terrain generator, curriculum, the streaming environment, the PPO config, `isaaclab_rl` and the core are identical. The `cfbj8jpx` snapshot equals the `aga5ovkp` one in these files. Other differing files are tow, `speed_bench` and deprecated tasks.
- **Newton:** identical to `cfbj8jpx`'s; against `aga5ovkp`'s it differs in 8 lines of `particle_cache.py` (size of the cache's record store), which the no-cache preset does not use.
- **Workflow specs** (`osmo workflow spec`, read-only): 40 trainers, 64 environments, same image and script as the reference specs; the only differences are the run name, the snapshot URLs, the added `env.commands.base_velocity.rel_standing_envs=0.2`, and no `--checkpoint` on the cache run. Asset archive: the same hash as for `aga5ovkp`.
- **Resolved with the submitted overrides, both presets:** 64 environments, sand fraction 0.5, `rel_standing_envs` 0.2, seed 42 (environment and agent), 24 steps per environment, learning rate 0.001, `max_iterations` 20,000, `resume` False, dt 0.005, decimation 4, episode 20 s.
- T2's list of 47 and 48 differing config entries: read in full; all are paths, names, run-time values or the viewer backend, except the three entries of the fix.

## Item 10: collision shapes per link, built models (2 environments each)

| Links | MPM mixed, new code | MPM mixed, all hulls relabelled (HEAD, `aga5ovkp`, `cfbj8jpx`) | Rigid task | RFT task |
|---|---|---|---|---|
| 22 links: hip pitch/roll/yaw and knee (both legs), pelvis contour, torso, head, logo, shoulder yaw, elbow, wrist roll/pitch/yaw (both arms) | CONVEX_MESH, 64 vertices, 124 faces | MESH, same 64 vertices, 124 faces | CONVEX_MESH, 64 / 124 | CONVEX_MESH, 64 / 124 |
| Shoulder pitch and roll (4) | CYLINDER | CYLINDER | CYLINDER | CYLINDER |
| `ankle_roll_link` (2) | BOX, margin 0, gap 0 | BOX, gap 0 (margin 0.02 on sand in the old code) | BOX, margin 0, gap 0.01 | BOX, margin 0, gap 0.01 |
| pelvis, ankle pitch, waist yaw/roll, rubber hands | no collider | no collider | no collider | no collider |

- (a) The dictionary does not restrict collision to the feet. It authors margin and gap on the prims under `ankle_roll_link` and leaves every other link's collider as in the USD (22 `convexHull` tokens).
- (b) The asset's `mesh_approximation_name="none"` does not give triangle meshes in the rigid and RFT tasks: the built models hold the same convex hulls.
- So the geometry (vertices) is the same in all tasks. What differed: in the committed code and for `aga5ovkp` and `cfbj8jpx`, the MPM solver's `prepare_builder` relabelled all 22 hulls per robot as triangle meshes, so link-against-link and link-against-ground contact used the mesh routine in the MPM tasks and the convex routine in the baselines' tasks. With `convex_collider_bodies=[]` the MPM walking tasks now use the same type as the baselines.
- Remaining difference: the foot box's contact gap, 0 in the MPM tasks and 0.01 in the rigid and RFT tasks (then and now). With margin 0 on both sides MJWarp's `includemargin` is 0; I did not test whether the gap changes anything beyond which candidate contacts are listed.
- The relabelled column was built with the present code and `convex_collider_bodies=None`, which is what the removed loop did.

## Issues, by severity

1. **The no-cache training is not running (infrastructure).** `g1-mpm-mixed-no-cache-fix-2` FAILED at 23:18:31 PST: `ImportError: cannot import name 'CameraCfg' from 'isaaclab.sensors'` on 11 of 40 trainers while the task packages were imported. `isaaclab/sensors/__init__.pyi` (the lazy-import stub) is listed in the snapshot, but my bulk download of that snapshot also came without exactly this file, and a second, targeted download returned it. Inference: the object was intermittently not delivered. Needed: relaunch through the launcher so that a new snapshot is uploaded, with the same arguments, and check on a trainer that the file is there. Not caused by the fix.
2. **The runs differ from the references in two things, not one.** Besides the margin, the 22 link hulls per robot are now collided as convex hulls, in sand and rigid-tile environments alike. Decided by Junnosuke (`DECISIONS.md`, 2026-11-25); the evidence that walking is unchanged is T5 10i (one seed, 16 robots, unchecked). Any comparison with `aga5ovkp` should say "margin fix and convex links".
3. **Cache run: 20,000 iterations from scratch.** `cfbj8jpx` ends at 24,500 (resumed at 4,500 from `gk4b6ci0`, plus 20,000). Compare at equal iterations, or extend the new run by 4,500.
4. **`rel_standing_envs=0.2` exists only on the command line.** The worktree default is 0.0. Every relaunch or resume must carry the override; the T2 relaunch table should record the full command.
5. **Mixed environment: silent loss of the sand margin is possible.** `_init_sim` replaces the preset's values by `mpm_contact_margin` (`dict.fromkeys(preset keys)`). With a preset that has no `collider_margins` the result is `{}` and the sand gets margin 0 without an error. Not the case for the presets used. Also, the preset's literal 0.02 is not the value that acts in the mixed task (`mpm_contact_margin` is); they are equal today.
6. **Tow:** sled margin still a shape margin (item 9); tow presets have no convex option. Before the tow retrain.
7. **T2's reason for keeping the entry is not what I see.** "Removing it would have changed the links' collision geometry": the rigid and RFT tasks use the asset's own `collision_props` and have the same hulls. Removing the entry would change the foot box's gap from 0 to 0.01 and the logged config. Keeping it is still right.
8. **Everything is uncommitted**, the mixed environment files untracked. The record is the snapshots and `sha256.txt`.

## Could not verify

- Whether a policy trains well with the fix (T2: 3 iterations only).
- Learning progress of the cache run; W&B configs of the new runs.
- Fixed-bed preset with `convex_collider_bodies=[]` (not built).
- Warp checkout, `uv.lock` and non-Python files of the snapshots (not downloaded).
- Sand support under the foot (T2's test 3), streaming travel in my probe.
- My probe is small: 8 and 4 robots, 6 and 4.8 s, one seed, a policy trained with the stop.

## Verification performed

Read: the fix diff, the mixed environment, Newton's implicit MPM and coupled solver, the launcher, T2's probe and diff logs. Run by me (scratchpad `/tmp/claude-353763860/-home-jkamohara-RSS-27-RSS-MPM-Project-Skill/7cd73667-8f25-4955-a4f1-70eac60a1408/scratchpad/check_fix/`): `probe.py` twice (`no_cache.json`, `cache.json`), `shapes.py` four times (`shapes_{mpm_new,mpm_old_relabel,rigid,rft}.json`), `resolve.py`; `sha256sum -c`; snapshot downloads and `diff -rq` (`snap_*`, `ref_vs_new_src.txt`, `cfb_compare.txt`); `osmo workflow spec`, `query`, `logs` (read-only; `spec_*.yaml`, `logs_nocache.txt`). No edit to code, `outputs/` or `site/`; no workflow submitted, cancelled or restarted.

## To send to the T2 session

1. Relaunch the no-cache run (issue 1) with the same arguments; record the command and the new snapshot.
2. Record issues 2 to 4 in the T2-MARGIN block; correct the sentence of issue 7.
3. Make `_init_sim` raise when the preset has no `collider_margins` (issue 5), after the trainings, not in the running snapshots.
