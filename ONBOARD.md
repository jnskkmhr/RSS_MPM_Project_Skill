# Onboarding

Shared context for the RSS MPM project. Humans and agents read this first. Keep it short and stable; anything that changes weekly goes in `tasks/`, `DECISIONS.md`, or `LESSON.md`.

## Project

**Working title:** Learning Robot Control Policy on Particle Systems.

**Claim:** robot policies can be trained directly on particle (MPM) simulation of granular terrain, at a scale that was previously impractical, and this transfers to hardware better than rigid or reduced-order terrain models.

**Contributions:**
1. Moving terrain patch MPM: simulate only the material around the robot and its objects (particle recycling), with a particle cache that restores deformed terrain on revisits.
2. Policy learning on MPM across embodiments and tasks: Franka particle pushing, Unitree G1 velocity tracking, Unitree G1 box pushing.
3. Hardware deployment on physical granular terrain.
4. Bonus: Particle NeRD, a neural surrogate for the MPM material update (Transolver particle prediction + analytical body-wrench reconstruction), trained on one terrain type.

**Venue:** RSS 2027. Deadline: TODO. Page target: TODO (the paper draft currently assumes five pages of main text; confirm against the call).

**People:** lead: TODO. Writers of this file: lead and Junnosuke.

## Repos

