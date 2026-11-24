# T2 history: earlier work and diagnostics (not paper results)

Archived from `outputs/T2.md` on 2026-11-21, when `tasks/T2.md` was reduced to policy success across embodiments and tasks. Nothing here is a T2 deliverable. It covers box, drum, table, and chair pushing on the old code, the object force probe, and the day-by-day tow development. Kept for provenance. The current record is `outputs/T2.md`; the towing comparison against rigid and RFT training is in `outputs/T3.md`.

---

# T2 handoff — policies across embodiments and tasks

- **Status:** partial
- This file holds one handoff per old session. The Codex session "IsaacLab mpm moving patch development" adds its own under a separate heading.

# Claude session

- **Author / date:** Claude session "mpm-object-push" in `~/isaac/IsaacLab`, written 2026-11-15 12:55 PST.
- Written for Step 2 of `misc/T2_migration.md`. No code was changed and nothing was committed for this handoff. Three training jobs submitted earlier in the session were still running when it was written.
- "Measured in this session" means read from W&B, OSMO, or a local run during this session. "Not verified" means taken from notes or from the user's earlier statements without a check here.

## 1. Scope: what this session worked on for this topic

Only G1 box pushing, as a single end-to-end PPO policy (no teachers, no distillation):

1. A rigid-ground task and a working policy (packages `g1_29dof_object_push_e2e` and `g1_29dof_object_push_e2e_v4`).
2. A port of that task to recycling moving-patch MPM sand (`g1_29dof_mpm_moving_patch_object_push_e2e`), and fine-tuning the rigid policy on it. This is not working yet.

Constraints set by the user on 2026-11-14: one PPO policy; no global state estimation (box pose relative to the pelvis is allowed); the no-hand G1 asset `UNITREE_G1_29DOF_BOX_FOOT_CFG_NO_HAND`; rigid ground first, then sand; target about one week (by about 2026-11-21).

Two other parts of T2 exist in the same checkout. This session did not write, run, or train them; they are included because T2 covers them. Everything said about them below comes from reading files, W&B, and OSMO on 2026-11-15, and is labelled "inspected, not run here".

3. G1 velocity-tracking locomotion on MPM: `contrib/velocity_mpm/` (six packages, fixed-bed and moving-patch).
4. Manipulator particle pushing: `contrib/ur10_particle_push/`, written upstream by Maximilian Krause (last content commit `174812ca7`, 2026-10-05, "Tune MPM pour/push and refresh particle-rendering goldens (#8106)").

This session's only contact with them: the sand box-pushing task imports the moving-patch environment, MPM gait rewards, visualizer and solver settings from `velocity_mpm/g1_29dof_mpm_moving_patch`, and takes its sand colour from `velocity_mpm/g1_29dof_mpm`.

Not worked on and not inspected: the teacher–student push packages, hardware deployment, and any DAgger training.

## 2. State of the code

> Superseded on 2026-11-15 13:47 PST: the working tree described here was committed as `dcdc2ff3c`. See section 10 for the current git state.

- Repo `/home/jkamohara/isaac/IsaacLab`, branch `junnosuke/mpm_rl_task`.
- Last commit `bc77a1a41a93184d26c6863e4da4a8c808cb8245` — "Update OSMO locomotion training workflows" (2026-11-02).
- The tree is dirty: 330 entries in `git status --short`. **Nothing from this session is committed. A worktree made from HEAD contains none of it.**

Untracked or modified files this work depends on (paths relative to the repo root):

| Path | Git state | Role |
|---|---|---|
| `source/isaaclab_tasks/isaaclab_tasks/contrib/push/` | untracked (whole directory) | All push packages, including the three this session wrote or ported |
| `…/contrib/push/config/g1_29dof_object_push_e2e/` | untracked | Rigid task "v3"; also provides the shared pushing `mdp` (commands, rewards, observations) |
| `…/contrib/push/config/g1_29dof_object_push_e2e_v4/` | untracked | Rigid variant; imports the `mdp` of the package above |
| `…/contrib/push/config/g1_29dof_mpm_moving_patch_object_push_e2e/` | untracked | Sand task; own `mdp/events.py`, `mdp/terminations.py`, `object_push_env.py` |
| `…/contrib/push/config/g1_29dof_mpm_moving_patch_object_push/` | untracked | Sand task imports its env class, particles utility, and patch terminations |
| `…/contrib/push/config/g1_29dof_mpm_object_push/` | untracked | Provides `ObjectContactForces` (per-body robot–box forces) |
| `…/contrib/push/mdp/`, `…/contrib/push/AGENT.md` | untracked | Shared terminations (`box_tilted`), task table |
| `source/isaaclab_tasks/isaaclab_tasks/contrib/velocity_mpm/` | untracked (whole directory, 0 tracked files) | All G1 locomotion-on-MPM tasks; also the moving-patch env, MPM gait rewards, visualizer configs, and solver settings used by the sand push task. The old `contrib/g1_29dof_mpm*` directories it replaced show as deleted |
| `source/isaaclab_tasks/isaaclab_tasks/contrib/ur10_particle_push/` | tracked, unchanged (15 files) | UR10 particle-pushing task; present in a worktree made from HEAD |
| `source/isaaclab_tasks/test/contrib/test_g1_mpm_lower.py`, `test_g1_mpm_moving_patch_lower_body.py`, `test_g1_moving_patch_mpm_push.py`, `test_g1_fixed_mpm_push.py` | untracked | Locomotion and older push tests; not run in this session |
| `source/isaaclab_tasks/test/contrib/test_mpm_particle_cache.py` | modified | Particle-cache test; not run in this session |
| `source/isaaclab_tasks/test/contrib/test_ur10_particle_push_env_cfg.py`, `test_ur10_particle_push_attachment.py` | tracked | UR10 tests; not run in this session |
| `source/isaaclab_tasks/isaaclab_tasks/contrib/velocity/` | tracked, with 18 modified, 24 deleted, and 14 untracked entries | `UniformVelocityYawCommand`, `g1_mdp`, `vel_mdp` imported by the push tasks |
| `source/isaaclab_tasks/isaaclab_tasks/contrib/mimic/` | tracked, 3 files modified | Reference only: the assistive wrench the sand assist force was modelled on |
| `source/isaaclab_assets/isaaclab_assets/robots/unitree.py` and the G1 `.usda` files | modified | No-hand G1 asset |
| `source/isaaclab_tasks/test/contrib/test_push_torso_rewards.py`, `test_g1_object_push.py` | untracked | Tests; 7 pass (measured in this session, 2026-11-15) |
| `osmo/osmo_push_training.md` | untracked | Submission recipe |
| `osmo/osmo_multi_gpu.yaml`, `osmo/osmo_training.md` | modified | Workflow spec used for every job |
| `osmo/run_multinode.sh` | tracked, unchanged | Submission script |

Each OSMO job uploads its own code snapshot at submission, so the three running jobs do not see later edits. `irgc7ke0` was submitted before the blow-up handling, mass curriculum, and noise floor existed.

## 3. Commands and configs

Task IDs and what each trains:

| Gym ID | Package under `contrib/push/config/` | Ground |
|---|---|---|
| `IsaacContrib-Push-Box-Flat-G1-29dof` (`-Play`) | `g1_29dof_object_push_e2e` | rigid, "v3" |
| `IsaacContrib-Push-Box-Flat-G1-29dof-V4` (`-Play`) | `g1_29dof_object_push_e2e_v4` | rigid; one change: free foot-trailing distance 0.25 m instead of 0.30 m |
| `IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E` (`-Play`) | `g1_29dof_mpm_moving_patch_object_push_e2e` | moving-patch sand |
| `IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E-Assist` | same | sand plus a training-only assistive push force |

Config files: `object_push_env_cfg.py`, `env_cfg/*.py`, and `agents/rsl_rl_ppo_cfg.py` inside each package. The design is described in each package's `README.md`.

Rigid training on OSMO (used for `df0fg7gz`; the v4 run used the `-V4` task and run name `e2e_v4_trailing_only_8gpu`). Reconstructed from `osmo/osmo_push_training.md` and the session; the exact original command line is in `logs/osmo/submit-*.log`:

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=8 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-object-push-e2e platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Box-Flat-G1-29dof --num_envs 512 --logger wandb --run_name e2e_v3_8gpu --video --video_length 200"
```

Sand fine-tune on OSMO (exact command used for `snsw2327`; `f4h3znc3` differs only in the run name, `irgc7ke0` uses the `-Assist` task, pool `isaac-lab-l40-07`, platform `ovx-l40`):

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40s-03 --set num_nodes=40 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-mpm-object-push-e2e platform=ovx-l40s \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E --num_envs 64 --wandb_run df0fg7gz --wandb_project g1_29dof_object_push_e2e --logger wandb --log_project_name g1_29dof_mpm_moving_patch_object_push_e2e --run_name sand_finetune_mass_curriculum_std_floor_from_df0fg7gz_40gpu --viz newton_gl --video --video_length 200"
```

`--wandb_run` / `--wandb_project` name the run to resume from; `--log_project_name` names the project of the new run.

Local smoke test of the sand resume (used before every sand submission):

```bash
uv run --with wandb isaaclab train --rl_library rsl_rl --task IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E \
  --num_envs 32 --max_iterations 3 --wandb_run df0fg7gz --wandb_project g1_29dof_object_push_e2e --logger tensorboard
```

Tests:

```bash
uv run pytest source/isaaclab_tasks/test/contrib/test_push_torso_rewards.py source/isaaclab_tasks/test/contrib/test_g1_object_push.py -q
```

### Locomotion on MPM (inspected, not run here)

Registered IDs, read from each package's `__init__.py` under `contrib/velocity_mpm/` (each also has `-Play`):

| Package | Gym IDs | Ground |
|---|---|---|
| `g1_29dof_mpm` | `IsaacContrib-Velocity-Sand-Flat-G1-29dof-MPM`, `…-Sand-Ascending-…`, `…-Sand-Descending-…`, `…-Sand-Dune-…`, `IsaacContrib-Balance-Sand-Tilting-G1-29dof-MPM`, `IsaacContrib-Velocity-Sand-Tilting-G1-29dof-MPM` | fixed particle bed, 29 actions |
| `g1_29dof_mpm_lower` | the six IDs above with `-Lower` appended | fixed bed, 15 leg/waist actions, arms on random trajectories |
| `g1_29dof_mpm_moving_patch` | `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch`, `IsaacContrib-Velocity-G1-29dof-MPM-MovingPatch-MixedTerrain` | recycling moving patch; mixed = half the envs MPM, half rigid |
| `g1_29dof_mpm_moving_patch_lower_body` | `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch-LowerBody` | moving patch, 15 actions |
| `g1_29dof_mpm_moving_patch_agile` | `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch-Agile`, `IsaacContrib-Velocity-G1-29dof-MPM-MovingPatch-Agile-MixedTerrain` | moving patch, default agent compositional FlashSAC |
| `g1_29dof_mpm_moving_patch_particle_cache` | `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch-ParticleCache` | experimental cached tiles |

Each package has a `README.md`; `g1_29dof_mpm_moving_patch/` also has `TODO.md` and `dev/PR_plan.md`, `dev/PR_major.md`. The default agent for `g1_29dof_mpm` and `g1_29dof_mpm_moving_patch` is compositional PPO (`agents/compositional_ppo_cfg.py`); standard RSL-RL PPO is selected with `--agent rsl_rl_standard_cfg_entry_point`.

Commands as written in `velocity_mpm/g1_29dof_mpm_moving_patch/README.md` (not run here):

```bash
# from scratch
uv run --no-sync --with wandb isaaclab train --rl_library rsl_rl \
  --task IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch \
  --num_envs 64 --viz newton_gl --video --video_length 200
# play
uv run --with wandb isaaclab play --rl_library rsl_rl \
  --task IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch-Play --num_envs 1 --viz newton_gl --wandb_run xxx
```

OSMO recipe for locomotion: `osmo/osmo_training.md` (modified, uncommitted). Its from-scratch entry uses `--task IsaacContrib-Velocity-G1-29dof-MPM-MovingPatch-MixedTerrain --num_envs 64 --logger wandb --viz newton_gl --video --run_name train_scratch` on `isaac-lab-l40s-03` / `ovx-l40s`. That README also describes building a custom Warp wheel from `jnskkmhr/warp` at `c1204bebe3ebbf8c5fd656eafa3e5a50b4608421`; whether the current environment still needs it is unknown.

### UR10 particle pushing (inspected, not run here)

- Gym ID `IsaacContrib-UR10-Particle-Push`; env class `ur10_particle_push_env.py:UR10ParticlePushEnv`; config `ur10_particle_push_env_cfg.py:UR10ParticlePushEnvCfg`; agent `agents/rsl_rl_ppo_cfg.py:UR10ParticlePushPPORunnerCfg`. No `-Play` ID is registered and the package has no README.
- Task, from the config docstring: push granular MPM media from a workbench into a side bin with a UR10 carrying a paddle (`UR10WithPaddleCfg`).
- Simulation: `dt = 1/120 s`, decimation 2, 12 s episodes, default 64 envs, MPM voxel 0.025 m.
- Action: 6-dim clamped relative joint position (`ClampedRelativeJointPositionActionCfg`).
- Observations: `policy` state vector, `heightmap` image, privileged `critic` state; the agent uses a CNN model config.
- Rewards: `success` +2.0, `bin_progress` +1.5, `transport_progress` +0.15, `spill` −0.20, `failure` −2.0, `action_magnitude` −0.10, `action_rate` −0.01.
- Terminations: `invalid_state`, `escaped_workspace`, `excessive_spill`, `success`, `time_out`.
- Thresholds: success at 0.60 of the material delivered with at most 0.02 spilled; failure at 0.20 spilled; at most 0.02 of particles may leave the workspace.
- Reset curriculum `SinglePushCurriculum`; reset randomization in `reset_randomization.py`.
- Agent: 72 steps per env per iteration, 6,000 iterations, experiment `ur10_particle_push`, W&B project `ur10-particle-push-mpm`.
- Expected training command, by the repo's usual pattern (not run here, not verified): `uv run --with wandb isaaclab train --rl_library rsl_rl --task IsaacContrib-UR10-Particle-Push --num_envs 64`.

OSMO notes: `osmo workflow logs <id> -t trainer-0 -n 40` returns; the same command without `-n` streams and hangs when piped. Platform is `ovx-l40s` for `isaac-lab-l40s-03` and `ovx-l40` for `isaac-lab-l40-07`.

## 4. Artifacts

W&B entity `jnskkmr` (the user opens runs at `https://forge.coreweave.com/wandb/jnskkmr/<project>/runs/<id>`; the trainer log prints `https://wandb.ai/jnskkmr/...`). Run-name timestamps are UTC.

Project `g1_29dof_object_push_e2e` (rigid):

| Run | Name suffix | OSMO workflow | State |
|---|---|---|---|
| `df0fg7gz` | `e2e_v3_8gpu` | `isaac-lab-g1-object-push-e2e-1` | finished, 20,000 iterations |
| `o38ie04z` | `e2e_v4_trailing_only_8gpu` | `isaac-lab-g1-object-push-e2e-v4-2` | finished, 20,000 iterations |
| `larxkm44` | `e2e_v4_8gpu` | `isaac-lab-g1-object-push-e2e-v4-1` | cancelled at 8,563 (failed design) |
| `97rdtlhn`, `j7d01plv`, `m9iyksse` | `local_sanity_e2e_v3`, `_v2`, `_v1` | local | 2,000 / 2,000 / 656 iterations |

Project `g1_29dof_mpm_moving_patch_object_push_e2e` (sand), all resumed from `df0fg7gz`:

| Run | Name suffix | OSMO workflow | Pool | State at 12:52 PST |
|---|---|---|---|---|
| `cuhtn04e` | `sand_finetune_from_df0fg7gz_40gpu` | `isaac-lab-g1-mpm-object-push-e2e-3` | `isaac-lab-l40s-03` | cancelled at +1,836 iterations (resumed at 16,000) |
| `irgc7ke0` | `sand_assist_from_df0fg7gz_40gpu` | `isaac-lab-g1-mpm-object-push-e2e-assist-3` | `isaac-lab-l40-07` | running, +490 |
| `f4h3znc3` | `sand_finetune_mass_curriculum_from_df0fg7gz_40gpu` | `isaac-lab-g1-mpm-object-push-e2e-4` | `isaac-lab-l40s-03` | running, +401 |
| `snsw2327` | `sand_finetune_mass_curriculum_std_floor_from_df0fg7gz_40gpu` | `isaac-lab-g1-mpm-object-push-e2e-5` | `isaac-lab-l40s-03` | running, +337 |

Other paths:

- Local copy of the rigid checkpoint: `/home/jkamohara/isaac/IsaacLab/logs/rsl_rl/g1_29dof_mpm_moving_patch_object_push_e2e/wandb/2026-11-15_02-48-49_e2e_v3_8gpu_df0fg7gz/model_19999.pt`.
- OSMO outputs: under `swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs`; the per-run subpaths are unknown (not inspected).
- Submission logs: `/home/jkamohara/isaac/IsaacLab/logs/osmo/submit-*.log`.
- Videos: logged to W&B by the jobs (`--video`). No sand video was inspected in this session.
- Session scratch (diagnostic scripts and logs; may be cleared by a reboot): `/tmp/claude-353763860/-home-jkamohara-isaac-IsaacLab/434ef052-ae70-46cd-9189-c7eaa3460fca/scratchpad/` — notably `box_drag.py`, `mass_check.py`, `assist_check.py`, `sand_check.py`, `wb_sand2.py`, `wb_v3base.py`, `wb_spike.py`.
- Datasets: none.

Locomotion and manipulator artifacts (inspected, not produced here):

- W&B projects under `jnskkmr` with MPM locomotion runs: `g1_29dof_mpm_mixed_terrain`, `g1_29dof_mpm_moving_patch_lower_body`, `g1_29dof_soft_flat_ppo`, `g1_29dof_soft_flat_finetune`. Related projects that use the learned particle model, which belongs to another task: `g1_29dof_particle_nerd_mixed_terrain`, `g1_29dof_particle_nerd_lower_mixed_terrain`, `g1_29dof_wbc_particle_nerd_mixed_terrain`.
- Runs named in the locomotion READMEs and `TODO.md`: `876gqr97`, `gzi8enaw`, `5f1xyc21`, `7cawp916`, `k9mk7koh`, `tyiby5k6`. Which of them is the reference locomotion policy is unknown.
- A locomotion job from another session was live at 12:52 PST: OSMO `isaac-lab-mpm-locomotion-updated-asset-rsync-1`; W&B `g1_29dof_mpm_mixed_terrain/eayrj79r` (`mixed_terrain_updated_usda`) was running at iteration 371. Earlier attempts `-updated-asset-1`, `-2`, `-3` were cancelled. This session did not submit them.
- Local log directories under `/home/jkamohara/isaac/IsaacLab/logs/rsl_rl/`: `g1_29dof_mpm`, `g1_29dof_mpm_lower`, `g1_29dof_mpm_mixed_terrain`, `g1_29dof_mpm_moving_patch_lower_body`, `g1_29dof_mpm_moving_patch_agile_flash_sac`, `g1_29dof_mpm_moving_patch_particle_cache`, `g1_29dof_mpm_terrain`. Contents not inspected.
- UR10: no W&B project with "ur10" in its name exists under `jnskkmr` (49 projects listed), and there is no `ur10` directory under `logs/rsl_rl/`. No checkpoint, log, or video for this task was found.

