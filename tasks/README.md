# Task index

One row per task. Update the status here when it changes. Status: `todo` | `in progress` | `needs check` | `done` | `blocked`.

| Task | Question | Owner | Status | Depends on | Current agent (to migrate to Claude) |
|---|---|---|---|---|---|
| [T1](T1.md) | Q1: recycling vs. caching, plus the simulation performance table | TODO | in progress | — | Codex session in `~/isaac/IsaacLab` (title unknown) |
| [T2](T2.md) | Q2: embodiments and tasks | TODO | in progress | Franka task, box-push training, T6 | Codex "IsaacLab mpm moving patch development" + Claude "mpm-object-push", both in `~/isaac/IsaacLab` |
| [T3](T3.md) | Q3: MPM vs. rigid and RFT, and why | TODO | in progress | hardware access, T6 | Codex "IsaacLab mpm moving patch development" |
| [T4](T4.md) | Q4: sensitivity to material range and resolution | TODO | in progress | T3 training recipe, T6 | Claude session in `~/isaac/worktrees/IsaacLab-T4` (branch `task/T4-sensitivity`); old Codex session "IsaacLab mpm moving patch development" to be closed |
| [T5](T5.md) | Q5: Particle NeRD speedup and transfer | TODO | in progress | T3 MPM-trained reference policy, T6 | Claude session in `~/isaac/IsaacLab-particle-nerd` (branch `junnosuke/particle_nerd`); old Cursor agent (argon) to be closed |
| [T6](T6.md) | Gate: sim-to-sim check before hardware | TODO | in progress | exported policies | Codex "IsaacLab isaac_ros integ" in `~/isaac/IsaacLab` |
| [T7](T7.md) | Paper: keep the draft consistent with this repo | TODO | in progress | T1 to T6, `FINAL.md`, `DECISIONS.md` | Claude session in `~/RSS_27/RSS_Humanoid_MPM` |

## Paper sync

The lead sets a question to `stale` whenever its task file, a decision affecting it, or its `FINAL.md` row changes. The T7 session aligns the paper and reports in `outputs/T7.md`; the lead then sets it back to `aligned`.

| Question | Task | Paper state | Stale because |
|---|---|---|---|
| Q1 | T1 | not yet aligned | T7 created 2026-11-15; no alignment pass run |
| Q2 | T2 | not yet aligned | same |
| Q3 | T3 | not yet aligned | same |
| Q4 | T4 | not yet aligned | same |
| Q5 | T5 | not yet aligned | same |
| Gate | T6 | not yet aligned | same |

Tasks were already under way in separate agent sessions before this repo existed. Until each session writes a handoff into `outputs/T<n>.md`, the state of that task is not recorded here.

The questions, as written in the paper (`sections/evaluation.tex`):

- **Q1:** Is particle recycling sufficient, or is particle caching required to reproduce the full-domain terrain response on fresh and revisited terrain?
  (Simulation cost against full-domain MPM is reported as a "Simulation Performance" paragraph, not as a question.)
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
