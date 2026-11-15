# Task index

One row per task. Update the status here when it changes. Status: `todo` | `in progress` | `needs check` | `done` | `blocked`.

| Task | Question | Owner | Status | Depends on | Current agent (to migrate to Claude) |
|---|---|---|---|---|---|
| [T1](T1.md) | Q1: moving patch cost, fidelity, cache | TODO | in progress | — | Codex session in `~/isaac/IsaacLab` (title unknown) |
| [T2](T2.md) | Q2: embodiments and tasks | TODO | in progress | Franka task, box-push training, T6 | Codex "IsaacLab mpm moving patch development" + Claude "mpm-object-push", both in `~/isaac/IsaacLab` |
| [T3](T3.md) | Q3: MPM vs. rigid and RFT, and why | TODO | in progress | hardware access, T6 | Codex "IsaacLab mpm moving patch development" |
| [T4](T4.md) | Q4: sensitivity to material range and resolution | TODO | in progress | T3 training recipe, T6 | Codex "IsaacLab mpm moving patch development" |
| [T5](T5.md) | Q5: Particle NeRD speedup and transfer | TODO | in progress | T3 MPM-trained reference policy, T6 | Cursor agent (argon) in `~/isaac/IsaacLab-particle-nerd` |
| [T6](T6.md) | Gate: sim-to-sim check before hardware | TODO | in progress | exported policies | Codex "IsaacLab isaac_ros integ" in `~/isaac/IsaacLab` |

Tasks were already under way in separate agent sessions before this repo existed. Until each session writes a handoff into `outputs/T<n>.md`, the state of that task is not recorded here.

The questions, as written in the paper (`sections/evaluation.tex`):

- **Q1:** Does the moving patch bound simulation cost while preserving full-domain MPM physics, including on revisited terrain?
- **Q2:** Can the framework train successful policies across embodiments and tasks at practical wall-clock cost?
- **Q3:** Does MPM training improve sim-to-real transfer over rigid and reduced-order terrain models, and which behaviors explain the difference?
- **Q4:** How sensitive is policy performance to material randomization and particle resolution?
- **Q5:** Does Particle NeRD yield a net training speedup while transferring to MPM and hardware?

## Proposed tasks

Add ideas here instead of expanding an existing task. The lead promotes them to `T<n>.md`.

- Sanity check for box pushing: measure push force against push distance in MPM. If it stays flat, the box behaves like a rigid body with friction and the task does not show a benefit from particles; change box mass, material, or push length.
- Franka particle-pushing task (currently only `IsaacContrib-UR10-Particle-Push` exists).
- PPO + DAgger training for whole-body box pushing.
- Material-parameter identification for the real terrain.