## 5. Results so far

Metric names: `box_speed_ratio` = box speed along the command ÷ commanded speed, moving commands only; `hand_contact_fraction` = fraction of wrists touching the box; `non_hand_contact_force` = box force on non-wrist bodies.

Rigid ground, final W&B summary values (measured in this session, 2026-11-15 12:52 PST):

| Run | Envs × GPUs | Iterations | Wall-clock | Box speed ratio | Wrist contact | Non-wrist force | Time-out rate | Box-tilt terminations | Velocity error | Throughput |
|---|---|---|---|---|---|---|---|---|---|---|
| `df0fg7gz` (v3) | 512 × 8 L40 | 20,000 | 6.0 h | 0.86 | 0.79 | 0 N | 0.998 | 0 | 0.09 m/s | 103,700 steps/s |
| `o38ie04z` (v4, trailing 0.25 m) | 512 × 8 L40 | 20,000 | 5.9 h | 0.88 | 0.76 | 0 N | 0.996 | 0 | 0.09 m/s | 107,900 steps/s |

- The v3 learning curve from scratch: box speed ratio stayed near 0.06 from iteration 300 to 800, reached 0.44 at 1,200 and 0.84 at 2,000 (measured in this session).
- The user viewed the v3 video and called the behaviour "fantastic", with a concern that both feet trail far behind the pelvis. A frame at about iteration 3,590 showed that posture (measured in this session). The v4 video was not inspected, so whether the 0.25 m band changed the gait is not verified.

Sand, W&B summary values at 12:52 PST (measured in this session). All use 64 envs × 40 GPUs and resume from `df0fg7gz`:

| Run | Changes vs. plain port | Iterations after resume | Wall-clock | Box speed ratio | Wrist contact | Time-out rate | Policy entropy | Other |
|---|---|---|---|---|---|---|---|---|
| `cuhtn04e` | none | 1,836 | 10.5 h | 0.04 | 0.87 | 0.88 | 7.2 | cancelled; stood still |
| `irgc7ke0` | assist force only | 490 | 2.9 h | 0.10 | 0.91 | 0.95 | 19.5 | assist gain 0.80 (its maximum), mean assist force 75 N |
| `f4h3znc3` | blow-up handling, mass curriculum | 401 | 2.4 h | 0.09 | 0.80 | 0.83 | 16.2 | mass level 0 (2–5 kg), implausible-velocity terminations 0.016 |
| `snsw2327` | the above plus noise floor 0.5 | 337 | 2.0 h | 0.12 | 0.74 | 0.60 | 24.2 | mass level 0 (2–5 kg), implausible-velocity terminations 0.016 |

- **No sand run pushes the box.** All three live runs are below the iteration count (about 800–1,200) at which the rigid run took off, so they are not yet decided. In `irgc7ke0` the ratio includes the assist force.
- Sand training speed: about 170 iterations per hour (about 21 s per iteration) for `cuhtn04e`; throughput 2,300–3,100 steps/s across the runs (measured in this session).
- Local throughput on one RTX 5090: about 140 steps/s at 32 sand envs; rigid about 85,000–95,000 steps/s at 2,048 envs (measured in this session). About 60,000 particles per environment.
- Box resistance on sand, box alone under a constant horizontal force (measured in this session, rough: episodes reset during the test): a 15 kg box needs about 60–100 N to slide and sinks about 3.4 cm; a 5 kg box slides under 30 N.
- Simulation blow-ups in `cuhtn04e`: 163 of 1,755 logged iterations had mean reward below −1,000, with `dof_acc_l2` down to −1.2e10, `ang_vel_xy_l2` to −3.5e9, value loss up to 5.9e19, and `solver_diverged` at 0 (measured in this session). The estimate that this is about 6 separate events, each visible for about 30 iterations in the running mean, is an inference and is not verified.
- Newton/MJWarp contact friction is the maximum of the two shapes' coefficients; with ground 0.9 the box coefficient had no effect (measured in this session on rigid ground).

Locomotion on MPM, final W&B summary values of the most recent finished runs (read in this session on 2026-11-15; this session did not train them and did not check what each run changed):

| Project / run | Name | Iterations | Wall-clock | Time-out rate | Linear velocity error | Yaw-rate error | Terrain level | Throughput |
|---|---|---|---|---|---|---|---|---|
| `g1_29dof_mpm_mixed_terrain` / `cpl0kk61` | `train_scratch_large_waist_gain` | 20,000 | 59.1 h | 0.82 | 0.67 m/s | 0.84 rad/s | 2.17 | 7,500 steps/s |
| `g1_29dof_mpm_mixed_terrain` / `jqur5jhm` | `train_scratch` | 20,000 | 60.6 h | 0.78 | 0.34 m/s | 0.83 rad/s | 2.69 | 6,700 steps/s |
| `g1_29dof_mpm_mixed_terrain` / `kevrlv51` | `no_waist_l2_penalty` | 40,000 (resumed) | 51.1 h | 0.81 | 0.19 m/s | 0.82 rad/s | 2.31 | 5,900 steps/s |
| `g1_29dof_mpm_moving_patch_lower_body` / `rbfuk3xq` | `mixed50_standard_ppo_support_height_40gp…` | 20,000 | 53.1 h | 0.84 | 0.31 m/s | 0.85 rad/s | 2.09 | 6,800 steps/s |

- These are last-logged training values, not an evaluation. Wall-clock is W&B `_runtime` and may include restarts. GPU count and `num_envs` per run were not read. `Metrics/success_rate` is 0 in every one of these runs, so that metric is either unused or broken; which is unknown.
- Whether any of these policies walks acceptably in video is not verified.

UR10 particle pushing: no result of any kind was found. Whether the task builds and trains in this checkout today is unknown.

Not measured at all: yaw tracking as defined in `tasks/T2.md`, success rate, box tipping rate over a fixed evaluation set, delivered and spilled fraction for the manipulator, any evaluation outside training logs, any hardware result.

## 6. Failed attempts

