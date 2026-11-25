# Task index

One row per task. Update the status here when it changes. Status: `todo` | `in progress` | `needs check` | `done` | `blocked`.

| Task | Question | Owner | Status | Depends on | Current agent (to migrate to Claude) |
|---|---|---|---|---|---|
| [T1](T1.md) | Q1: streaming MPM benchmark: scaling with terrain size and environments, terrain history | Junnosuke | P1 to P3 done and checked (2026-11-19); P2b and the bed-compaction analysis (2026-11-24) unchecked | — | Claude session in `~/isaac/worktrees/IsaacLab-T1`, working on `~/isaac/worktrees/mpm-unification/IsaacLab` |
| [T2](T2.md) | Q2: policy success across embodiments (UR10, Go2, G1) and tasks (particle pushing, walking, object towing) | TODO | in progress | — | Codex "IsaacLab mpm moving patch development" + Claude "mpm-object-push", both in `~/isaac/IsaacLab` |
| [T3](T3.md) | Q3: where particle simulation helps: yielding terrain (slope and material together) and object towing; against rigid and RFT training | TODO | in progress | final checkpoint of MPM-Rough, T2 towing policies, hardware access, T6 | Codex "IsaacLab mpm moving patch development" |
| [T4](T4.md) | Retired 2026-11-18; merged into T3 | — | retired | — | Claude session in `~/isaac/worktrees/IsaacLab-T4` (branch `task/T4-sensitivity`), to be stopped or reassigned |
| [T5](T5.md) | Q5: Particle NeRD speedup and transfer | lead-launched agent (2026-11-25, overnight) | in progress: NeRD policy training on mixed terrain, corrected run `657cyza6` (first run `rcvgr7b9` cancelled: faulty graph step); first check in `checks/T5.md` | T3 MPM-trained reference policy, T6 | Claude session in `~/isaac/IsaacLab-particle-nerd` (branch `junnosuke/particle_nerd`); old Cursor agent (argon) to be closed |
| [T6](T6.md) | Gate: sim-to-sim check before hardware | TODO | in progress | exported policies | Codex "IsaacLab isaac_ros integ" in `~/isaac/IsaacLab` |
| [T7](T7.md) | Paper: keep the draft consistent with this repo | TODO | in progress | T1 to T6, `FINAL.md`, `DECISIONS.md` | Claude session in `~/RSS_27/RSS_Humanoid_MPM` |
| [T8](T8.md) | Accuracy of MPM: box drag in DEM (Chrono DEM-Engine) against MPM, with matched material | lead-launched agent | second round done 2026-11-24 (97 OSMO tasks); three rounds done, three checks passed with caveats; merged into `FINAL.md` 2026-11-24. Open: no converged MPM force, gantry effect unexplained, sampling decision (`DECISIONS.md`), no git remote for the code | T1 box probe | background agent of the lead session, workspace `~/isaac/dem_compare/` |

## Paper sync

The lead sets a question to `stale` whenever its task file, a decision affecting it, or its `FINAL.md` row changes. The T7 session aligns the paper and reports in `outputs/T7.md`; the lead then sets it back to `aligned`.

| Question | Task | Paper state | Stale because |
|---|---|---|---|
| Q1 | T1 | aligned, with unchecked numbers | 2026-11-22 (T7 pass 7): both T1 figures are in as placeholders with captions, and the training-speed paragraph is added with `\unchecked{}` numbers. The Q1 wording does not mention training speed yet. The main text is about 0.6 page over the five-page budget. |
| Q2 | T2 | aligned, with unchecked numbers | 2026-11-21 (T7 pass 6): text follows `tasks/T2.md`. The towing numbers come from `outputs/T2.md`, are unchecked, and are wrapped in `\unchecked{}`; everything else is `\pending{}`. |
| Q3 | T3 | stale | 2026-11-23: the slope and material axes are merged into one section on yielding terrain (`DECISIONS.md` of that date), so sections C-1 and C-2 of the paper become one; the towing numbers changed on 2026-11-22 and 2026-11-23 (material-matched RFT, sinkage measured from the settled surface, channel test); figures 4 and 5 still show the earlier MPM policy until the final checkpoint of `aga5ovkp` is evaluated. All T3 numbers are unchecked. |
| Q4 | — | aligned | 2026-11-21 (T7 pass 6): removed from the paper. |
| Q5 | T5 | not yet aligned | same |
| Gate | T6 | not yet aligned | same |
| Front and back matter | — | stale | 2026-11-21: abstract, introduction, related work, and conclusion still use the old names and mention Franka, box pushing, and hardware pushing. 83 `\unchecked{}` numbers are in the draft (list in `outputs/T7.md`, pass 6). |

Tasks were already under way in separate agent sessions before this repo existed. Until each session writes a handoff into `outputs/T<n>.md`, the state of that task is not recorded here.

The questions, as written in the paper (`sections/evaluation.tex`):

- **Q1:** Is particle recycling sufficient, or is particle caching required to reproduce the full-domain terrain response on fresh and revisited terrain?
  (Simulation cost against full-domain MPM is reported as a "Simulation Performance" paragraph, not as a question.)
- **Q2:** Can the framework train successful policies across embodiments and tasks at practical wall-clock cost?
- **Q3:** How do policies trained on MPM compare with policies trained on rigid and reduced-order terrain models, in simulation on terrain beyond the training distribution and on hardware, and which behaviors explain the difference?
- **Q4:** How sensitive is policy performance to material randomization and particle resolution?
- **Q5:** Does Particle NeRD yield a net training speedup while transferring to MPM and hardware?

## Proposed tasks

Add ideas here instead of expanding an existing task. The lead promotes them to `T<n>.md`.

- (Done as part of T2: the pushing-resistance check is now measurement rule 3 in `tasks/T2.md`. Dropped on 2026-11-18: a new Franka particle-pushing task, and PPO + DAgger for box pushing.)
- Material-parameter identification for the real terrain.