| Repo | Remote / branch | Local path (Junnosuke's machine) | Holds |
|---|---|---|---|
| Context (this repo) | TODO | `~/RSS_27/RSS_MPM_Project_Skill` | Onboarding, tasks, outputs, checks |
| Paper | `jnskkmhr/RSS_Humanoid_MPM`, `main` | `~/RSS_27/RSS_Humanoid_MPM` | LaTeX; edit `sections/*.tex`, build with `latexmk paper.tex` |
| IsaacLab (MPM tasks) | `jnskkmhr/IsaacLab`, `junnosuke/mpm_rl_task` | `~/isaac/IsaacLab` | Moving-patch MPM, G1 / box-push / UR10 tasks, RFT soft contact, baselines |
| IsaacLab (Particle NeRD) | `jnskkmhr/IsaacLab`, `junnosuke/particle_nerd` | `~/isaac/IsaacLab-particle-nerd` | Particle NeRD model, data collection, NeRD-backed G1 tasks |
| Deployment | `jnskkmhr/isaac_ros_deploy`, `main` | `~/workspace/isaac_ros_deploy` | Standalone G1 ROS deployment: policy bundles, MuJoCo sim-to-sim, hardware launch, safety blending |

Both IsaacLab checkouts have their own `CLAUDE.md` / `AGENTS.md` and `skills/`; follow those for code conventions. Both had uncommitted changes on 2026-11-15, so check `git status` before assuming the branch tip is what was run.

## How work is managed

1. Each piece of work is a task file `tasks/T<n>.md` with an owner, status, and acceptance criteria. `tasks/README.md` is the index.
2. Whoever does the task writes `outputs/T<n>.md` (use `outputs/TEMPLATE.md`).
3. A different person or agent checks it against the acceptance criteria and writes `checks/T<n>.md` (use `checks/TEMPLATE.md`).
4. Every policy passes the sim-to-sim gate (`tasks/T6.md`) before it runs on hardware.
5. The lead merges checked results into `FINAL.md`, which maps each paper question to its evidence. Only checked results go into the paper.
6. When something goes wrong, add one entry to `LESSON.md`.
7. Decisions that change scope go in `DECISIONS.md` with a date.

## Rules

- **Provenance.** Every output states the repo, commit hash, task ID / config, exact command, seed, and GPU. If the working tree was dirty, say so.
- **No large files in git.** Checkpoints, datasets, and videos stay outside; record their path or W&B run ID.
- **No invented results.** Unmeasured numbers stay as `\pending{}` in the paper and "not done" in outputs.
- **Fair baselines.** Compared policies share robot asset, observations, rewards, and training budget; list every intentional difference.
- **Simulation is not the referee for Q3.** Evaluating in MPM favors MPM-trained policies; hardware is the primary comparison.
- **Stay in scope.** Do the assigned task; propose new tasks in `tasks/README.md` instead of expanding one.
- **Paper prose.** Cut generic sentences and filler lead-ins; state claims directly.

## Coding style and consistency

**IsaacLab code (both checkouts)**
- Follow the upstream Isaac Lab coding style: <https://isaac-sim.github.io/IsaacLab/main/source/refs/contributing.html#coding-style>. The same guide is in the repo at `docs/source/refs/contributing.rst`, with an agent checklist at `skills/developer/coding-style/SKILL.md`.
- Formatting and linting are enforced by `ruff` (line length 120) through `.pre-commit-config.yaml`. Run pre-commit before committing.
- Follow my custom task-construction rules in [`style/isaaclab_env_construction.md`](style/isaaclab_env_construction.md). Where they are stricter than upstream, they win. In short:
  1. Every task directory has the same layout: `agents/`, `env_cfg/` (one file per manager: action, commands, curriculum, event, observation, physics, reward, scene), `mdp/`, optional `util/`, `__init__.py`, `*_env_cfg.py`, optional `*_env.py`, and `README.md`.
  2. Config files are standalone. Do not inherit term or env configs from another task.
  3. MDP functions may be reused from another task.
  4. Task-specific constants (joint lists, body selections, ranges) live in the owning term config under `env_cfg/`, never in `mdp/`. Reusable MDP functions receive them as term parameters.

**Consistency across tasks**
- Before writing a new task, read an existing one of the same kind and match its structure, naming, and term order. Reference tasks: `contrib/velocity_mpm/g1_29dof_mpm_moving_patch` (locomotion) and `contrib/push/` (loco-manipulation).
- Task IDs follow the existing pattern, for example `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch`.
- Policies that are compared in the paper must share observation terms, order, history, noise, rewards, and robot asset. `osmo/osmo_contact_benchmark.md` is the reference for how a matched baseline is documented.
- Change shared code (`mdp/` functions used by several tasks, the moving-patch or soft-contact modules) only when the task requires it, and say so in the output, because it can silently change other tasks' results.

**Paper (LaTeX)**
- One sentence per line in `sections/*.tex`. Unmeasured values use `\pending{}`; author notes use the name macros in `shortcut.tex`.
- Result paragraphs start with a bold one-sentence claim and are tagged with the question they answer, as in `sections/evaluation.tex`.

## What exists so far (snapshot 2026-11-15)

Read from the repos on this date; not re-run. Treat as a map, and verify before relying on it.

**Paper (`RSS_Humanoid_MPM`)**
- Abstract, introduction, related work, and methodology are drafted. Evaluation section has questions Q1 to Q5 and experiment plans; every result is still `\pending{}`.

**IsaacLab, branch `junnosuke/mpm_rl_task`** (last commit 2026-11-02)
- Moving-patch MPM G1 velocity tasks under `source/isaaclab_tasks/isaaclab_tasks/contrib/velocity_mpm/`:
  - `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch` (recycling patch)
  - `IsaacContrib-Velocity-Sand-G1-29dof-MPM-MovingPatch-ParticleCache` (cached patch)
  - `...-MovingPatch-Agile`, `...-MovingPatch-LowerBody`, and `...-MixedTerrain` variants
  - `g1_29dof_mpm` (earlier MPM task without the moving patch; confirm whether it can serve as the full-domain reference)
- G1 push tasks under `contrib/push/`: `IsaacContrib-Push-G1-29dof-MPM-ObjectPush`, rigid `...-ObjectPush`, and separate `...-Locomotion` / `...-Manipulation` tasks.
- Manipulator: `IsaacContrib-UR10-Particle-Push`. The Franka particle-pushing task in the paper is not implemented yet.
- RFT soft-contact model (2D/3D resistive force theory) under `contrib/soft_contact/`.
- Baseline training recipe in `osmo/osmo_contact_benchmark.md`: rigid-rough and RFT tasks matched to the moving-patch MPM task (same observations, rewards, curricula, robot; 2 GPUs x 1,280 envs, 20,000 iterations).
- Evaluation harness in `examples/RSS/locomotion/` (untracked): runs Rigid-rough, RFT-flat, RFT-rough, and MPM-rough policies in the MPM G1 environment; W&B run IDs are listed in its README, checkpoints under `logs/rss_locomotion/checkpoints`.
- Training backends: compositional PPO and FlashSAC; OSMO workflows under `osmo/`.

**IsaacLab, branch `junnosuke/particle_nerd`** (last commit 2026-11-05; includes `mpm_rl_task` merged in)
- `examples/particle_nerd/`: `ParticleTransolver`, active-particle compaction, GPU analytical/RFT contact estimator, data collection, open- and closed-loop evaluation, for Box, Shovel, and G1. Start with `examples/particle_nerd/agent/README.md` and `documentation/methodology.rst`.
- NeRD-backed G1 tasks: `IsaacContrib-Velocity-Sand-G1-29dof-ParticleNeRD-MovingPatch`, WBC and MixedTerrain variants, and a NeRD object-push task directory.

**Deployment (`isaac_ros_deploy`, `main`)**
- Standalone G1 deployment stack with CPU ONNX Runtime inference, MuJoCo simulation (`hardware_type:=mujoco`), and hardware launch through the Unitree SDK.
- Policy bundles exist for MPM, RFT flat, RFT rough, rigid rough, reduced-order, and NeRD locomotion policies.
- `VALIDATION.md` (tests of 2026-10-29) records build, numerical, and startup checks, and states that no locomotion-quality or physical G1 test had been run.

**Not started / unknown**
- Franka task and Franka hardware; PPO + DAgger training for box pushing; quadruped task; all hardware experiments; material-parameter identification for the real terrain.