| Attempt | What happened | Why (as far as known) |
|---|---|---|
| Rigid v1: hand targets attached to the box | Robot planked onto the box | Reward could be earned by leaning body weight on the box |
| Rigid v2: tightly constrained posture | Collapsed to standing | Over-constrained; no posture left that could push |
| Rigid v4 first attempt (`larxkm44`): ground friction 0.4 with per-env foot friction 0.4–1.0, free forward lean 0.35→0.25 rad, free foot trailing 0.30→0.25 m, all at once | Box speed ratio 0.10, time-out 0.69 at 8,563 iterations; entropy −0.56 | Unknown which of the three changes caused it; they were bundled. Reverted at the user's request |
| Sand fine-tune without changes (`cuhtn04e`) | 74% of episodes fell right after the resume; then learned to stand with wrists on the box; ratio 0.04 after 1,836 iterations; entropy fell from 24 to 7 | The rigid policy does not transfer; the cause of the standing optimum is not established |
| Assisted run on `isaac-lab-l40-06` (`-assist-2`) | All 40 workers sat 7 h at "Validating READ access" to the swift snapshot; never trained | Unknown; the same snapshot store works from `isaac-lab-l40s-03` and `isaac-lab-l40-07` |
| Jobs on `isaac-lab-l40-07` (`-e2e-2`) and `isaac-lab-l40s-03` (`-assist-1`) | Stayed in scheduling | Pool quota was full |
| Teacher–student runs `haxmnwd2`, `1nr7ez11`, fixed-bed `03iu4g23` (before this session's e2e work) | Cube tipping, hands never in contact, robot separating from the cube, or standing still | Not verified; from the user's statements and notes |

## 7. Known bugs and open issues

- The sand policy does not push. This is the main open issue.
- Coupled-solver blow-ups leave finite but absurd velocities. Handling exists only in code used by `f4h3znc3` and `snsw2327` (termination `implausible_velocity`, step reward clamped to ±10). The root cause in the solver was not investigated.
- With the assist force at its maximum gain (0.80, mean 75 N) the box speed ratio in `irgc7ke0` is still 0.10 after 490 iterations. Whether the force is too weak, mis-directed, or simply early is unknown.
- Sand-only penalties are much larger than on rigid ground: `base_height` about −0.8 per episode against 0, `stance_foot_angle_penalty` about −0.25 to −0.6 against −0.02 (measured in `cuhtn04e`). Not verified as a cause of the standing behaviour.
- The assist gain, 150 N cap, 0.7 retirement ratio, mass ranges, promotion thresholds, and the 0.5 noise floor are first guesses, not tuned.
- The mass curriculum level is kept per training process; 40 workers each hold their own.
- Box mass changes reach the coupled rigid solver only after the next physics step.
- A check of the reward clamp by injecting a 1e5 rad/s joint velocity ended the episode with reward 0; the raw reward was also 0, so the clamp itself was not exercised by that test.
- The sand colour was set to match `velocity_mpm/g1_29dof_mpm` but never checked visually.
- `tasks/T2.md` names `IsaacContrib-Push-G1-29dof-MPM-ObjectPush` as the box-pushing starting point; this session's work uses different task IDs (section 3).
- Nothing is committed; the old `contrib/g1_29dof_mpm*` directories show as deleted in git.
- Locomotion: the task table in `velocity_mpm/g1_29dof_mpm/README.md` lists IDs that are not the registered ones (for example `IsaacContrib-Velocity-Sand-G1-29dof-MPM` and `…-Sand-Rough-…` in the README against `IsaacContrib-Velocity-Sand-Flat-G1-29dof-MPM` and `…-Sand-Ascending-…` in `__init__.py`). The registered IDs in section 3 are the ones to use.
- Locomotion: that README states that some foot-clearance and touchdown rewards still assume flat ground on the shaped beds.
- Locomotion: `velocity_mpm/g1_29dof_mpm_moving_patch/TODO.md` lists open gait questions: excessive arm swing, weak hip-yaw motion and low foot clearance when turning, and heel lift, each compared across specific W&B runs.
- Locomotion: `tasks/T2.md` asks for success rate, velocity error, and yaw error; the logged `success_rate` is 0 everywhere and no evaluation script was found by this session.
- UR10: no README, no `-Play` ID, no training artifact found.

## 8. Next steps I would take

1. Let `irgc7ke0`, `f4h3znc3`, and `snsw2327` reach about +1,200–1,500 iterations, then compare `box_speed_ratio` together with `Curriculum/box_mass/level` and `Curriculum/assistive_push_force/beta`. A sand policy counts only when the mass level is 1 and the assist gain is 0.
2. Watch a sand video from each run before calling anything working.
3. If all three stand still: fix the sand `base_height` and stance-foot-angle terms, and check the assist force direction and size in a short local run with the trained policy.
4. Resubmit the assisted task from current code so it also has the blow-up handling, mass curriculum, and noise floor.
5. Write an evaluation script for the T2 acceptance metrics (success rate, velocity and yaw error, box velocity tracking, box tipping rate) over a fixed number of episodes; none exists from this session.
6. Commit the push packages and their dependencies on a feature branch (the repo rules forbid AI attribution lines). `contrib/velocity_mpm/` must go in the same commit series, because the sand push task imports it and it is entirely untracked.
7. Locomotion: ask the Codex session or the user which run is the reference policy, then evaluate it on the T2 metrics with a fixed episode count, and find out why `success_rate` logs 0.
8. UR10: run its two tests and a short local training run to learn whether it works in this checkout; only then plan the Franka port.

## 9. Specific questions

**What is the state of G1 box pushing on MPM: which task ID trains, and what does the policy do today?**
`IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E` (and `-Assist`) build, step, load the rigid checkpoint `df0fg7gz`, and train on OSMO at 64 envs × 40 GPUs. Today the policy stays upright with its wrists on the box and does not move it: box speed ratio 0.04 in the finished-and-cancelled run and 0.09–0.12 in the three live runs, which are still early. On rigid ground the same design pushes at 0.86–0.88 of the commanded speed with wrist-only contact (`IsaacContrib-Push-Box-Flat-G1-29dof`, runs `df0fg7gz` and `o38ie04z`). The state of the older MPM push tasks (`IsaacContrib-Push-G1-29dof-MPM-ObjectPush`, `IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch`, `IsaacContrib-Push-Box-G1-29dof-MPM`) is unknown to this session beyond the failed runs listed in section 6.

**What exists for the manipulator task, and what is missing to move from UR10 to Franka?**
Not worked on in this session; from inspection only. `contrib/ur10_particle_push/` (tracked, unchanged, from Maximilian Krause) registers `IsaacContrib-UR10-Particle-Push`: a UR10 with a paddle pushes MPM media from a workbench into a side bin, with heightmap and state observations, a 6-dim joint action, and success defined as 0.60 of the material delivered with at most 0.02 spilled (details in section 3). Two tests exist. No training run, checkpoint, or video was found, so whether it trains is unknown.

For Franka, nothing was found: no Franka particle-pushing package or task ID exists in `contrib/`. A `contrib/franka_pour/` package exists (a pouring task, not inspected). By reading the UR10 config, a port would at least need a Franka asset with the paddle attachment (the UR10 one is `UR10WithPaddleCfg`), the coupler body mappings for the new links, the reset inverse-kinematics and randomization in `reset_randomization.py`, and the 6-dim action changed to Franka's 7 joints. This list comes from reading, not from attempting the port; the full set of missing pieces is unknown.

**What exists for G1 velocity tracking on MPM?** (added; T2 acceptance criterion 2)
Six packages under `contrib/velocity_mpm/` (IDs in section 3), all untracked in git. Finished training runs exist in W&B (section 5), with linear velocity error 0.19–0.67 m/s and yaw-rate error about 0.8 rad/s as last-logged training values. This session did not run or evaluate any of them, and does not know which run is the reference policy.

**Is PPO + DAgger for whole-body box pushing implemented? If so, where?**
Not by this session; its work is PPO only. By file listing only: `source/isaaclab_rl/isaaclab_rl/rsl_rl/distillation_cfg.py` exists, the packages `g1_29dof_object_push` and `g1_29dof_mpm_object_push` are described in `contrib/push/AGENT.md` as whole-body students with two frozen teachers, and the word "DAgger" appears in `contrib/push/config/g1_29dof_object_push/README.md`. Whether that is a PPO + DAgger implementation, and whether it works, is unknown.

## 10. Update, 2026-11-15 13:55 PST (Claude session)

Written after the working tree was committed, and after checking this handoff against the repo, W&B, and OSMO. Sections 1–9 are left as written at 12:55 PST; where they disagree with this section, this section is current.

### Git state now

- `/home/jkamohara/isaac/IsaacLab`, branch `junnosuke/mpm_rl_task`, HEAD `dcdc2ff3ca74ff0df59d7008c6fbd8d8c87a1076` — "Snapshot MPM RSS work: move MPM tasks under velocity_mpm, add push tasks, baselines, and RSS evaluation" (2026-11-15 13:46 PST). One commit ahead of `origin/junnosuke/mpm_rl_task`; not pushed.
- The tree is clean except for untracked `exports/`. `contrib/push/` (228 files), `contrib/velocity_mpm/` (187 files), `osmo/osmo_push_training.md`, and the push tests are now tracked with no differences from the working files.
- Every change this session made is in the commit. Checked by searching HEAD for: `MIN_ACTION_STD = 0.5`, `class BoxMassCurriculum`, `class AssistivePushForce`, `def robot_velocity_implausible`, `class G1MovingPatchObjectPushE2EEnv`, `MAX_FOOT_TRAILING_DISTANCE = 0.25` (v4), `def episode_box_speed_ratio`, `def box_contact_forces`.
- `test_push_torso_rewards.py` and `test_g1_object_push.py`: 7 passed at this commit (measured in this session). All task IDs in section 3 are registered at this commit (measured in this session, by listing the Gym registry).
- The three running OSMO jobs use code snapshots uploaded at submission and were not affected by the commit.
- The commit message ends with a `Co-Authored-By: Claude …` line. The IsaacLab `AGENTS.md` says "Do not add AI co-author or attribution lines". This session did not make the commit. It is unpushed, so the message can still be changed; that is the owner's call.

### Sand runs now (measured in this session, W&B summary at 13:55 PST)

| Run | Changes | Iterations after resume | Wall-clock | Box speed ratio | Wrist contact | Time-out rate | Policy entropy | Other |
|---|---|---|---|---|---|---|---|---|
| `irgc7ke0` | assist force only | 672 | 3.9 h | 0.10 | 0.92 | 1.00 | 17.2 | assist gain 0.80 (maximum), mean assist force 71 N |
| `f4h3znc3` | blow-up handling, mass curriculum | 584 | 3.4 h | 0.09 | 0.85 | 0.84 | 11.9 | mass level 0 (2–5 kg), box-tilt terminations 0.016 |
| `snsw2327` | the above plus noise floor 0.5 | 521 | 3.1 h | 0.12 | 0.74 | 0.85 | 22.8 | mass level 0 (2–5 kg) |

- In all three the box speed ratio fell from about 0.38 in the first iterations (while the robot was still falling) to about 0.10 as the time-out rate rose, and has been flat since. This is the same path `cuhtn04e` took into standing still.
- The mass curriculum has not left its starting range in either run that has it, so even a 2–5 kg box is not being pushed.
- The assisted run is at maximum gain with a mean force of about 71 N and the box still does not move. Why is unknown.
- Since the blow-up handling went in, the lowest logged mean reward in each live run is about −12 to −16, against −3.0e9 in `cuhtn04e`.
- No sand video has been inspected.

### What the check of sections 1–9 found

- Section 2 is stale: it says nothing is committed. Now superseded (above).
- Section 4 lists `tyiby5k6` among runs named in the locomotion documents without a project. It is in `g1_29dof_soft_flat_ppo`, not `g1_29dof_mpm_mixed_terrain`.
- Section 6 lists teacher–student runs without projects. They exist: `haxmnwd2` and `1nr7ez11` in `g1_29dof_mpm_moving_patch_object_push`, `03iu4g23` in `g1_29dof_mpm_object_push`, all in state "crashed". What they did is still not verified.
- Everything else named was found: all ten e2e W&B runs, the locomotion runs in section 5, the eight OSMO push workflows, the local checkpoint `model_19999.pt` (17 MB), the submission logs, and the scratch directory.
- Not checked: the swift output paths; the contents of the local locomotion log directories; any video.
- A possible conflict with `style/isaaclab_env_construction.md` ("config files are standalone; do not inherit term or env configs from another task"): `g1_29dof_object_push_e2e_v4` and the sand package import the `mdp` of `g1_29dof_object_push_e2e` (allowed: MDP reuse), but the `-Assist` variant's `AssistEventsCfg`, `AssistCurriculumCfg`, and `G1ObjectPushAssistEnvCfg` inherit from configs in their own package, and `G1MovingPatchObjectPushE2EEnv` subclasses the env class of `g1_29dof_mpm_moving_patch_object_push`. Whether same-package variants count is for the owner to decide.
- This session changed one shared module: `g1_29dof_object_push_e2e/mdp/` gained `box_contact_forces` and `episode_box_speed_ratio`, and the command metrics now call the former. `g1_29dof_object_push_e2e_v4` uses that module. Both changes are additive and were made for the sand port. `df0fg7gz` was trained before either existed. Whether `o38ie04z` was submitted before or after `box_contact_forces` is unknown; it was trained before `episode_box_speed_ratio`. The rigid tasks have not been retrained at `dcdc2ff3c`.

### Manipulator part on hold (2026-11-15, from the owner)

Junnosuke stated that Max already has a working Franka policy and will be asked to take over the manipulator part. This session runs nothing for UR10 or Franka (no tests, no training, no port plan) until told otherwise. The Franka policy, its task ID, and its location are unknown to this session; the "no Franka pushing task exists" statements above describe only what is in `junnosuke/mpm_rl_task` at `dcdc2ff3c`.

## 11. Box-push physics probes on sand, 2026-11-15 (Claude session)

Local measurements, no policy and no training, at IsaacLab `dcdc2ff3c` (clean tree), task `IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E`, 8 envs, one RTX 5090. Script (scratch, not in the repo): `/tmp/claude-353763860/-home-jkamohara-isaac-IsaacLab/434ef052-ae70-46cd-9189-c7eaa3460fca/scratchpad/push_physics.py`, run as `MODE=drag [HEIGHTS=a,b] [BOXMU=..] [BOXH=..] [BOXL=..] uv run python push_physics.py`.

Method: terminations off; the robot base is held kinematically 0.35 m above the sand and carried along with the box, so it never touches the box and the patch follows as in training. After 1.5 s of settling, a PI controller applies a horizontal force to the box to hold 0.3 m/s for 6 s (about 1.8 m of travel). The force is applied at a chosen height (force at the centre plus the matching pitch torque). All numbers below are measured in this session.

Sliding resistance, force applied 0.05 m above the box bottom (the box stays upright, tilt under 6°):

| Box (L × W × H) | Box surface friction | 2 kg | 5 kg | 10 kg | 15 kg | Sink at 15 kg |
|---|---|---|---|---|---|---|
| 1.0 × 0.8 × 1.0 m (training box) | 0.6 / 0.5 (training value) | 15 N | 37 N | 120 N | 178 N | 0.04 → 0.06 m |
| 1.0 × 0.8 × 1.0 m | 0.2 | 5 N | 61 N | 140 N | 203 N | 0.04 → 0.10 m |
| 1.0 × 0.8 × 0.6 m | 0.6 / 0.5 | 13 N | 48 N | 125 N | 169 N | 0.03 → 0.05 m |
| 1.6 × 0.8 × 1.0 m | 0.6 / 0.5 | 11 N | 40 N | 90 N | 153 N | 0.04 → 0.08 m |

- Mean force over the last 4 s. As a fraction of box weight this is about 0.8–1.2 for 5–15 kg (rigid-ground task: about 0.6).
- The box sinks about 0.03 m at rest and keeps sinking as it slides. Lowering the box surface friction did not lower the resistance.
- Robot weight is 324 N (33.0 kg).

Tipping, same drive but with the force applied higher:

| Box | Push height above ground | Result for 2, 5, 10, 15 kg |
|---|---|---|
| 1.0 × 0.8 × 1.0 m | 0.30 m | all four tipped past 90° within about 1.4 m |
| 1.0 × 0.8 × 1.0 m | 0.50 m (centre) | all four past 45° within about 0.6 m, then tumbling |
| 1.0 × 0.8 × 1.0 m | 0.83 m (wrist height) | all four past 48° within about 0.6 m, then tumbling; same with surface friction 0.2 |
| 1.0 × 0.8 × 0.6 m | 0.55 m | all four past 64° within about 0.6 m |
| 1.6 × 0.8 × 1.0 m | 0.83 m | all four past 34° within about 0.6 m, then tumbling |

Reading (inference, consistent with rigid-body statics): a box slides instead of tipping only when resistance ÷ weight is below length ÷ (2 × push height). At wrist height that limit is 0.60 for the training box and 0.96 for the 1.6 m box; the measured resistance ratio is 0.8–1.2. So at G1 wrist height the box tips before it slides, for every mass tested. The task penalises and terminates tipping, which is consistent with all sand policies settling on standing with the wrists on the box.

Patch boundary: with the robot following, the clearance between the box front face and the kinematic boundary stayed 0.30–0.40 m (0.15–0.25 m for the 1.6 m box with a 3.4 m patch). The box was not blocked by the boundary in these runs. Not tested: a stationary robot, where the patch follows only half of the box motion.

Not established:
- Why the box sinks under about 180 Pa of pressure and keeps sinking while sliding. Whether this is a resolution effect (voxel 0.04 m), particles entering the collider, or the coupling was not investigated.
- The horizontal force the robot's feet can hold on sand. A probe that pulled a passive (zero-action) robot was invalid: the legs buckled at 50–75 N before the feet slipped. The sand friction coefficient is 0.48, which would put a frictional ceiling near 155 N; that is a calculation, not a measurement.

### Drum probe, 2026-11-15 (Claude session)

Same probe and commit as section 11, with the box replaced by a horizontal cylinder: radius 0.5 m, length 0.8 m, axis across the push direction (`DRUM=0.5 HEIGHTS=0.0,0.33 MODE=drag uv run python push_physics_drum.py`, scratch script next to `push_physics.py`). Measured in this session; one run, 8 envs.

| Push height above ground | 2 kg | 5 kg | 10 kg | 15 kg |
|---|---|---|---|---|
| 0.50 m (axle) | 2 N | 6 N | 13 N | 21 N |
| 0.83 m (wrist height) | 1 N | 4 N | 8 N | 13 N |

- Mean force to hold 0.3 m/s over the last 4 s. The drum rolled at 0.30 m/s in every case, drifted sideways by at most 0.01 m over about 1.8 m, and its centre height changed by at most 0.02 m.
- Rolling resistance is about 0.13–0.15 of the drum's weight when pushed at the axle and about 0.08 at wrist height.
- Not tested: the robot actually pushing it, steering it, a drum on a slope, or a drum on rigid ground for comparison.

### Drum tasks added, 2026-11-15 (Claude session)

Decision by the owner: work on a drum instead of the box. Two new packages under `contrib/push/config/`, uncommitted on top of IsaacLab `dcdc2ff3c` (untracked directories plus a modified `contrib/push/AGENT.md`):

| Package | Gym ID | Ground |
|---|---|---|
| `g1_29dof_mpm_moving_patch_drum_push_e2e` | `IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E` (`-Play`) | moving-patch sand |
| `g1_29dof_drum_push_e2e` | `IsaacContrib-Push-Drum-Flat-G1-29dof` (`-Play`) | rigid; owns the drum MDP terms |

- Drum: cylinder, radius 0.5 m, length 0.8 m, axis across the push direction, 5–15 kg sampled once per environment, scene name `drum`.
- Changes against the box tasks: the object pose observation is the drum position with a yaw-only rolling-direction frame (`drum_pose_b`, same 7 values, so box checkpoints load); the box tilt penalty and tilt termination are removed; `drum_axis_tilted` ends the episode if the axis leaves the horizontal. The sand drum task keeps the blow-up handling (implausible-velocity termination, step reward clamped to ±10) and drops the mass curriculum, the action-noise floor, and the assist variant.
- No existing package was edited.

Measured in this session:
- Sand drum task: observation shapes 1000 / 3 / 1010 / 7 / 150 / 9, mirror reflection applied twice returns the input exactly, the checkpoint `df0fg7gz` `model_19999.pt` loads, and a 4-iteration local resume at 32 envs ran without errors.
- Rigid drum task: a 300-iteration local run (2,048 envs, RTX 5090) ran without errors, but the policy stopped touching the drum after about 150 iterations (wrist contact 0.00, drum speed ratio 0.00, time-out 1.00, mean reward 81). The box task at the same iteration had wrist contact 0.68. Longer training was not tried.
- The 7 push tests still pass.

No drum policy has been trained on sand. Nothing was submitted to OSMO for the drum.

### Sand drum fine-tune submitted, 2026-11-15 17:25 PST (Claude session)

On the owner's go-ahead. The three sand box runs (`isaac-lab-g1-mpm-object-push-e2e-assist-3`, `-e2e-4`, `-e2e-5`) were cancelled.

- OSMO workflow `isaac-lab-g1-mpm-drum-push-e2e-1`, pool `isaac-lab-l40-07`, platform `ovx-l40`, 40 GPUs × 64 envs.
- W&B `jnskkmr/g1_29dof_mpm_moving_patch_drum_push_e2e/yjspqbop`, run name `sand_drum_from_df0fg7gz_40gpu`, resumed from `g1_29dof_object_push_e2e/df0fg7gz`.
- Code: IsaacLab `dcdc2ff3c` plus the two uncommitted drum packages (the job uses a snapshot of the working tree).
- Command:

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=40 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-mpm-drum-push-e2e platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E --num_envs 64 --wandb_run df0fg7gz --wandb_project g1_29dof_object_push_e2e --logger wandb --log_project_name g1_29dof_mpm_moving_patch_drum_push_e2e --run_name sand_drum_from_df0fg7gz_40gpu --viz newton_gl --video --video_length 200"
```

At 17:32 PST all workers were running and the W&B run existed; no training iteration had been logged yet. No result.

### Rough-terrain drum variant added, 2026-11-15 (Claude session)

Requested by the owner. Uncommitted, in the same package as the flat sand drum task (IsaacLab `dcdc2ff3c` plus untracked drum packages).

- Gym ID `IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E-Rough` (`-Rough-Play`); class `G1DrumPushRoughEnvCfg` in `g1_29dof_mpm_moving_patch_drum_push_e2e/drum_push_env_cfg.py`.
- Terrain `ROUGH_TERRAINS_CFG` in `env_cfg/terrain_cfg.py`: 10 × 5 tiles of 8 m; equal shares of waves (amplitude 0.05–0.2 m, 4 waves per tile), random bumps (0.01–0.05 m), pyramid and inverted-pyramid slopes (0–0.2), and flat. These are half the values of `velocity_mpm/g1_29dof_mpm_moving_patch`. Rows are ordered by difficulty; each environment starts at a tile centre on a random row; no level curriculum.
- One reward differs from the flat task: `base_height` uses the new `base_height_band_above_terrain_l2` (in `g1_29dof_drum_push_e2e/mdp/rewards.py`), which measures the pelvis above the scanned sand surface. The flat task's `validate_config` gained a guard so it only enlarges the terrain tile when environments are not placed on terrain origins; the flat task's behaviour is unchanged.

Measured in this session (local, 16 and 32 envs):
- Environments land on all five terrain types and on rows 0–9. Pelvis height above the scanned sand at reset is 0.76 m on every tile, matching the flat value.
- Observation shapes unchanged; mirror reflection applied twice returns the input exactly; `df0fg7gz` loads; a 4-iteration resume ran without errors.
- With zero actions, the drum on wave tiles rolled on its own at 0.3–0.4 m/s within 0.4 s, and one of 16 environments ended by `drum_outside_patch` in 0.8 s.

Not trained. Nothing submitted for this variant.

### Rough drum fine-tune submitted, 2026-11-15 20:06 PST (Claude session)

On the owner's go-ahead. OSMO workflow `isaac-lab-g1-mpm-drum-push-e2e-rough-1`, pool `isaac-lab-l40-07`, platform `ovx-l40`, 40 GPUs × 64 envs; W&B `jnskkmr/g1_29dof_mpm_moving_patch_drum_push_e2e/p0ux7eil`, run name `sand_drum_rough_from_df0fg7gz_40gpu`, resumed from `g1_29dof_object_push_e2e/df0fg7gz`. Same command as the flat drum run with `--task IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E-Rough`, `workflow_name=isaac-lab-g1-mpm-drum-push-e2e-rough`, and that run name. Code: `dcdc2ff3c` plus the uncommitted drum packages. At 20:12 PST all workers were running and the W&B run existed; no iteration logged yet.

Flat drum run `yjspqbop` at +379 iterations (19:46 PST, W&B summary, measured in this session): drum speed ratio 0.82, wrist contact 0.53, time-out 0.98, `drum_outside_patch` 0, bad orientation 0.016. Video not inspected.

### Flat drum result and rough drum resubmission, 2026-11-15 22:33 PST (Claude session)

Flat sand drum run `yjspqbop` (measured in this session, W&B at 22:28 PST, +850 iterations after resuming `df0fg7gz`, 40 GPUs × 64 envs, about 5 h wall-clock): drum speed ratio 0.85, wrist contact 0.66, non-wrist contact 0 N, time-out 1.00, `drum_outside_patch` 0, linear velocity error 0.11 m/s, mean reward 116. The ratio passed 0.8 at about +430 iterations. Five frames of the video at iteration 20,840 show the robot upright behind the drum with both arms on it. The video was not watched in motion, and no evaluation outside training has been run.

First rough run `p0ux7eil` (`-rough-1`, random difficulty rows, resumed from the rigid box policy): at +361 iterations time-out 0.20, bad orientation 0.61, `drum_outside_patch` 0.21, drum speed ratio 0.51 over short episodes. The owner judged it not learning; cancelled. No outright defect was found in the rough setup; the changes below reduce difficulty at the start.

Changes to the rough variant (uncommitted, on `dcdc2ff3c`):
- Terrain curriculum `terrain_levels_push` (`g1_29dof_drum_push_e2e/mdp/curriculums.py`): every environment starts on the easiest row; it moves up after a full-length episode with drum speed ratio above 0.7, and down after a fall or a ratio below 0.35.
- Pyramid tile platform widened from 2 m to 4 m so the robot and drum both start on flat ground.
- Warm start from the flat sand drum policy instead of the rigid box policy.

Checked locally: the curriculum promotes and demotes as specified; with zero actions no environment terminated in 40 steps on the easiest row; a 4-iteration resume from `yjspqbop` `model_20500.pt` ran with bad orientation 0.00.

Resubmitted: OSMO `isaac-lab-g1-mpm-drum-push-e2e-rough-2`, pool `isaac-lab-l40-07`, 40 GPUs × 64 envs; W&B `jnskkmr/g1_29dof_mpm_moving_patch_drum_push_e2e/secylx9i`, run name `sand_drum_rough_curriculum_from_yjspqbop_40gpu`; args as the flat run except `--task IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E-Rough --wandb_run yjspqbop --wandb_project g1_29dof_mpm_moving_patch_drum_push_e2e`. At 22:40 PST the checkpoint was loaded and the W&B run existed; no iteration logged yet.

### Slides and policy playback, 2026-11-16 01:45 PST (Claude session)

- **Slides:** [site/T2/index.html](../site/T2/index.html), built by `examples/RSS/push/site_slides.py` in the IsaacLab checkout (`uv run --with wandb --with matplotlib python examples/RSS/push/site_slides.py --site ~/RSS_27/RSS_MPM_Project_Skill/site/T2`). Every result on them is `unchecked`.
- Code state: IsaacLab `dcdc2ff3c` plus uncommitted work: the two drum packages, `contrib/push/AGENT.md`, and `examples/RSS/push/` (`eval_drum_push.py`, `site_slides.py`).
- GPU: one local RTX 5090. Seed 42. One environment per run, as the owner asked.

Videos (10 s, 1 environment, recorded with `isaaclab play ... --viz newton_gl --video --video_length 500`), originals in `/home/jkamohara/isaac/IsaacLab/logs/rss_push/videos/`, downscaled copies in `site/T2/media/`:

| File | Task | Checkpoint | Command overrides |
|---|---|---|---|
| `flat_straight.mp4` | `IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E-Play` | `yjspqbop` `model_21000.pt` | none (0.35 m/s forward) |
| `flat_turn.mp4` | same | same | `env.commands.base_velocity.ranges.ang_vel_z=[0.3,0.3]` |
| `rough_straight.mp4` | `IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E-Rough-Play` | `secylx9i` `model_21000.pt` | `env.scene.terrain.max_init_terrain_level=5` |
| `rough_turn.mp4` | same | same | the level override plus the yaw override above |

`logs/rss_push/videos/flat_policy_on_rough/` holds two earlier rough clips recorded with `secylx9i` `model_20500.pt`, which is the checkpoint the rough run resumed from (the flat policy); they are not on the slides.

One-episode measurements (measured in this session; `examples/RSS/push/eval_drum_push.py --num_envs 1 --speed 0.35 --yaw_rate 0.0|0.3`, plus `--max_level 5` on the rough task; no observation noise; results in `logs/rss_push/eval/*.json`). Each row is a single 12 s episode, separate from the recorded clip:

| Run | Drum speed ratio | Drum travel | Drum speed error | Base speed error | Mean yaw rate | Wrist contact | Non-wrist force | Episode |
|---|---|---|---|---|---|---|---|---|
| Flat policy `yjspqbop` `model_21000.pt`, flat sand, 0.35 m/s | 0.92 | 4.36 m | 0.068 m/s | 0.067 m/s | 0.000 rad/s | 0.74 | 0.0 N | reached 12 s |
| Flat policy, flat sand, 0.35 m/s + 0.3 rad/s yaw | 0.92 | 4.37 m | 0.068 m/s | 0.066 m/s | -0.003 rad/s | 0.75 | 0.0 N | reached 12 s |
| Rough policy `secylx9i` `model_21000.pt`, wave tile row 5, 0.35 m/s | 0.88 | 4.21 m | 0.087 m/s | 0.157 m/s | -0.008 rad/s | 0.67 | 0.0 N | reached 12 s |
| Rough policy, wave tile row 5, 0.35 m/s + 0.3 rad/s yaw | 0.89 | 4.37 m | 0.091 m/s | 0.158 m/s | -0.011 rad/s | 0.68 | 0.0 N | reached 12 s |

- Neither policy turns: the measured yaw rate is 0.00 rad/s against a 0.3 rad/s command. Both were trained with a yaw command range of zero.
- The rough measurements are on one wave tile (terrain type 0) at difficulty row 5 of 0–9.
- A first attempt at a 64-environment evaluation ran out of memory on the 32 GB local GPU; the owner then asked for one environment per run. There is no multi-episode success rate.

Training wall-clock, from W&B history at 01:44 PST (data written to `logs/rss_push/curves/`; "time to 0.8" is the first time the 15-point rolling mean of the object speed ratio reaches 0.8):

| W&B run | Stage | State | Iterations in this run | Wall-clock | Time to speed ratio 0.8 | Last speed ratio |
|---|---|---|---|---|---|---|
| `g1_29dof_object_push_e2e/df0fg7gz` | Rigid ground, box (from scratch, 8 GPUs x 512 envs) | finished | 19,988 | 6.0 h | 0.5 h | 0.87 |
| `g1_29dof_mpm_moving_patch_drum_push_e2e/yjspqbop` | Flat sand, drum (fine-tune, 40 GPUs x 64 envs) | running | 1,440 | 8.1 h | 2.4 h | 0.89 |
| `g1_29dof_mpm_moving_patch_drum_push_e2e/secylx9i` | Rough sand, drum (fine-tune, 40 GPUs x 64 envs) | running | 508 | 3.0 h | 0.3 h | 0.82 |

- The sand runs are fine-tunes and their times exclude the earlier stage. The rough run starts on the easiest terrain row, so its early ratio is on nearly flat ground; at 01:37 PST its mean terrain level was 6.1 of 9 with speed ratio 0.79 and time-out 0.91.

### Clips re-recorded with RTX rendering, 2026-11-16 02:00 PST (Claude session)

At the owner's request the four clips on the slides were re-recorded with `--viz newton_rtx` instead of `--viz newton_gl`, from the same checkpoints (`yjspqbop` `model_21000.pt` and `secylx9i` `model_21000.pt`, passed with `--checkpoint`) and the same command overrides. The RTX clips replace the files of the same names in `logs/rss_push/videos/` and `site/T2/media/`; the earlier GL clips are kept in `logs/rss_push/videos/gl/`. The frame strips in `site/T2/fig/` were regenerated from the RTX clips. The one-episode measurements and the learning-curve data were not rerun and are unchanged. In the RTX clips the drum is drawn with visible flat facets; whether the collision shape is also faceted was not checked.

### Package rename and cube / table tasks, 2026-11-16 (Claude session)

Requested by the owner. All uncommitted on IsaacLab `dcdc2ff3c`; nothing trained, nothing submitted.

- **Rename:** `contrib/push/config/g1_29dof_mpm_moving_patch_drum_push_e2e` → `g1_29dof_mpm_moving_patch_drum_push`. The Gym IDs (`IsaacContrib-Push-Drum-G1-29dof-MPM-MovingPatch-E2E` and variants), the W&B project, and the experiment name are unchanged, so earlier commands and run paths in this file still hold apart from the directory name. The two running jobs use earlier snapshots.
- **Cube:** `g1_29dof_mpm_moving_patch_cube_push`, IDs `IsaacContrib-Push-Cube-G1-29dof-MPM-MovingPatch-E2E` (`-Play`, `-Rough`, `-Rough-Play`). A copy of the drum task with a cube of edge 0.9 m (my choice, so the wrists at 0.83 m meet it near the top edge), 5–15 kg. The object pose observation is `face_aligned_pose_b` (position plus the horizontal direction of the face nearest the robot heading; unchanged by quarter turns). No orientation termination: the cube may tumble. The reference the owner gave for the "Rubik's cube" could not be identified, so the size and the single colour are not taken from it.
- **Table:** `g1_29dof_mpm_moving_patch_table_push`, IDs `IsaacContrib-Push-Table-G1-29dof-MPM-MovingPatch-E2E` (and variants). The cube task with an IKEA LACK side table, modelled in `data/lack_table.usda` as one rigid body with five boxes: top 0.55 × 0.55 × 0.05 m, four legs 0.05 × 0.05 × 0.40 m, height 0.45 m, mass 3–5 kg. Dimensions and the 3.6–4.0 kg weight are from IKEA product listings.

Measured in this session (local RTX 5090):
- Renamed drum task: registers, observation shapes unchanged, mirror reflection exact; the 7 push tests pass.
- Cube and table tasks: observation shapes 1000 / 3 / 1010 / 7 / 150 / 9, mirror reflection exact, `yjspqbop` `model_21000.pt` loads, 3-iteration resume at 32 envs without errors. `face_aligned_pose_b` returned the object yaw unchanged for six test orientations that included quarter and half turns about the horizontal axes.
- Probe without the robot (`push_physics_obj.py`, scratch; object driven to 0.3 m/s by a PI force for 6 s, 2 envs per mass):

| Object | Push height | Masses | Result |
|---|---|---|---|
| Cube, edge 0.6 m | 0.30 m (centre) | 2, 5, 10, 15 kg | tumbles continuously; mean force 5, 16, 38, 57 N; stays within 0.02 m of a straight line (0.11 m for 2 kg) |
| Cube, edge 0.6 m | 0.55 m | 2, 5, 10, 15 kg | tumbles continuously; mean force 3, 7, 17, 29 N |
| LACK table | 0.20 m | 3.6, 8 kg | rolls onto its top within about 0.5 m, then is dragged upside down at 71 and 127 N |
| LACK table | 0.425 m (top edge) | 3.6, 8 kg | keeps tumbling; mean force 23 and 35 N |

- The 0.9 m cube used by the task was not put through this probe; the earlier 1.0 × 0.8 × 1.0 m box pushed at 0.83 m also tumbled (section 11).
- In the 3-iteration resume from the drum policy, the cube task showed wrist contact 0.29 and no falls; the table task showed wrist contact 0.00 and bad-orientation terminations in 89% of episodes.

Open problems: the table top (0.45 m) is below the wrists of the fixed pushing posture (0.83 m), and the table flips on this sand. The table task is not expected to work as built.

### Rubik's-style cube model and previews, 2026-11-16 (Claude session)

- The owner pointed to a Rubik's cube shown with ANYmal in Isaac Lab imagery. That asset was not found in the IsaacLab checkout (`dcdc2ff3c`), on `upstream/main` or `upstream/develop`, or by web search, so its edge length is unknown to this session.
- The cube task now spawns `g1_29dof_mpm_moving_patch_cube_push/data/rubiks_cube.usda`, written in this session: a unit cube with one box collider and 27 grey cubelets for display, scaled by `CUBE_SIZE` (still 0.9 m). Uncommitted.
- Previews (RTX, 3 s clips with the flat drum policy `yjspqbop` `model_21000.pt`, one environment), in `/home/jkamohara/isaac/IsaacLab/logs/rss_push/previews/`: `drum`, `cube` (plain cube, before the model change), `table`, `rubiks_0.90m`, `rubiks_0.33m`, each as `.png`, `.mp4`, and `_strip.png`. The 0.33 m size is an estimate from the picture, set by command-line overrides for the preview only.
- Observed in the previews: at 0.33 m the cube is below the robot's knees; at 0.90 m its top is at chest height.

### Cube task aligned with the RSL cube and reworked for leg pushing, 2026-11-16 (Claude session)

The owner asked to align the cube with the paper. Uncommitted on IsaacLab `dcdc2ff3c`; not trained, not submitted.

- Size and mass: `CUBE_SIZE = 0.40` m, nominal 4.6 kg, randomised 3.5–6.0 kg. The 40 cm and 4.6 kg figures are from press coverage of "Solving a Giant Rubik's Cube with a Quadruped Robot" (ETH RSL); the paper was not opened, so they are not verified against it.
- Because a 0.40 m cube is below the wrists' reach (about 0.55 m at the lowest, 0.83 m in the fixed posture), the task now rewards pushing with the legs: pushing bodies are `hip_yaw_link` (thigh), `knee_link` (shank), `ankle_pitch_link`, and `ankle_roll_link` of each leg; all other bodies are penalised. New reward functions `push_progress` and `push_contact` in the cube package give full credit when any pushing body touches. Reset places the cube's near face 0.25–0.55 m ahead of the pelvis. The arm posture is unchanged.
- One shared file changed: `g1_29dof_object_push_e2e/mdp/commands.py`. Each entry of `hand_body_names` may now be an expression matching several bodies, and a group counts as touching when any of its bodies does. For single-body entries (all existing tasks) the metric is computed as before. The 7 push tests pass and the drum task's check is unchanged.
- The table task still imports `face_aligned_pose_b` and `reset_object_on_sand` from the cube package and is otherwise untouched (wrist pushing, not expected to work).

Measured in this session (local RTX 5090):
- Probe, cube 0.40 m driven at 0.3 m/s without the robot, 2 envs per case: it tumbled in every case. Mean force over the last 4 s: pushed at 0.10 m above the ground 34, 46, 39, 65 N for 3.5, 4.6, 4.6, 6 kg; pushed at 0.30 m 6, 8, 8, 10 N.
- Playing the flat drum policy on the task, the only bodies that touched the cube were the thighs (`hip_yaw_link`, about 190–235 N at impact); the shanks and feet never did. The robot's leg shapes and the cube are in the same collision group with no filter between them. This is why the thighs were added to the pushing bodies.
- Observation shapes unchanged, mirror reflection exact, `yjspqbop` `model_21000.pt` loads.
- 60-iteration local resume from that checkpoint at 32 envs: bad-orientation terminations 1.00 throughout, mean episode length about 44 steps (0.9 s), `hand_contact_fraction` 0.01–0.05, cube speed ratio 0.02–0.08. Too short and too small to judge learnability.
- Preview at the new size: `/home/jkamohara/isaac/IsaacLab/logs/rss_push/previews/rubiks_0.40m.{png,mp4}` and `rubiks_0.40m_strip.png`.

### Rigid table task and first rigid table run, 2026-11-16 16:00 PST (Claude session)

Requested by the owner ("do we have rigid table push task? If not implement it and throw job to osmo"). Uncommitted on IsaacLab `dcdc2ff3c`.

- New package `contrib/push/config/g1_29dof_table_push`, Gym ID `IsaacContrib-Push-Table-Flat-G1-29dof` (`-Play`): the rigid box task `g1_29dof_object_push_e2e` with the IKEA LACK table (0.55 × 0.55 × 0.45 m, 3–5 kg) and leg pushing. Pushing bodies are the thighs (`hip_yaw_link`), shanks, and feet; `push_progress` and `push_contact` credit any leg in contact; all other bodies are penalised. The box task's tilt penalty (−10) and tilt termination (0.5 rad) are kept for the table. The owner had not said whether legs or arms should push; leg pushing is my choice, since the table top is below the wrists' reach.
- Two additions made after a first local run stalled (below): the table's near edge starts 0.15–0.35 m ahead of the pelvis (was 0.25–0.55 m), and a new reward `object_proximity` (weight 1.0, `exp(-gap / 0.2)`, gap measured beyond a 0.375 m pelvis-to-table-centre clearance) draws the robot to the table. `object_proximity` lives in the cube package's `mdp/rewards.py`.
- USD models are now generated in code: `contrib/push/util/generated_assets.py` (`lack_table_usd`, `rubiks_cube_usd`) writes them to a temp cache directory. The repository's `.gitignore` excludes all `*.usda`, so the earlier `data/*.usda` files were not in the OSMO snapshot; they are deleted. The sand cube and sand table tasks use the same generated models and still pass their checks.

Measured in this session (local RTX 5090, 2,048 envs, from scratch):

| Variant | Iterations | Leg contact fraction | Table speed ratio | Time-out rate |
|---|---|---|---|---|
| Near edge 0.25–0.55 m ahead, no proximity reward | 500 | 0.00 | 0.00 | 0.98 |
| Near edge 0.15–0.35 m ahead, with proximity reward | 600 | 0.08, rising from 0.005 at iteration 150 | 0.02 | 0.91 |

Neither is a working policy. The second was submitted because contact was rising.

OSMO:
- `isaac-lab-g1-table-push-1` failed after about 2 minutes: `FileNotFoundError` for `g1_29dof_mpm_moving_patch_table_push/data/lack_table.usda` (the ignored-file problem above).
- `isaac-lab-g1-table-push-2`: pool `isaac-lab-l40-07`, platform `ovx-l40`, 8 GPUs × 512 envs, from scratch, W&B project `g1_29dof_table_push`, run name `table_rigid_legs_8gpu`. Training iterations were being logged at 16:01 PST. No result yet.

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=8 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-table-push platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Table-Flat-G1-29dof --num_envs 512 --logger wandb --run_name table_rigid_legs_8gpu --video --video_length 200"
```

### Rigid table task changed to arm pushing from a squat, 2026-11-16 16:50 PST (Claude session)

The owner corrected the previous design: push the table with the arms, not the legs; the table stays upright; otherwise the rigid box task. `isaac-lab-g1-table-push-2` (leg pushing, W&B `g1_29dof_table_push/fgqmxak8`) was cancelled; the owner saw that it did not crouch to the table. Uncommitted on IsaacLab `dcdc2ff3c`.

`g1_29dof_table_push` (`IsaacContrib-Push-Table-Flat-G1-29dof`) was rebuilt from the rigid box design with wrist pushing. What differs from the box task:
- Object: IKEA LACK table (generated model), 3–5 kg.
- Default posture and reset: a squat (knees 2.00 rad, ankles −0.70 rad, hips −1.55 rad, waist 0.35 rad, shoulders −0.90 rad, elbows 0.60 rad), pelvis 0.50 m, pitched 0.25 rad forward.
- Pelvis height band 0.38–0.60 m (box: 0.65–0.80); free forward lean 0.60 rad pelvis and 0.95 rad torso (box: 0.35); orientation termination 1.0 rad (box: 0.79).
- Table near edge 0.02–0.15 m beyond the wrists at reset; reward `object_proximity` (weight 1.0) for approaching.
- Kept from the box task: wrist-gated progress, wrist contact reward, penalty on other-body contact, tilt penalty −10 and tilt termination 0.5 rad, observations, networks.

Measured in this session (local RTX 5090):
- Kinematic sweep: standing, the lowest wrist height with the wrists ahead of the body is about 0.62 m; the wrists reach 0.42–0.45 m only with the pelvis near 0.45–0.56 m and the torso bowed forward.
- Holding constant joint targets (no policy), none of 120 squat postures stayed up: with the arms forward they fell forward, with the arms down backward. Only a full squat resting on the knee joint limit (pelvis 0.27 m) settled.
- Training from scratch, 2,048 envs:

| Variant | Iterations | Time-out rate | Wrist contact | Table speed ratio | Table tilt terminations |
|---|---|---|---|---|---|
| Near edge 0.05–0.30 m beyond the wrists, no approach reward | 600 | 1.00 | 0.01–0.03 | 0.00 | 0.00 |
| Near edge 0.02–0.15 m, with approach reward | 630 | 0.98 | 0.93 | 0.00–0.02 | 0.00 |

So the policy learns to balance in the squat and to hold its wrists on the table, but had not moved the table by 630 iterations. The rigid box run was at a comparable point (contact 0.7–0.8, ratio 0.06) between iterations 300 and 800, before it took off.

OSMO: `isaac-lab-g1-table-push-3`, pool `isaac-lab-l40-07`, 8 GPUs × 512 envs, from scratch; W&B `jnskkmr/g1_29dof_table_push/i1dzx8ro`, run name `table_rigid_arms_squat_8gpu`. First iteration logged at 16:50 PST. No result yet. Command as for `-2` with `--run_name table_rigid_arms_squat_8gpu`.

The sand table task `g1_29dof_mpm_moving_patch_table_push` still has the standing wrist-push design and is not expected to work.

### Rigid table task: hold with the wrists, push with the thighs, taller table, 2026-11-16 17:47 PST (Claude session)

The squat run `isaac-lab-g1-table-push-3` (W&B `g1_29dof_table_push/i1dzx8ro`) stalled and was cancelled: at 1,806 iterations (0.52 h) wrist contact 0.95, time-out 1.00, table speed ratio 0.001 (measured in this session). The owner then set the design: make the table higher so the robot does not crouch much, lock the table with the arms, and push partly with hip/knee/pelvis. On my recommendation they chose pressing down on the tabletop over clamping the sides, and a 0.72 m table. Uncommitted on IsaacLab `dcdc2ff3c`.

`g1_29dof_table_push` (`IsaacContrib-Push-Table-Flat-G1-29dof`) now differs from the rigid box task as follows:
- Table: LACK model scaled 1.6, 0.88 × 0.88 × 0.72 m, 4–8 kg.
- Posture: standing, box-task arm posture, waist pitch 0.30 rad so the wrists rest on the top.
- Wrists hold; the box task's wrist-gated progress and wrist contact rewards are unchanged, so progress is paid in proportion to the wrists on the table.
- Pelvis, hips, thighs, and knees may touch the table (they push the edge). Penalised bodies: torso, waist, head, shoulders, elbows, ankles.
- Free torso lean 0.60 rad (box 0.35). Reset: near edge 0.03–0.15 m ahead of the thighs. `object_proximity` reward, weight 1.0.
- Unchanged from the box task: pelvis height band, pelvis lean band, orientation termination, tilt penalty and tilt termination, remaining rewards, observations, networks.

Measured in this session (local RTX 5090):
- Zero actions, 8 envs, 200 steps: no falls; pelvis 0.74 m; each wrist on the table at about 20 N; table upright and stationary.
- Training from scratch, 2,048 envs, stopped by a time limit at 669 iterations:

| Iteration | Table speed ratio | Wrist contact | Time-out rate | Table tilt terminations | Force on non-wrist bodies |
|---|---|---|---|---|---|
| 50 | 0.02 | 0.41 | 0.56 | 0.00 | 97 N |
| 250 | 0.21 | 0.76 | 0.99 | 0.00 | 83 N |
| 400 | 0.67 | 0.62 | 0.99 | 0.00 | 101 N |
| 650 | 0.78 | 0.70 | 0.98 | 0.00 | 104 N |

- The non-wrist force is mostly the thigh and hip push, which this design allows; the penalty on prohibited bodies was about −0.06 per episode at the end.
- Clip of the 500-iteration local checkpoint: `/home/jkamohara/isaac/IsaacLab/logs/rss_push/previews/table_rigid_hold_local500.mp4` (GL viewer; frames in `..._strip.png`). Five frames show the robot behind the table with its wrists on the top and the table advancing. Not watched in motion.

OSMO: `isaac-lab-g1-table-push-4`, pool `isaac-lab-l40-07`, 8 GPUs × 512 envs, from scratch; W&B `jnskkmr/g1_29dof_table_push/lntz7ql0`, run name `table_rigid_hold_and_push_8gpu`. Training iterations logged from 17:46 PST. No result from the cluster run yet.

Not done: any evaluation; the sand table task (`g1_29dof_mpm_moving_patch_table_push`) still has the old standing wrist-push design at the real table size.

### Real table (IKEA LINNMON / ADILS) and sand table fine-tune, 2026-11-16 23:30 PST (Claude session)

Requests from the owner: update the table to one that can be bought and relaunch; then add the MPM moving-patch table task following the env construction skill and submit it on 40 GPUs. Uncommitted on IsaacLab `dcdc2ff3c`.

Cluster result for the stand-in table (LACK scaled 1.6, 0.88 × 0.88 × 0.72 m, 4–8 kg), W&B `g1_29dof_table_push/lntz7ql0` (`isaac-lab-g1-table-push-4`), read at 18,453 iterations, 5.07 h, 8 GPUs × 512 envs (measured in this session): table speed ratio 0.87, wrist contact 0.91, time-out 1.00, table tilt terminations 0, base velocity error 0.10 m/s. The run was left to finish.

Table model changed to the IKEA LINNMON / ADILS in both table tasks:
- `contrib/push/util/generated_assets.py: linnmon_table_usd(foot_radius)`: top 1.00 × 0.60 × 0.034 m, four round legs 0.04 m in diameter, height 0.74 m, pushed along the long side; `TABLE_FOOT_RADIUS = 0.05` adds a 0.10 m disc under each leg. Mass 4.0–9.5 kg (real table about 8 kg from listed part weights: top 4.6 kg, four legs 0.86 kg each).
- Default waist pitch 0.20 rad (was 0.30) so the wrists rest on the 0.74 m top.
- The top edge is at waist height, so the lower torso and waist were added to the bodies allowed to push; penalised bodies are now head, shoulders, elbows, ankles.

Measured in this session (local RTX 5090):
- Rigid, zero actions: no falls; wrists on the table at 15–19 N each; the lower torso and pelvis also touch the edge.
- Rigid, from scratch, 2,048 envs, 620 iterations, mass 6.5–9.5 kg: wrist contact 0.96, time-out 1.00, table speed ratio 0.006 (held the table, did not move it).
- Rigid, resumed from `lntz7ql0` `model_18000.pt`, 2,048 envs, 400 iterations, mass 4.0–9.5 kg: table tilt terminations 0.45 at first, then speed ratio 0.51 and rising, wrist contact 0.86, time-out 0.995, tilt 0.002.
- Sand, zero actions, 4 envs, bare legs: table sank 0.09 m in 0.2 s and 0.18 m by 2 s. With disc feet of radius 0.05 m: 0.05 m and steady; radius 0.08 m: 0.035–0.04 m. In all three the zero-action robot itself fell within 3 s, as it does on sand without a policy.
- Sand table task: observation shapes 1000 / 3 / 1010 / 7 / 150 / 9, mirror reflection exact, a rigid table checkpoint loads, 4-iteration resume at 32 envs without errors.

Sand table task `g1_29dof_mpm_moving_patch_table_push` (IDs `IsaacContrib-Push-Table-G1-29dof-MPM-MovingPatch-E2E`, `-Play`, `-Rough`, `-Rough-Play`) now mirrors the rigid table task: same table, default posture, wrist-hold rewards, allowed and penalised bodies, tilt penalty and tilt termination, `object_proximity`, torso lean band, reset distance, mass range, and the box task's full table pose observation. Scene, gait rewards, patch terminations, and blow-up handling are those of the sand drum task.

OSMO:
- `isaac-lab-g1-table-push-5`: rigid LINNMON, 8 GPUs × 512 envs, resumed from `lntz7ql0`; W&B `g1_29dof_table_push/a70na3on` (`linnmon_rigid_hold_and_push_from_lntz7ql0_8gpu`). Submitted before the disc feet were added to the model. At 23:18 PST, about 1,000 iterations after the resume: table speed ratio 0.59, wrist contact 0.90, time-out 0.99, tilt 0.008. Still running.
- `isaac-lab-g1-mpm-table-push-1`: sand, pool `isaac-lab-l40-07`, 40 GPUs × 64 envs, resumed from `a70na3on` (`model_20000.pt`), W&B project `g1_29dof_mpm_moving_patch_table_push`, run name `sand_table_from_a70na3on_40gpu`. All workers running at 23:31 PST; no iteration logged yet. No result.

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=40 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-mpm-table-push platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Table-G1-29dof-MPM-MovingPatch-E2E --num_envs 64 --wandb_run a70na3on --wandb_project g1_29dof_table_push --logger wandb --log_project_name g1_29dof_mpm_moving_patch_table_push --run_name sand_table_from_a70na3on_40gpu --viz newton_gl --video --video_length 200"
```

Caveats: the rigid policy the sand run starts from is only partly trained on the LINNMON (speed ratio 0.59) and was trained without the disc feet; the disc feet are not part of the product; whether the table tips or digs in when pushed on sand by the robot has not been measured.

### Chair task (IKEA SANDSBERG), rigid ground, 2026-11-17 (Claude session)

Requested by the owner, who cancelled the table jobs and asked for the IKEA SANDSBERG chair, held by the arms and pushed by walking, as a rigid-ground run in a task named `*_push_chair`. Uncommitted on IsaacLab `dcdc2ff3c`.

- Cancelled: `isaac-lab-g1-table-push-5` (W&B `a70na3on`) and `isaac-lab-g1-mpm-table-push-1` (W&B `g1_29dof_mpm_moving_patch_table_push/budyji0b`, only its first iterations logged). `isaac-lab-g1-table-push-4` (`lntz7ql0`) had already finished. The table packages are left in place.
- New package `contrib/push/config/g1_29dof_push_chair`, Gym ID `IsaacContrib-Push-Chair-Flat-G1-29dof` (`-Play`), copied from the rigid table task. Chair: 0.47 m deep, 0.39 m wide, 0.77 m high, seat top 0.45 m, 2.0–3.5 kg; dimensions and the 2.5 kg weight (package weight 5 lb 9 oz) from the IKEA US product page. Model `sandsberg_chair_usd` in `contrib/push/util/generated_assets.py`: seat slab, upright backrest slab, four straight legs of 0.024 m diameter; the real backrest and legs are shaped differently.
- The owner's screenshot could not be read (a path on another machine).
- Chair and ground friction 0.3 (my choice). Checked in the model: chair shapes 0.3, ground 0.3, robot shapes 1.0.
- Default posture: waist 0.10 rad, shoulders −0.40 rad, elbows 1.10 rad; the wrists sit behind the upper backrest. The backrest starts 0.02–0.13 m beyond the wrists. Everything else is the rigid table task.

Measured in this session (local RTX 5090, 2,048 envs, from scratch):

| Variant | Iterations | Chair speed ratio | Wrist contact | Time-out rate | Chair tilt terminations | Force on non-wrist bodies |
|---|---|---|---|---|---|---|
| Friction 0.9 ground, wrists above the backrest top | 451 | 0.01–0.03 | 0.00–0.02 | 0.97 | 0.36 at iteration 100, then 0.01–0.02 | 95 N |
| Friction 0.3, wrists behind the backrest | 264 | 0.77 | 0.11 | 0.89 | 0.01 | 126 N |

- In the second variant the chair moves at the commanded speed but mostly through body contact; the wrist hold is low and was rising (0.00 → 0.11).
- With zero actions the robot in this posture falls forward within about a second; the trained policy does not (time-out 0.89).

OSMO: `isaac-lab-g1-push-chair-1`, pool `isaac-lab-l40-07`, 8 GPUs × 512 envs, from scratch, W&B project `g1_29dof_push_chair`, run name `chair_rigid_hold_and_push_8gpu`. Submitted; no result yet.

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=8 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-push-chair platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Chair-Flat-G1-29dof --num_envs 512 --logger wandb --run_name chair_rigid_hold_and_push_8gpu --video --video_length 200"
```

### Chair task: straight-pushing penalties, 2026-11-17 (Claude session)

- First chair run `isaac-lab-g1-push-chair-1` (W&B `g1_29dof_push_chair/jhnkr45g`), read at 1,679 iterations, 0.50 h, 8 GPUs × 512 envs (measured in this session): chair speed ratio 0.85, wrist contact 0.42, time-out 0.99, chair tilt terminations 0, force on non-wrist bodies 53 N, heading error (`error_yaw`) 0.31 rad. Cancelled at the owner's request for the change below.
- The owner asked for a penalty so the torso faces the direction of travel and the robot pushes straight, with the object's velocity equal to the robot's. Added to `g1_29dof_push_chair` (new `mdp/rewards.py`):
  - `torso_heading_alignment`, weight −5.0: `1 − cos` of the angle between the torso link's horizontal heading and the robot root's horizontal velocity, zero below 0.05 m/s.
  - `object_velocity_match`, weight −2.0: squared difference of the horizontal velocities of the chair and the robot root.
  The weights are my choice and are not tuned.
- Local check: a 40-iteration run at 1,024 envs ran without errors and logged both terms. No longer local run with the penalties.
- OSMO: `isaac-lab-g1-push-chair-2`, pool `isaac-lab-l40-07`, 8 GPUs × 512 envs, from scratch, W&B project `g1_29dof_push_chair`, run name `chair_rigid_straight_push_8gpu`. Same command as `-1` with that run name. No result yet.

### Rigid chair result and sand chair task, 2026-11-17 (Claude session)

Rigid chair run with the straight-pushing penalties, `isaac-lab-g1-push-chair-2`, W&B `g1_29dof_push_chair/u7fpcvfe`, finished: 20,000 iterations, 5.77 h, 8 GPUs × 512 envs, from scratch. Final W&B summary (measured in this session): chair speed ratio 0.87, wrist contact 0.27, time-out 1.00, chair tilt terminations 0, heading error 0.095 rad (0.31 rad in the run without the penalties), `torso_heading_alignment` −0.067 and `object_velocity_match` −0.025 per episode. Training values only; no evaluation, no video inspected. The wrists hold the backrest about a quarter of the time, so most of the push comes from the body.

Sand chair task, requested by the owner ("craft task directory for chair pushing on MPM; you can use pretrained policy from rigid terrain"). Uncommitted on IsaacLab `dcdc2ff3c`:
- Package `contrib/push/config/g1_29dof_mpm_moving_patch_push_chair`; Gym IDs `IsaacContrib-Push-Chair-G1-29dof-MPM-MovingPatch-E2E` and `-Play`, `-Rough`, `-Rough-Play`. Layout per `skills/env_construction.md`: `agents/`, `env_cfg/` (one file per manager plus terrain), `mdp/`, `__init__.py`, `push_chair_env_cfg.py`, `README.md`. Built from the sand table package.
- Chair, default posture, mass range, reset distance, wrist-hold rewards, allowed and penalised bodies, tilt penalty and termination, approach reward, straight-pushing penalties, and the full object pose observation are those of the rigid chair task. MDP functions are imported from the rigid chair, cube, drum, and box packages.
- Disc feet: `CHAIR_FOOT_RADIUS = 0.04` in both chair tasks.

Measured in this session (local RTX 5090):
- Zero actions on sand, 4 envs: on bare legs the chair sank 0.064 m in 0.2 s and was 0.10–0.14 m down after later resets; with 0.04 m-radius feet 0.036–0.048 m. The zero-action robot fell in both cases, as it does on sand without a policy, and knocked the chair over.
- Observation shapes 1000 / 3 / 1010 / 7 / 150 / 9; mirror reflection exact; `u7fpcvfe` `model_19999.pt` loads; a 4-iteration resume at 32 envs ran without errors (first iterations: bad orientation 0.67, chair tilted 0.15, as expected before any sand training).

Not done: no sand training has been submitted for the chair. Fine-tune command:

```bash
bash osmo/run_multinode.sh osmo/osmo_multi_gpu.yaml --pool isaac-lab-l40-07 --set num_nodes=40 num_gpu=1 \
  --set-string workflow_name=isaac-lab-g1-mpm-push-chair platform=ovx-l40 \
  output_url=swift://pdx.s8k.io/AUTH_team-isaac-sqa/isaac-sqa/jkamohara/g1-object-push/runs \
  wandb_credential=wb-auth wandb_key=wb_api_key \
  args="--task IsaacContrib-Push-Chair-G1-29dof-MPM-MovingPatch-E2E --num_envs 64 --wandb_run u7fpcvfe --wandb_project g1_29dof_push_chair --logger wandb --log_project_name g1_29dof_mpm_moving_patch_push_chair --run_name sand_chair_from_u7fpcvfe_40gpu --viz newton_gl --video --video_length 200"
```

## Sand chair fine-tune submitted, 2026-11-17 19:30 PST (Claude session)

Command above, three submissions:

- `isaac-lab-g1-mpm-push-chair-1`: failed at startup on all workers, `ImportError: cannot import name 'heading_velocity_misalignment' from '...g1_29dof_push_chair.mdp' (unknown location)`. The files are in the snapshot and the import works locally. The trainer log shows 19 "Encountering too many requests" retries during the snapshot download. Cause not confirmed; it did not recur on jobs 2 and 3 with the same code.
- `isaac-lab-g1-mpm-push-chair-2` (W&B `nwfjm2lw`): rank 19 crashed with `Warp CUDA error 700: illegal memory access` during the first rollout steps (surfaced at a reward term reading the height sensor); ranks 15, 17, 18, 21 then died with NCCL remote errors and the other 36 hung for 1.5 h with no learning iteration. Cancelled. Root cause unknown; not reproduced.
- `isaac-lab-g1-mpm-push-chair-3`: all 40 workers running, training started (iteration 20001/39999; first iterations speed ratio 0.19, wrist contact 0.10). Measured in this session from the trainer log; no video inspected.

Open: if the CUDA error 700 crash recurs later in training, find the triggering state before resubmitting.

## Tow task and first tow check, 2026-11-19 (Claude session)

Owner decisions on 2026-11-19: pushing trains on one fixed sand material without material randomization; try towing an object by a rope tied to the pelvis, walking forward. No tow or push policy has been trained.

Code: unified IsaacLab `~/isaac/worktrees/mpm-unification/IsaacLab`, branch `jnskkmhr/mpm-unification`, HEAD `a60612c79`, **dirty tree** (other sessions' changes plus the untracked files below; nothing committed).

New, untracked:

| Path | What |
|---|---|
| `contrib/push/config/g1_29dof_mpm_tow/` | `IsaacContrib-Tow-G1-29dof-MPM` (`-Play`): the streaming MPM walking task with a sled and a rope; standalone configs, walking observation layout unchanged |
| `contrib/push/config/g1_29dof_rigid_tow/` | `IsaacContrib-Tow-G1-29dof-Rigid` (`-Play`): the same on rigid ground, copied from the soft-contact flat task with its analytical sand force switched off |
| `contrib/push/util/tether.py` | The rope: one-sided spring and damper (1000 N/m, 40 N s/m, 1.2 m), pelvis back to the sled's front face 0.05 m above its bottom, recomputed once per control step |
| `scripts/benchmarks/t2/tow_check.py` | Runs a walking policy on either `-Play` task, one sled mass per environment |

Sled in both tasks: 0.3 m cube, 10 kg, friction 0.5 (rigid ground friction 0.5). Sand: nominal `poppy_seed_loose` (density 640 kg/m3, friction 0.73), flat, depth 0.25 m.

Tow check, measured in this session. Walking policies that never saw the rope, 0.5 m/s forward command, 16 s, one environment per mass, one run each; speed and rope tension are means over the last 8 s. Raw data `logs/t2/tow/pkg_cube_*.{json,npz}`. Nobody fell.

| Ground | Policy | 5 kg: speed | 5 kg: tension | 10 kg: speed | 10 kg: tension | 10 kg: sled travel in 16 s |
|---|---|---|---|---|---|---|
| rigid | MPM-trained `jqur5jhm` | 0.44 m/s | 22 N | 0.37 m/s | 44 N | 5.6 m |
| rigid | rigid-trained `3qymp37c` | 0.42 m/s | 22 N | 0.33 m/s | 44 N | 5.0 m |
| sand | MPM-trained `jqur5jhm` | 0.31 m/s | 30 N | 0.02 m/s | 50 N | 0.3 m |
| sand | rigid-trained `3qymp37c` | 0.37 m/s | 33 N | 0.01 m/s | 56 N | 0.7 m |

- Ground changes the outcome: the 10 kg cube is towed at 0.33-0.37 m/s on rigid ground and both policies stall on sand.
- The training ground of the walking policy does not: the rigid-trained policy is not worse than the MPM-trained one on sand.
- Object shape matters little at these masses (`logs/t2/tow/cand_*`, MPM-trained policy, sand, 5 kg): 0.5 x 0.4 x 0.2 m sled 0.35 m/s at 27 N; 0.3 m cube 0.29 m/s at 31 N; 0.2 x 0.2 x 0.3 m block 0.29 m/s at 32 N. On rigid ground all three give 0.44 m/s at 22 N.
- Without a rope the policies walk at 0.46 m/s (MPM-trained) and 0.53 m/s (rigid-trained) on this sand (`logs/t2/tow/check_nominal*`).

Not done: the force probe report (sweep still running, `logs/t2/probe/`); any tow training; an evaluation with several trials and seeds; rough or sloped sand.

## Force probe before pushing training (tasks/T2.md step 3), 2026-11-19 (Claude session)

Slides: [site/T2/index.html](../site/T2/index.html). Everything below is measured in this session and unchecked.

Code: unified IsaacLab `~/isaac/worktrees/mpm-unification/IsaacLab`, branch `jnskkmhr/mpm-unification`, commit `a60612c79`, **dirty tree** (other sessions' uncommitted work; the probe scripts are untracked files and change no shared code). Newton `7adb5be70`, clean tree. GPU: one RTX 5090.

Scripts (untracked): `scripts/benchmarks/t2/force_probe.py` (runs), `summarize_probe.py` (tables, figures), `probe_slides.py` (slides). Raw data: `logs/t2/probe/*.json|npz` in that worktree, `queue.txt` and `queue2.txt` hold every command, `summary.json` and `summary.md` hold all 516 object cases, `notes.json` the conclusions shown on the slides.

Method:
- Objects: `IsaacContrib-Velocity-G1-29dof-MPM-Locomanip-Play` with preset `solver_cfg_all_active_cache`, flat terrain, sand depth 0.35 m, voxel 0.03 m; the task's three objects are replaced by the probed set, each with its own streaming pool (1.2 m; 1.6 m for drum and big box). The robot is parked 3 m behind with zero actions. No policy.
- Drive: after 2 s of settling, a PI controller applies a horizontal force along +x to hold 0.3 m/s for 8 s (target raised over 1 s, force 0 to 400 N). The force acts at a fixed height above the settled sand surface: force at the centre of mass plus the pitch moment. One environment per push height: 0.05 m, 0.20 m (shin), 0.70 m (wrist); 0.30 m (top edge) for the 0.30 m tall objects.
- Force reported: mean from 1.5 s after the start to the end of the drive, or until the tilt passes 30 degrees ("tips").
- Rigid ground: the same drive on `IsaacContrib-Velocity-Flat-G1-29dof-Rigid-Play`, object and ground friction 0.5. Object friction on sand is 0.5.
- Materials (density kg/m3, Young's modulus Pa, friction, yield pressure Pa): nominal = `poppy_seed_loose` (640, 1e15, 0.73, 1e15), the sand of the `-Play` configs; training low end (1000, 1e7, 0.30, 1e8); training high end (3000, 1e9, 0.90, 1e9); heavy_grippy (3000, 1e15, 0.90, 1e15); heavy_slippery (3000, 1e15, 0.30, 1e15); sand (1600, 1e15, 0.48, 1e15); beach_sand (1800, 1e15, 0.80, 1e15); and one-at-a-time variants around (2000, 1e8, 0.60, 3.16e8).
- Traction: `IsaacContrib-Velocity-G1-29dof-MPM-Play`, preset `solver_cfg_cache`, flat, walking policy `jqur5jhm` `model_19999.pt` (sha256 `0852d6160c91`), command 0.3 m/s forward. Ramp: backward force growing 4 N/s to 120 N on 8 robots. Hold: one level per robot for 12 s.

**Was randomization on in section 11?** Yes. Section 11 ran the training config `IsaacContrib-Push-Box-G1-29dof-MPM-MovingPatch-E2E`, which keeps the `mpm_material` and `mpm_material_log` reset events, so each of its 8 environments had a different random sand. This probe shows the randomization was not the cause: on the nominal sand the big box still tips at wrist height at every mass, and the nominal sand is harder than the high end of the ranges.

### Force G1 sustains while walking

| Sand | Force on | Speed without force | Force at half speed, median (range) | Force at standstill, median (range) | Falls |
|---|---|---|---|---|---|
| nominal | pelvis, command 0.3 m/s | 0.30 m/s | 24 N (17-26) | 53 N (49-56) | 0 of 8 |
| nominal | pelvis, command 0.6 m/s | 0.61 m/s | 53 N (50-54) | 61 N (60-62) | 0 of 8 |
| train_high | pelvis, command 0.3 m/s | 0.29 m/s | 20 N (18-26) | 44 N (35-50) | 0 of 8 |
| train_low | pelvis, command 0.3 m/s | 0.24 m/s | 20 N (19-22) | 53 N (50-54) | 0 of 8 |
| nominal | left_knee_link, right_knee_link, command 0.3 m/s | 0.30 m/s | 78 N (75-80) | not reached by 120 N | 0 of 8 |
| nominal | torso_link, command 0.3 m/s | 0.30 m/s | 17 N (16-18) | 33 N (31-36) | 0 of 8 |

Held force on the pelvis, mean forward speed over the last 6 s [m/s], one robot per level, no falls:

| Sand | 10 N | 20 N | 30 N | 40 N | 50 N | 60 N | 70 N | 80 N |
|---|---|---|---|---|---|---|---|---|
| beach_sand | 0.24 | 0.18 | 0.12 | 0.04 | 0.01 | -0.01 | -0.10 | -0.63 |
| heavy_grippy | 0.26 | 0.19 | 0.12 | 0.02 | 0.01 | -0.00 | -0.39 | -0.62 |
| heavy_slippery | 0.18 | 0.15 | 0.11 | 0.05 | -0.01 | -0.37 | -0.46 | -0.53 |
| nominal | 0.24 | 0.19 | 0.14 | 0.08 | 0.02 | -0.05 | -0.41 | -0.62 |
| sand | 0.22 | 0.17 | 0.12 | 0.07 | 0.00 | -0.27 | -0.49 | -0.59 |
| train_high | 0.24 | 0.19 | 0.13 | 0.01 | 0.01 | -0.00 | -0.29 | -0.60 |
| train_low | 0.20 | 0.16 | 0.12 | 0.08 | -0.26 | -0.35 | -0.44 | -0.54 |

With the MPM-trained walking policy, G1 walks at half the commanded speed against about 20 N on the pelvis and stops at about 50 N, on every sand tried. The robot weighs 324 N, so this is the limit of a policy never trained against a load, not of foot friction. A force at shin height is tolerated up to about 78 N at half speed. This fills the open value "Force G1 can sustain while walking on sand": about 20 N at half speed and about 50 N at standstill on the pelvis, measured as above.

### Box, 0.3 m cube

Tips at shin height (0.20 m) on every sand and every mass. Slides only when pushed 0.05 m above the sand on sand with friction 0.9 (16 N at 2 kg, 47 N at 5 kg). On rigid ground it slides at 0.5 x weight at both heights.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.30 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | slides 10 N | slides 10 N | tips at once | 0.0 cm | n/a |
| rigid | 5 kg | slides 24 N | slides 24 N | tips at once | 0.0 cm | n/a |
| rigid | 10 kg | slides 49 N | slides 49 N | tips at once | 0.0 cm | n/a |
| rigid | 15 kg | slides 73 N | slides 73 N | tips at once | 0.0 cm | n/a |
| nominal | 2 kg | tips (39 N before) | tips at once | tips at once | -1.3 cm | 1.8 cm |
| nominal | 5 kg | tips (80 N before) | tips at once | tips at once | -0.8 cm | 3.7 cm |
| nominal | 10 kg | tips (129 N before) | tips at once | tips at once | -0.1 cm | 4.2 cm |
| nominal | 15 kg | tips (167 N before) | tips at once | tips at once | 0.6 cm | 5.6 cm |
| train_high | 2 kg | slides 16 N | tips at once | tips at once | -2.0 cm | 1.7 cm |
| train_high | 5 kg | slides 47 N | tips at once | tips at once | -1.8 cm | 1.9 cm |
| train_high | 10 kg | slides 120 N | tips at once | tips at once | -1.5 cm | 2.3 cm |
| train_high | 15 kg | slides 223 N | tips at once | tips at once | -1.3 cm | 2.9 cm |
| heavy_grippy | 5 kg | slides 50 N | tips at once | tips at once | -1.8 cm | 2.1 cm |
| heavy_grippy | 15 kg | slides 244 N | tips at once | tips at once | -1.3 cm | 3.8 cm |
| beach_sand | 5 kg | slides 68 N | tips at once | tips at once | -1.4 cm | 2.7 cm |
| beach_sand | 15 kg | tips (228 N before) | tips at once | tips at once | -0.9 cm | 3.8 cm |
| sand | 5 kg | tips (85 N before) | tips at once | tips at once | -0.8 cm | 3.0 cm |
| sand | 15 kg | tips (179 N before) | tips at once | tips at once | 0.1 cm | 4.0 cm |
| heavy_slippery | 5 kg | tips (89 N before) | tips at once | tips at once | -0.9 cm | 1.5 cm |
| heavy_slippery | 15 kg | tips (193 N before) | tips at once | tips at once | -0.0 cm | 3.2 cm |
| train_low | 2 kg | tips (34 N before) | tips at once | tips at once | -0.5 cm | 2.5 cm |
| train_low | 5 kg | tips (67 N before) | tips at once | tips at once | 0.2 cm | 3.9 cm |
| train_low | 10 kg | tips (108 N before) | tips at once | tips at once | 1.5 cm | 5.6 cm |
| train_low | 15 kg | tips (142 N before) | tips at once | tips at once | 2.7 cm | 6.9 cm |

### Upright cylinder, radius 0.15 m, height 0.3 m

Same as the box: tips at 0.20 m on every sand; slides at 0.05 m only on the high-friction sands up to 10 kg.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.30 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | tips (6 N before) | slides 10 N | tips at once | 0.0 cm | n/a |
| rigid | 5 kg | tips (14 N before) | slides 24 N | tips at once | 0.0 cm | n/a |
| rigid | 10 kg | tips (28 N before) | slides 48 N | tips at once | 0.0 cm | n/a |
| rigid | 15 kg | tips (46 N before) | slides 71 N | tips at once | 0.0 cm | n/a |
| nominal | 2 kg | tips (33 N before) | tips at once | tips at once | -1.0 cm | 2.2 cm |
| nominal | 5 kg | tips (64 N before) | tips at once | tips at once | -0.6 cm | 3.6 cm |
| nominal | 10 kg | tips at once | tips at once | tips at once | 0.3 cm | 5.2 cm |
| nominal | 15 kg | tips (127 N before) | tips at once | tips at once | 1.0 cm | 7.0 cm |
| train_high | 2 kg | slides 14 N | tips at once | tips at once | -1.6 cm | 1.8 cm |
| train_high | 5 kg | slides 47 N | tips at once | tips at once | -1.4 cm | 2.1 cm |
| train_high | 10 kg | slides 140 N | tips at once | tips at once | -1.2 cm | 1.7 cm |
| train_high | 15 kg | tips (208 N before) | tips at once | tips at once | -1.1 cm | 2.8 cm |
| heavy_grippy | 5 kg | slides 48 N | tips at once | tips at once | -1.3 cm | 2.1 cm |
| heavy_grippy | 15 kg | tips (213 N before) | tips at once | tips at once | -1.0 cm | 2.1 cm |
| beach_sand | 5 kg | tips (81 N before) | tips at once | tips at once | -1.3 cm | 2.6 cm |
| beach_sand | 15 kg | tips (187 N before) | tips at once | tips at once | -0.6 cm | 3.2 cm |
| sand | 5 kg | tips (71 N before) | tips at once | tips at once | -0.6 cm | 2.8 cm |
| sand | 15 kg | tips (149 N before) | tips at once | tips at once | 0.5 cm | 4.7 cm |
| heavy_slippery | 5 kg | tips (78 N before) | tips at once | tips at once | -0.6 cm | 1.7 cm |
| heavy_slippery | 15 kg | tips (166 N before) | tips at once | tips at once | 0.4 cm | 3.4 cm |
| train_low | 2 kg | tips at once | tips at once | tips at once | -0.4 cm | 2.7 cm |
| train_low | 5 kg | tips (56 N before) | tips at once | tips at once | 0.6 cm | 4.0 cm |
| train_low | 10 kg | tips at once | tips at once | tips at once | 2.5 cm | 5.7 cm |
| train_low | 15 kg | tips at once | tips at once | tips at once | 4.0 cm | 6.6 cm |

### Sphere, radius 0.15 m

Rolls on every sand without leaving its line. Pushed at 0.20 m on nominal sand: 3 N at 2 kg, 11 N at 5 kg, 26 N at 10 kg, 43 N at 15 kg. It sinks 2 to 7 cm on nominal sand, which is where the rolling resistance comes from; on rigid ground it needs about 0 N.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.30 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 5 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 10 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 15 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| nominal | 2 kg | rolls 13 N | rolls 3 N | rolls 2 N | 2.0 cm | 2.2 cm |
| nominal | 5 kg | rolls 45 N | rolls 11 N | rolls 7 N | 3.4 cm | 4.1 cm |
| nominal | 10 kg | rolls 89 N | rolls 26 N | rolls 18 N | 5.4 cm | 5.8 cm |
| nominal | 15 kg | rolls 128 N | rolls 43 N | rolls 30 N | 7.1 cm | 7.6 cm |
| train_high | 2 kg | rolls 8 N | rolls 2 N | rolls 1 N | -0.0 cm | 1.9 cm |
| train_high | 5 kg | rolls 23 N | rolls 7 N | rolls 5 N | 0.6 cm | 2.1 cm |
| train_high | 10 kg | rolls 64 N | rolls 16 N | rolls 11 N | 1.4 cm | 2.2 cm |
| train_high | 15 kg | rolls 112 N | rolls 28 N | rolls 19 N | 2.2 cm | 2.5 cm |
| heavy_grippy | 5 kg | rolls 24 N | rolls 7 N | rolls 5 N | 0.6 cm | 2.0 cm |
| heavy_grippy | 15 kg | rolls 112 N | rolls 29 N | rolls 20 N | 2.2 cm | 2.5 cm |
| beach_sand | 5 kg | rolls 32 N | rolls 9 N | rolls 6 N | 1.7 cm | 2.2 cm |
| beach_sand | 15 kg | rolls 131 N | rolls 33 N | rolls 22 N | 3.5 cm | 3.8 cm |
| sand | 5 kg | rolls 44 N | rolls 10 N | rolls 7 N | 2.7 cm | 3.0 cm |
| sand | 15 kg | rolls 128 N | rolls 41 N | rolls 28 N | 6.1 cm | 4.9 cm |
| heavy_slippery | 5 kg | rolls 43 N | rolls 10 N | rolls 6 N | 2.2 cm | 2.1 cm |
| heavy_slippery | 15 kg | rolls 126 N | rolls 39 N | rolls 27 N | 5.4 cm | 3.8 cm |
| train_low | 2 kg | rolls 16 N | rolls 4 N | rolls 3 N | 2.9 cm | 2.7 cm |
| train_low | 5 kg | rolls 41 N | rolls 13 N | rolls 9 N | 5.8 cm | 4.1 cm |
| train_low | 10 kg | rolls 74 N | rolls 29 N | rolls 21 N | 9.3 cm | 5.6 cm |
| train_low | 15 kg | rolls 103 N | rolls 45 N | rolls 32 N | 11.8 cm | 6.5 cm |

### Drum, radius 0.5 m, length 0.8 m

Rolls straight when pushed at 0.20 m or 0.70 m on every sand. At wrist height it needs 1 to 11 N from 2 to 15 kg on nominal sand, inside what the walking policy holds. Pushed 0.05 m above the sand it veers, because the push then opposes the rolling.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.70 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 5 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 10 kg | rolls 0 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| rigid | 15 kg | rolls 1 N | rolls 0 N | rolls 0 N | 0.0 cm | n/a |
| nominal | 2 kg | veers 14 N | rolls 3 N | rolls 1 N | -1.3 cm | 1.3 cm |
| nominal | 5 kg | veers 38 N | rolls 10 N | rolls 3 N | -1.1 cm | 1.5 cm |
| nominal | 10 kg | veers 83 N | rolls 25 N | rolls 7 N | -0.8 cm | 1.3 cm |
| nominal | 15 kg | veers 118 N | rolls 43 N | rolls 11 N | -0.5 cm | 1.1 cm |
| train_high | 2 kg | veers 11 N | rolls 2 N | rolls 1 N | -1.7 cm | 1.0 cm |
| train_high | 5 kg | veers 30 N | rolls 6 N | rolls 2 N | -1.6 cm | 1.0 cm |
| train_high | 10 kg | veers 63 N | rolls 13 N | rolls 4 N | -1.4 cm | 1.0 cm |
| train_high | 15 kg | veers 100 N | rolls 22 N | rolls 6 N | -1.3 cm | 1.2 cm |
| heavy_grippy | 5 kg | veers 31 N | rolls 6 N | rolls 2 N | -1.6 cm | 1.1 cm |
| heavy_grippy | 15 kg | veers 101 N | rolls 22 N | rolls 6 N | -1.3 cm | 1.3 cm |
| beach_sand | 5 kg | veers 32 N | rolls 6 N | rolls 2 N | -1.5 cm | 1.0 cm |
| beach_sand | 15 kg | veers 106 N | rolls 26 N | rolls 8 N | -1.2 cm | 1.4 cm |
| sand | 5 kg | veers 37 N | rolls 9 N | rolls 3 N | -1.2 cm | 1.1 cm |
| sand | 15 kg | veers 92 N | rolls 37 N | rolls 10 N | -0.6 cm | 1.0 cm |
| heavy_slippery | 5 kg | veers 34 N | rolls 7 N | rolls 2 N | -1.1 cm | 0.9 cm |
| heavy_slippery | 15 kg | veers 148 N | rolls 33 N | rolls 8 N | -0.3 cm | 0.3 cm |
| train_low | 2 kg | veers 14 N | rolls 4 N | rolls 1 N | -0.8 cm | 1.1 cm |
| train_low | 5 kg | veers 70 N | rolls 12 N | rolls 3 N | -0.4 cm | 0.5 cm |
| train_low | 10 kg | veers 67 N | rolls 38 N | rolls 8 N | 0.2 cm | 1.6 cm |
| train_low | 15 kg | veers 111 N | rolls 76 N | rolls 14 N | 1.0 cm | 1.6 cm |

### Chair, SANDSBERG model with 0.04 m disc feet

Tips at 0.20 m and 0.70 m on every sand and every mass. Slides at 0.05 m only on the high-friction sands up to 10 kg. On rigid ground it slides at shin height and tips at wrist height.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.70 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | slides 9 N | slides 9 N | tips at once | 0.0 cm | n/a |
| rigid | 5 kg | slides 24 N | slides 24 N | tips at once | 0.0 cm | n/a |
| rigid | 10 kg | slides 48 N | slides 47 N | tips at once | 0.0 cm | n/a |
| rigid | 15 kg | slides 73 N | slides 70 N | tips at once | 0.0 cm | n/a |
| nominal | 2 kg | tips (43 N before) | tips (7 N before) | tips at once | 0.0 cm | 2.0 cm |
| nominal | 5 kg | tips (93 N before) | tips (20 N before) | tips at once | 1.2 cm | 3.2 cm |
| nominal | 10 kg | tips (167 N before) | tips (52 N before) | tips at once | 3.0 cm | 2.6 cm |
| nominal | 15 kg | tips (226 N before) | tips (92 N before) | tips (11 N before) | 4.7 cm | 2.9 cm |
| train_high | 2 kg | slides 14 N | tips (17 N before) | tips at once | -1.3 cm | 1.5 cm |
| train_high | 5 kg | slides 44 N | tips (28 N before) | tips at once | -1.0 cm | 1.7 cm |
| train_high | 10 kg | slides 155 N | tips (80 N before) | tips at once | -0.5 cm | 2.0 cm |
| train_high | 15 kg | tips (296 N before) | tips (128 N before) | tips at once | -0.2 cm | 2.3 cm |
| heavy_grippy | 5 kg | slides 51 N | tips (33 N before) | tips at once | -1.0 cm | 1.7 cm |
| heavy_grippy | 15 kg | tips (294 N before) | tips (130 N before) | tips at once | -0.2 cm | 2.4 cm |
| beach_sand | 5 kg | slides 87 N | tips (24 N before) | tips at once | -0.2 cm | 2.0 cm |
| beach_sand | 15 kg | tips (284 N before) | tips (120 N before) | tips at once | 1.1 cm | 2.6 cm |
| sand | 5 kg | tips (102 N before) | tips (21 N before) | tips at once | 0.8 cm | 2.4 cm |
| sand | 15 kg | tips (266 N before) | tips (99 N before) | tips at once | 3.4 cm | 2.5 cm |
| heavy_slippery | 5 kg | tips (111 N before) | tips (22 N before) | tips at once | 0.6 cm | 1.7 cm |
| heavy_slippery | 15 kg | tips (309 N before) | tips (117 N before) | tips at once | 2.8 cm | 2.4 cm |
| train_low | 2 kg | tips (39 N before) | tips (7 N before) | tips at once | 1.4 cm | 2.7 cm |
| train_low | 5 kg | tips (104 N before) | tips (19 N before) | tips at once | 3.3 cm | 3.2 cm |
| train_low | 10 kg | tips (180 N before) | tips (77 N before) | tips (8 N before) | 7.1 cm | 4.3 cm |
| train_low | 15 kg | tips (255 N before) | tips (140 N before) | tips (20 N before) | 10.2 cm | 4.6 cm |

### Box, 1.0 x 0.8 x 1.0 m (old box task)

On nominal sand it slides at 0.05 m but needs 53 N at 5 kg and 271 N at 15 kg, and tips at 0.20 m from 5 kg up. On the high end of the training ranges it slides at 0.05 m and 0.20 m at every mass (10 N at 2 kg, 31 to 40 N at 5 kg, 144 to 192 N at 15 kg). It tips at wrist height on every sand, as in the earlier probe.

| Ground | Mass | Push at 0.05 m | Push at 0.20 m | Push at 0.70 m | Sink at rest | Trench depth (low push) |
|---|---|---|---|---|---|---|
| rigid | 2 kg | slides 10 N | slides 10 N | slides 10 N | 0.0 cm | n/a |
| rigid | 5 kg | slides 24 N | slides 24 N | slides 24 N | 0.0 cm | n/a |
| rigid | 10 kg | slides 48 N | slides 49 N | slides 49 N | 0.0 cm | n/a |
| rigid | 15 kg | slides 73 N | slides 73 N | slides 74 N | 0.0 cm | n/a |
| nominal | 2 kg | slides 16 N | slides 23 N | tips (7 N before) | -2.6 cm | 1.1 cm |
| nominal | 5 kg | slides 53 N | tips (90 N before) | tips (16 N before) | -2.1 cm | 1.7 cm |
| nominal | 10 kg | slides 198 N | tips (170 N before) | tips (36 N before) | -1.9 cm | 2.8 cm |
| nominal | 15 kg | slides 271 N | tips (228 N before) | tips (60 N before) | -1.9 cm | 3.3 cm |
| train_high | 2 kg | slides 10 N | slides 9 N | tips (7 N before) | -2.6 cm | 1.1 cm |
| train_high | 5 kg | slides 31 N | slides 40 N | tips (19 N before) | -2.6 cm | 1.0 cm |
| train_high | 10 kg | slides 97 N | slides 119 N | tips (36 N before) | -2.4 cm | 1.2 cm |
| train_high | 15 kg | slides 144 N | slides 192 N | tips (64 N before) | -2.2 cm | 1.4 cm |
| train_low | 2 kg | slides 24 N | slides 26 N | tips (6 N before) | -2.8 cm | 1.3 cm |
| train_low | 5 kg | slides 146 N | tips (80 N before) | tips (17 N before) | -1.6 cm | 2.9 cm |
| train_low | 10 kg | stalls 243 N | tips (146 N before) | tips (38 N before) | -1.3 cm | 2.8 cm |
| train_low | 15 kg | stalls 285 N | tips (204 N before) | tips (65 N before) | -1.3 cm | 2.9 cm |

A negative sink at rest means the object's bottom is above the top of the highest sand particles, by up to the particle spacing.

### What the sand material changes

Sand friction is the parameter that matters: at 10 kg, friction 0.9 alone makes both boxes slide where friction 0.3 or 0.6 lets them tip or dig in. Density helps the big box (77 N at density 3000 against 186 N at density 1000, 10 kg, low push) and reduces sinkage. Stiffness and yield pressure change nothing measurable. The easiest sand tried is density 3000 kg/m3 with friction 0.9 (training high end, or the same with rigid elasticity).

One parameter at a time around (density 2000, modulus 1e8, friction 0.60, yield 3.16e8), 10 kg, push at 0.05 m:

| Variant | Small box | Big box (0.05 m) | Big box (0.20 m) | Sphere (0.20 m) |
|---|---|---|---|---|
| train_mid | tips (163 N before) | slides 95 N | tips (161 N before) | rolls 21 N |
| friction_low | tips (134 N before) | slides 195 N | tips (163 N before) | rolls 26 N |
| friction_high | slides 164 N | slides 98 N | slides 129 N | rolls 19 N |
| density_low | tips (136 N before) | slides 186 N | tips (166 N before) | rolls 25 N |
| density_high | tips (169 N before) | slides 77 N | slides 101 N | rolls 18 N |
| stiffness_low | tips (164 N before) | slides 98 N | tips (165 N before) | rolls 21 N |
| stiffness_high | tips (162 N before) | slides 95 N | tips (155 N before) | rolls 21 N |

### Pass or fail per object

Pass means: the object moves as intended (slides or rolls, no tipping) and needs no more than the force the walking policy holds at half speed (20 N on the pelvis for hands; 78 N at the shins for legs). The robot-side limits come from an untrained-for-load policy, so a fail on force alone may not be final.

| Object | Verdict | Mass and push height | Hands or legs | Why |
|---|---|---|---|---|
| Drum (r 0.5 m) | pass | 2 to 15 kg at 0.70 m (1 to 11 N), any sand | hands | rolls straight; rigid ground needs about 0 N, so sand adds the only resistance |
| Sphere (r 0.15 m) | pass | 2 to 10 kg at 0.20 m (3 to 26 N nominal; 2 to 16 N high-friction sand) | legs (0.30 m tall, below standing wrist reach) | rolls; resistance grows with sinkage |
| Big box (1.0 x 0.8 x 1.0 m) | pass only light, low, on high-friction sand | 2 kg at 0.20 m (9 N); 5 kg needs 31 to 40 N | legs | tips at wrist height on every sand; on nominal sand tips at 0.20 m from 5 kg |
| Small box (0.3 m) | fail | none at shin height | - | tips at 0.20 m on every sand and mass |
| Upright cylinder | fail | none at shin height | - | tips at 0.20 m on every sand and mass |
| Chair (disc feet) | fail | none at shin or wrist height | - | tips at 0.20 m and 0.70 m on every sand and mass; on bare legs it sinks about 2 to 4 cm more at rest (2 and 5 kg, nominal sand) |

For pushing on one fixed, easy sand: use density 3000 kg/m3 with friction 0.9, and push a rolling object (drum with the hands, or sphere with the legs). A box only works if it is long, light (about 2 kg) and pushed at shin height. Owner decisions on 2026-11-19 moved the work to towing an object by a rope on the pelvis; see outputs/T2.md.

### Limits

- One run per condition, one seed. Forces fluctuate by several newtons between runs; no repeat was made.
- The drive is a force at a fixed height, not a robot limb: no contact patch, no vertical component, no friction at the pusher.
- The traction limit is that of walking policy jqur5jhm, which never saw a sustained external force. A policy trained to push or pull would hold more; how much is not measured.
- Rigid ground uses friction 0.5 for object and ground. Sand runs use object friction 0.5; with friction 0.3 or the simulator default the 10 kg small box still tips on nominal sand.
- The trench depth is taken from particle tops on a 3 cm grid; values under about 1.5 cm are within the particle spacing.
- The sand surface settles about 8 cm below the nominal terrain height; push heights are measured from the settled surface.
- Two runs at once exhaust the 32 GB GPU; the first parallel pass lost about 45 runs, which were rerun one at a time.
- Chair and drum were taken from the old code as shapes only; the chair model has straight legs and an upright slab backrest.
- Not done: any pushing or towing training; pushing on slopes; turning; a pusher modelled as the robot's body.
- Chair on bare legs (`chair_bare`, nominal sand, 2 and 5 kg): tips at every height; sinks 2.1 cm and 4.9 cm at rest.
- Small box, 10 kg, nominal sand, other object friction: tips at the low push with friction 0.3 (121 N before) and with the simulator default (136 N before).
- Traction at a 0.6 m/s command (nominal sand, pelvis): half speed at 52 N, standstill at 61 N (median of 8).

## Towing a rolling wheelset, 2026-11-20 (Claude session)

Owner suggestion: pull a cart on very loose sand. Stand-in for a cart: a wheelset, two wheels (radius 0.15 m, width 0.05 m, 0.4 m apart) joined by an axle as one rigid body that rolls as a whole, rope tied to the middle of the axle (`contrib/push/util/generated_assets.py:wheelset_usd`, selected with `tow_check.py --object wheelset`; untracked, same dirty tree at `a60612c79`). Same tow tasks, rope, command (0.5 m/s) and walking policies as the tow check above; one 16 s run per case, means over the last 8 s. Raw data `logs/t2/tow/wheel_*.{json,npz}`. Measured in this session, unchecked. Nobody fell.

| Ground | Policy | Mass | Robot speed | Rope tension | Wheelset travel in 16 s |
|---|---|---|---|---|---|
| rigid | MPM-trained `jqur5jhm` | 10 kg | 0.50 m/s | 2 N | 8.5 m |
| rigid | MPM-trained `jqur5jhm` | 20 kg | 0.51 m/s | 1 N | 8.1 m |
| nominal sand | MPM-trained `jqur5jhm` | 2 kg | 0.50 m/s | 5 N | 7.3 m |
| nominal sand | MPM-trained `jqur5jhm` | 5 kg | 0.44 m/s | 13 N | 6.5 m |
| nominal sand | MPM-trained `jqur5jhm` | 10 kg | 0.33 m/s | 30 N | 4.5 m |
| nominal sand | MPM-trained `jqur5jhm` | 20 kg | 0.00 m/s | 55 N | 0.1 m |
| nominal sand | rigid-trained `3qymp37c` | 10 kg | 0.33 m/s | 34 N | 2.6 m |
| nominal sand | rigid-trained `3qymp37c` | 20 kg | 0.01 m/s | 36 N | 0.0 m |

- On rigid ground the wheelset is free to tow at either mass. On sand the wheels sink (the 20 kg wheelset ends about 7 cm lower than the 2 kg one) and the tension grows faster than the mass.
- On rigid ground the wheelset drifted 0.3 to 0.9 m sideways over 8 m; nothing keeps it behind the robot except the rope.
- Not run: the training-low-end sand (the run failed at start: the tile template did not settle within its time limit); a cart with a body and wheels on joints; slopes; any training.

## Tow clips and a 1.0 m/s command, 2026-11-20 (Claude session)

RTX clips of the sand tow task (`IsaacContrib-Tow-G1-29dof-MPM-Play`, nominal sand, 0.3 m cube at 10 kg, one environment, 12 s, `tow_check.py --video_dir`), same dirty tree at `a60612c79`. Originals in `~/isaac/worktrees/mpm-unification/IsaacLab/logs/t2/tow/video/`, copies in `site/T2/media/`. The rope is not drawn. One run each, measured in this session, unchecked; one late frame of each clip was inspected, not the whole clip.

| Command | Policy | Robot speed, last 6 s | Rope tension, last 6 s | Box travel in 12 s | Clip |
|---|---|---|---|---|---|
| 0.5 m/s | MPM-trained `jqur5jhm` | 0.02 m/s | 52 N | 0.3 m | `tow_box_sand_10kg_mpm_policy.mp4` |
| 0.5 m/s | rigid-trained `3qymp37c` | 0.01 m/s | 58 N | 0.7 m | `tow_box_sand_10kg_mjwarp_policy.mp4` |
| 1.0 m/s | MPM-trained `jqur5jhm` | 0.02 m/s | 25 N | 0.3 m | `tow_box_sand_10kg_1.0mps_mpm_policy.mp4` |
| 1.0 m/s | rigid-trained `3qymp37c` | 0.50 m/s | 77 N | 5.8 m | `tow_box_sand_10kg_1.0mps_mjwarp_policy.mp4` |

At a 1.0 m/s command the rigid-trained walking policy tows the 10 kg box at 0.5 m/s on sand and the MPM-trained one stays stalled. Neither fell. Also recorded: `tow_wheelset_sand_10kg.mp4` (wheelset, MPM-trained policy, 0.5 m/s command). A rigid-ground clip was started and had not finished rendering.

15 kg cube, 1.0 m/s command, same setup and tree (2026-11-20, one run each, numbers only; clips `tow_box_sand_15kg_1.0mps_mpm_policy.mp4` and `tow_box_sand_15kg_1.0mps_mjwarp_policy.mp4`, frames not inspected):

| Policy | Robot speed, last 6 s | Rope tension, last 6 s | Peak tension | Box travel in 12 s |
|---|---|---|---|---|
| MPM-trained `jqur5jhm` | 0.01 m/s | 26 N | 100 N | 0.1 m |
| rigid-trained `3qymp37c` | 0.00 m/s | 78 N | 129 N | 0.5 m |

Both stall; neither fell. The rigid-trained policy holds about 78 N of tension at both 10 and 15 kg, which moves the 10 kg cube and not the 15 kg one.

## Tow training jobs and the rigid-trained tow policy, 2026-11-20 (Claude session)

Jobs (unified worktree `~/isaac/worktrees/mpm-unification/IsaacLab`, dirty tree, bundle built by `scripts/benchmarks/t3/osmo_bundle.sh`, workflow by `scripts/benchmarks/t2/osmo_train.py`, pool `isaac-lab-l40-07`):

- `g1-tow-rigid-1`: `IsaacContrib-Tow-G1-29dof-Rigid`, 4 GPUs x 1,024 envs, from walking policy `3qymp37c`. Running.
- `g1-tow-mpm-1`: `IsaacContrib-Tow-G1-29dof-MPM`, 40 GPUs x 32 envs, from `jqur5jhm`, streaming MPM with tile cache, default preset `solver_cfg_all_active_cache` (no sleeping). Failed at the first reset: `Shared terrain height query missed the surface`. Cause: 32 envs on the 4 m clone grid span the whole 20 m plane, and the randomized reset put edge robots off it.
- Fix in the tow package only: `tow_env_cfg.py` always sets `use_terrain_origins = True`; `env_cfg/terrain_generator_cfg.py` flat plane 20 m -> 50 m. Local 2-iteration test trains at 4 and 8 envs; peak GPU memory unchanged by the fix (11.8 GB at 4 envs, 19.8 GB at 8, out of memory at 16 on the 32 GB card), so about 2 GB per env and 32 envs would not fit a 48 GB L40. Resubmitted with 16 envs per GPU (640 total).
- `g1-tow-mpm-2`: trainers passed environment setup; trainer-5 crashed with `Warp CUDA error 700: illegal memory access` in `solver_implicit_mpm._allocate_grid` during solver construction; the rest waited. Cancelled. Not reproduced locally with that rank's seed (47). Same error class as `isaac-lab-g1-mpm-push-chair-2`. Root cause unknown.
- `g1-tow-mpm-3`: same spec, training (iteration 20003/39999 seen in the trainer log). `g1-tow-mpm-4` was a duplicate from a submit that reported a connection error; cancelled.

Rigid-trained tow policy, checkpoint `model_37000.pt` of `g1-tow-rigid-1` (`logs/t2/tow/ckpt_rigid_tow/`), `tow_check.py`, 0.3 m cube, one environment, 12 s, one run each, measured in this session. Contact sheets of the clips were inspected, not full playback. Clips in `site/T2/media/tow_trained_*`; rigid clips use the GL viewer (the RTX render of the rigid task hung before step 0), the rope is not drawn, the camera is fixed.

| Ground | Mass | Command | Robot travel in 10 s | Cube travel in 10 s | Rope tension | Outcome |
|---|---|---|---|---|---|---|
| rigid | 10 kg | 0.5 m/s | 4.8 m | 3.9 m after the rope went taut | 31-47 N | survived |
| rigid | 10 kg | 1.0 m/s | 9.5 m | 7.8 m | 37-68 N | survived |
| rigid | 15 kg | 0.5 m/s | 4.4 m | 4.2 m | 51-79 N | survived |
| rigid | 15 kg | 1.0 m/s | 8.8 m | 8.7 m | 69-88 N | survived |
| sand (nominal) | 15 kg | 0.5 m/s | 0.8 m | 0.5 m | up to 119 N | fell (`bad_orientation`) |
| sand (nominal) | 15 kg | 1.0 m/s | 0.5 m, then fell and reset | 0.1 m | up to 145 N | fell (`bad_orientation`) |

## Mixed rigid/sand tow task, 2026-11-20 (Claude session)

Owner request: train the tow task on mixed rigid/MPM terrain as the walking task does (`velocity_mpm/config/g1_29dof`, `streaming_mpm_mixed_env*`), collider margin 2 cm on MPM and 0 on MJWarp.

New, untracked, in `contrib/push/config/g1_29dof_mpm_tow/` (unified worktree, dirty tree): `tow_mixed_env_cfg.py`, `tow_mixed_env.py`, registration `IsaacContrib-Tow-G1-29dof-MPM-Mixed` (`-Play`, 2 envs).

- Flat terrain with two 50 m columns; `MixedMPMTerrainImporter` from the walking task makes the even column rigid and the odd one sand. Environments are split half and half by the terrain-origin assignment.
- `G1TowMixedEnv(G1TowEnv, G1MPMMixedEnv)`: foot margins per column as in the walking task, and the same for the sled shape (rigid 0, sand 0.02 m).
- Terrain friction set to the sled's 0.5 (max rule), as in the rigid tow task; spawn height +0.05 m as in the mixed walking task.
- Streaming MPM with tile cache, default preset `solver_cfg_all_active_cache` (no sleeping), unchanged.
- Local checks, measured in this session: 3 training iterations at 4 envs run; 2-env check with the rigid-trained tow policy (`model_37000.pt`, 0.5 m/s, 10 s): env 0 rigid, margins 0, robot 4.8 m and cube 3.5 m forward; env 1 sand, margins 0.02 m, robot falls and resets. No video.

Job: `g1-tow-mpm-mixed-1`, 40 GPUs x 16 envs (8 rigid + 8 sand each), from walking policy `jqur5jhm`, run name `tow_mixed_box10kg_from_jqur5jhm`, W&B project `g1_29dof_mpm_tow`. `g1-tow-mpm-3` (sand only) cancelled when this was submitted.

### Mixed tow job at 32 envs per GPU, 2026-11-20 (Claude session)

Peak GPU memory, local RTX 5090, 2 training iterations each, measured in this session (includes about 1.3 GB of desktop use):

| Task, setting | 4 envs | 8 envs | 16 envs |
|---|---|---|---|
| Tow (sand only), voxel 0.03 m, capacity multiplier 4.0, cache 1.5M | 11.8 GB | 19.8 GB | out of memory |
| Tow mixed, voxel 0.03 m | - | 18.9 GB | - |
| Tow mixed, sleeping preset `solver_cfg_cache` | - | 21.2 GB | - |
| Tow mixed, capacity multiplier 2.0 | - | 13.3 GB | - |
| Tow mixed, cache 500k | - | 17.4 GB | - |
| Tow mixed, voxel 0.04 m | - | 12.6 GB | 22.5 GB |
| Walking `IsaacContrib-Velocity-G1-29dof-MPM`, all-active cache | 8.8 GB | 14.2 GB | - |
| Walking mixed `...-MPM-Mixed` (voxel 0.04 m) | - | 11.9 GB | - |

- The tow task has the walking task's pool size (1.2 m) but two pools (pelvis and sled), so its capacity multiplier is 4.0 against 2.0; about 2.0 GB per env against 1.35 GB for walking at voxel 0.03 m.
- A capacity multiplier of 2.0 leaves no spare slots for two disjoint pools (exhaustion raises), so it was not used. Shortening the rope from 1.2 m to 0.6 m would make the pools overlap by about 15% only; not changed.
- Change: `tow_mixed_env_cfg.py` sets voxel 0.04 m (`MIXED_VOXEL_SIZE`), the mixed walking task's value. About 1.23 GB per env, estimated 41 GB at 32 envs on a 46 GB L40.
- `g1-tow-mpm-mixed-1` (16 envs, voxel 0.03 m) reached iteration 20006 and was cancelled; `g1-tow-mpm-mixed-2`: 40 GPUs x 32 envs (1,280), voxel 0.04 m, otherwise the same, run name `tow_mixed_box10kg_32env_from_jqur5jhm`.

### Pure-sand and mixed tow jobs, 15 kg, with training video, 2026-11-20 14:32 PST (Claude session)

Owner requests: 4 cm voxel for both tow variants; run both; record video during training with the viewer following the robot; same reward in both; camera closer (x=3, y=3); train with 15 kg.

Changes in `contrib/push/config/g1_29dof_mpm_tow/` (untracked, unified worktree):

- `env_cfg/scene_cfg.py`: `VOXEL_SIZE` 0.03 -> 0.04 (both variants; the mixed override was removed), `SLED_MASS` 10 -> 15 kg.
- `tow_env_cfg.py`: training viewer eye (5, 5, 2) -> (3, 3, 2); it already used `follow_robot=True`.
- `tow_mixed_env_cfg.py`: added `rigid_contact_gap = 0.01`, a field the mixed walking env (`streaming_mpm_mixed_env.py`, changed by another session today) now reads.
- Rewards: the mixed config inherits the sand config's reward terms; the printed reward tables of both tasks are identical (26 lines, local run).
- Video: jobs pass `--viz newton_gl --video --video_length 200`. Local 8-iteration runs wrote `videos/train/clip_0000.mp4`; one contact sheet inspected: camera follows the robot, rope drawn. Environments that share a terrain column start at the same point, so several robots overlap in the picture.

Jobs, 40 GPUs x 32 envs each, from walking policy `jqur5jhm`, W&B project `g1_29dof_mpm_tow`:

- `g1-tow-mpm-6`: `IsaacContrib-Tow-G1-29dof-MPM`, run name `tow_sand_box15kg_32env_from_jqur5jhm`.
- `g1-tow-mpm-mixed-4`: `IsaacContrib-Tow-G1-29dof-MPM-Mixed`, run name `tow_mixed_box15kg_32env_from_jqur5jhm`.

Cancelled before these: `g1-tow-mpm-mixed-2` (10 kg, no video; W&B `jtv18uv3`), `g1-tow-mpm-5` and `g1-tow-mpm-mixed-3` (10 kg, old camera, cancelled minutes after submission). Earlier W&B runs in the project: `2vtg28jd` = `g1-tow-mpm-3`, `zz8nyi35` = `g1-tow-mpm-mixed-1`.

The rigid tow job `g1-tow-rigid-1` still trains with a 10 kg cube.

### Rigid tow retrained with 15 kg and training video, 2026-11-20 14:50 PST (Claude session)

- `contrib/push/config/g1_29dof_rigid_tow/env_cfg/scene_cfg.py`: `SLED_MASS` 10 -> 15 kg.
- `tow_env.py` / `tow_env_cfg.py`: new `camera_follow_eye = (3, 3, 2)`; the viewer is moved to that offset from the first robot's root every step. The fixed view showed empty ground (local clip, contact sheet inspected before and after).
- Job `g1-tow-rigid-2`: `IsaacContrib-Tow-G1-29dof-Rigid`, 4 GPUs x 1,024 envs, from `3qymp37c`, run name `tow_box15kg_from_3qymp37c`, `--viz newton_gl --video --video_length 200`. `g1-tow-rigid-1` (10 kg) was not touched.

### Tow fine-tuning after 500 iterations: which ground has learned, 2026-11-20 (Claude session)

Checkpoints `model_20500.pt` (500 iterations after the warm start) of `g1-tow-mpm-mixed-4` (W&B `05pdyxnu`) and `g1-tow-mpm-6` (W&B `lsti6ht9`), 15 kg cube, `tow_check.py`, one environment, 12 s, one run each, measured in this session. The MPM tow tasks train with the compositional runner, whose actor keys carry a `terms.actor.` prefix; `tow_check.py` reads the plain layout, so the actor was re-saved without the prefix (`model_20500_flat.pt`). `model_20000.pt` of the mixed run differs from `jqur5jhm` by at most 0.012 per weight, so the warm start was loaded. Clips not inspected.

| Checkpoint | Ground | Command | Robot travel in 10 s | Cube travel in 10 s | Outcome |
|---|---|---|---|---|---|
| mixed | sand | 0.5 m/s | 0.57 m | 0.30 m | no fall |
| mixed | sand | 1.0 m/s | 0.85 m | 0.59 m | no fall |
| mixed | rigid | 1.0 m/s | 10.5 m | 9.5 m | no fall |
| pure sand | sand | 0.5 m/s | 0.34 m | 0.15 m | no fall |
| pure sand | sand | 1.0 m/s | 0.11 m | 0.01 m | no fall |

The training video of the mixed run follows environment 0, which is in the rigid column (terrain types are assigned in index order; local check `mpm_env_mask = [False, True]`). Sand particles are also present and drawn in the rigid column.

### Sand tow training stopped; mixed tow on hold, 2026-11-20 17:30 PST (Claude session)

Owner decision: cancel both sand tow jobs; the ground level looks wrong and the policy swings its feet too high; wait until the mixed-terrain locomotion environment is finalized before implementing mixed tow. `g1-tow-mpm-6` and `g1-tow-mpm-mixed-4` cancelled. `g1-tow-rigid-2` (15 kg, rigid) keeps running.

Found before the stop, measured in this session:

- The mixed terrain importer copied this morning put the sand layer at the same height as the rigid surface in the rigid column, so rigid-column feet and cube touched sand. `g1-tow-mpm-mixed-1` to `-4` all trained with that layout.
- The walking task's importer was rewritten by another session today (sand column raised by the sand depth; unused sand one depth below the rigid column; `MixedMPMTerrainImporterCfg`, `root_left_column` time-out). It raises vertices, and a flat tile has vertices only on its border, shared with the next column: with the tow task's two flat tiles both columns came out tilted (env origins at z 0.125 m, cube below the rigid ground level).
- Uncommitted work in progress in `g1_29dof_mpm_tow/tow_mixed_env_cfg.py`: uses the new importer config, adds `TowMixedTerrainImporter` that raises whole triangles, and the column time-out. Two-env check with the rigid tow policy (10 s, 0.5 m/s, 15 kg): rigid env origin z 0, feet at sole height 0.035 m, cube centre at 0.15 m, cube towed 4.1 m; sand env origin z 0.25 m, robot stalls. Not trained, not reviewed against the final locomotion environment.
- Not investigated: the high foot swing the owner sees.

### Mixed tow terrain aligned with the fixed mixed walking task, 2026-11-20 18:15 PST (Claude session)

Owner request: fix the tow task's mixed terrain using the walking task's fixes (no particles on the rigid patch, no crossing between sand and rigid), changing only `g1_29dof_mpm_tow/tow_mixed_env_cfg.py` and `tow_mixed_env.py`. Only `tow_mixed_env_cfg.py` was changed (untracked, unified worktree); `tow_mixed_env.py` needed nothing.

- Terrain config is now the walking task's `MixedMPMTerrainImporterCfg` (`sand_env_fraction` 0.5; the first environments are the sand ones and are placed on the sand column).
- `validate_config` mirrors the walking task: sand asset class `MixedMPMObject`, clone plan with sand only in sand environments, sparse MPM storage scaled to the sand environments.
- Termination `out_of_patch` (`mpm_mdp.root_out_of_patch`, margin 0.5 m, time-out).
- `TowMixedTerrainImporter` kept: the walking importer raises sand columns per vertex, which tilts two-triangle flat tiles; this one raises whole triangles.
- Local checks, measured in this session. Two-env check, rigid tow policy `model_37000.pt`, 15 kg, 0.5 m/s, 10 s: env 0 sand (walking surface z 0.25 m, margins 0.02 m, particles only in this world: 100,352), robot stalls, feet 6 to 12 cm below the nominal sand top; env 1 rigid (surface z 0, margins 0, no particles), feet at sole height 0.035 m, cube centre 0.15 m, cube towed 4.2 m. Training test, 8 envs, 10 iterations with video: runs, peak GPU memory 9.9 GB (12.6 GB before, when every environment held sand), reward table identical to the pure-sand task; contact sheet of the clip shows the camera on sand robots.
- No job submitted; sand tow training stays on hold.

### Mixed tow job from the mixed walking policy, 2026-11-20 18:29 PST (Claude session)

Owner request: train `IsaacContrib-Tow-G1-29dof-MPM-Mixed` with the setup of the cancelled job, warm-started from `eayrj79r` (W&B project `g1_29dof_mpm_mixed_terrain`, `model_19999.pt`, same network layout as the tow task).

`g1-tow-mpm-mixed-5`: 40 GPUs x 32 envs, 15 kg cube, voxel 0.04 m, fixed sand, the fixed mixed terrain of the entry above, `--viz newton_gl --video --video_length 200`, run name `tow_mixed_box15kg_32env_from_eayrj79r`. Local 6-iteration test with this checkpoint at 8 envs ran.

### Soft-contact (RFT) tow task and job, 2026-11-20 18:39 PST (Claude session)

Owner request: a tow task on the analytical soft-contact model, defined like the soft-contact walking task, same terrain setup as mixed MPM (half rigid, half RFT), rigid ground under the RFT half lowered so it is never reached, pretrained from `6t0h2ud8` (`g1_29dof_contact_benchmark`, rough RFT walking, `model_19999.pt`), 4 GPUs x 1,024 envs.

New, untracked (unified worktree): `contrib/push/config/g1_29dof_soft_contact_tow/`, task `IsaacContrib-Tow-G1-29dof-SoftContact` (`-Play`, 2 envs). Copied from `g1_29dof_rigid_tow` (itself the soft-contact flat walking task with the RFT force off), then:

- `env_cfg/action_cfg.py`: RFT on for the feet (`physics_callback`, as in walking); second RFT term `sled_physics_callback` on the cube (box collider of the cube's size); `tether_hold` term that re-adds the rope force.
- `env_cfg/scene_cfg.py`: two 50 m flat columns; first rigid at z 0, second with the rigid plane at z -0.5 m (`SUPPORT_DEPTH`). The RFT surface is world z 0 in both. First half of the environments on rigid, second half on RFT. Cube 15 kg, ground friction 0.5.
- `mdp/events.py`: `reset_object_behind_robot_on_ground` puts the cube at rest height above z 0 (the shared reset would place it on the lowered plane).
- `env_cfg/event_cfg.py`: RFT material randomization removed (one fixed material, default `Material3DRFTCfg`, for feet and cube); reset positions spread over +-5 m so robots do not overlap in the video.
- `env_cfg/termination_cfg.py`: `out_of_patch` time-out (margin 0.5 m).
- `tow_env.py`: viewer follows the last environment (RFT half).
- `contrib/push/util/tether.py`: new `Tether.reapply()`.

Bug found and fixed while testing: each RFT term sets its asset's permanent wrench once per physics step, and `set_forces_and_torques_index` clears the environment's whole buffer, so the rope force set at the start of the step was erased (cube did not move, tension pinned at 300 N). `tether_hold` runs after the RFT terms and adds the held rope force back.

Local checks, measured in this session. Two-env check with `6t0h2ud8` (no tow training), 0.5 m/s, 10 s: rigid env robot 0.96 m, cube 0.80 m, tension about 65 N; RFT env robot 0.48 m, cube 0.29 m, tension 36 to 61 N, lowest foot-link origin z -0.082 m (sole about 0.12 m below the surface), lowest cube centre z 0.127 m (2.3 cm sunk); rigid plane at -0.5 m not reached. Training test, 64 envs, 10 iterations with video: runs; reward table has the same 24 terms as the rigid tow task; contact sheet of the clip shows separate robots on the RFT half. The drawn ground under the RFT half is the lowered plane, so robots appear above their shadows.

Job `g1-tow-soft-contact-1`: 4 GPUs x 1,024 envs, `--viz newton_gl --video --video_length 200`, run name `tow_mixed_box15kg_from_6t0h2ud8`, W&B project `g1_29dof_soft_contact_tow`.

### Mixed MPM tow run after 6,500 iterations: rigid tows, sand does not, 2026-11-21 (Claude session)

`g1-tow-mpm-mixed-5` (W&B `bjgp31tu`), `model_26500.pt` (6,500 iterations after `eayrj79r`), 15 kg cube, `tow_check.py`, one environment, 12 s, one run each, measured in this session. Sand runs use the pure-sand play task (voxel 0.04 m), rigid runs the rigid play task. Clips `site/T2/media/tow_mixed5_26500_*`; one contact sheet each of the 1.0 m/s sand and rigid clips inspected.

| Ground | Command | Robot travel in 10 s | Cube travel in 10 s | Rope tension at the 2 s samples | Outcome |
|---|---|---|---|---|---|
| sand | 0.5 m/s | 0.27 m | 0.07 m | 0 to 101 N | no fall |
| sand | 1.0 m/s | 0.41 m | 0.06 m | 0 to 102 N | no fall |
| rigid | 0.5 m/s | 4.8 m | 3.9 m | 57 to 77 N | no fall |
| rigid | 1.0 m/s | 9.3 m | 7.7 m | 41 to 81 N | no fall |

Training metrics at step 26,611 (both halves averaged): cube speed 0.16 m/s, tension 40 N, velocity error 0.14 m/s, 97% time-outs.

### Tow videos reorganized, 2026-11-21 (Claude session)

All tow clips moved from `site/T2/media/tow_*.mp4` to `site/T2/media/tow/<policy folder>/<test file>.mp4`; the mapping and naming rule are in `site/T2/media/tow/README.md`. Folder = policy type (walking or tow), training ground, run or job, checkpoint; file = test ground, object and mass, commanded speed. Earlier entries in this file name the old paths. No page referenced these clips.

### Sand cube-mass curriculum and forward-lean allowance, mixed MPM tow relaunched, 2026-11-21 11:52 PST (Claude session)

Owner: add the cube-mass curriculum on the sand half and relaunch; the policy should probably lean forward rather than tow at constant orientation.

Changes in `contrib/push/config/g1_29dof_mpm_tow/` (untracked, unified worktree), shared by the pure-sand and mixed tasks:

- `mdp/curriculums.py: sled_mass_levels`, term `sled_mass` in `env_cfg/curriculum_cfg.py`: every sand environment has its own cube mass, 5 kg at the start, range 5 to 15 kg, step 1 kg per episode; up when the cube's path is above 0.6 of the commanded path, down below 0.3, not judged when the commanded path is under 2 m. Rigid environments stay at 15 kg. Logged as `Curriculum/sled_mass/mean` and `/max`.
- `tow_env.py`: per-episode `sled_path` and `commanded_path`; tow metrics also logged per ground on mixed terrain (`Metrics/tow/sled_speed_sand`, `_rigid`, `tension_sand`, `_rigid`).
- `mdp/rewards.py: lean_orientation_l2`, used for `flat_orientation_l2` (weight -10 unchanged): forward pitch up to 20 degrees is free; roll, backward lean and lean beyond 20 degrees are penalized as before. The rigid tow and soft-contact tow tasks still use the plain flat-orientation penalty.

Local checks, measured in this session. Two-env check with `eayrj79r` (no tow training), 0.5 m/s, 6 s per phase: sand env at 5 kg cube travels 1.86 m (0.63 of the commanded path), set to 15 kg at runtime 0.11 m, back to 5 kg 2.08 m; rigid env (15 kg) about 1.5 m each phase. Mean pelvis pitch of that policy is -0.4 to +0.8 degrees on sand and -3.4 to -4.1 degrees (backward) on rigid at 72 to 81 N. Training test, mixed task, 8 envs, 50 iterations: runs; sand mass mean 5.5 kg, max 6 kg; per-ground metrics logged. Pure-sand task, 4 envs, 3 iterations: runs.

Job `g1-tow-mpm-mixed-6`: 40 GPUs x 32 envs, from `eayrj79r`, video on, run name `tow_mixed_sandmass5to15kg_lean20deg_32env_from_eayrj79r`. `g1-tow-mpm-mixed-5` cancelled at about iteration 26,600.

### Mixed MPM tow with mass curriculum and lean allowance: 15 kg towed on sand after 1,000 iterations, 2026-11-21 (Claude session)

`g1-tow-mpm-mixed-6` (W&B `her588wk`), `model_21000.pt` (1,000 iterations after `eayrj79r`), 15 kg cube, `tow_check.py` (curriculum term disabled in the script so the set mass stays), one environment, 12 s, one run each, measured in this session. Clips in `site/T2/media/tow/tow-policy_trained-on-mixed-rigid-mpm_sand-mass-curriculum-5to15kg_g1-tow-mpm-mixed-6_iter21000/`; contact sheets of both sand clips inspected (robot leans forward, cube leaves a trench behind it).

| Ground | Command | Robot travel in 10 s | Cube travel in 10 s | Rope tension at the 2 s samples | Outcome |
|---|---|---|---|---|---|
| MPM sand | 0.5 m/s | 4.4 m | 3.9 m | 75 to 109 N | no fall |
| MPM sand | 1.0 m/s | 7.9 m | 6.6 m | 69 to 132 N | no fall |
| rigid | 0.5 m/s | 4.6 m | 3.8 m | 56 to 77 N | no fall |
| rigid | 1.0 m/s | 9.2 m | 8.2 m | 57 to 75 N | no fall |

Training metrics at step 21,338: sand cube mass mean 14.3 kg (max 15), cube speed 0.34 m/s on sand and 0.38 m/s on rigid. The mass curriculum and the lean allowance were introduced together; their separate effects are not measured. Not evaluated: several trials or seeds, turning, other masses.

### Changing speed command during the tow, 2026-11-21 (Claude session)

`tow_check.py` gained `--speed_schedule` (comma-separated forward commands held for equal parts of the run). Same checkpoint as above (`g1-tow-mpm-mixed-6`, `model_21000.pt`), 15 kg cube, schedule 0.5, 1.0, 0.5, 0.0 m/s, 5 s each, one environment, one run each, measured in this session. Clips `test-on-*_cube15kg_cmd0.5-1.0-0.5-0.0mps_5s-each.mp4` in the same policy folder; contact sheet of the sand clip inspected.

| Ground | Command | Robot mean speed | Speed in the second half of the segment | Cube travel | Mean tension |
|---|---|---|---|---|---|
| MPM sand | 0.5 m/s | 0.36 m/s | 0.43 m/s | 1.49 m | 80 N |
| MPM sand | 1.0 m/s | 0.67 m/s | 0.72 m/s | 3.38 m | 125 N |
| MPM sand | 0.5 m/s | 0.49 m/s | 0.48 m/s | 2.45 m | 108 N |
| MPM sand | 0.0 m/s | 0.02 m/s | 0.01 m/s | 0.23 m | 23 N |
| rigid | 0.5 m/s | 0.44 m/s | 0.48 m/s | 2.03 m | 61 N |
| rigid | 1.0 m/s | 0.94 m/s | 0.96 m/s | 4.69 m | 67 N |
| rigid | 0.5 m/s | 0.48 m/s | 0.48 m/s | 2.44 m | 64 N |
| rigid | 0.0 m/s | 0.01 m/s | 0.00 m/s | 0.12 m | 21 N |

No fall in either run. The first segment includes the rope going taut from slack.
