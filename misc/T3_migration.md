# Migrating T3 to Claude: MPM vs. rigid and reduced-order training (Q3)

Follow the shared steps in [README.md](README.md) first (commit the dirty trees). Task definition: [`tasks/T3.md`](../tasks/T3.md).

## Where the work is now
Codex session "IsaacLab mpm moving patch development" in `~/isaac/IsaacLab` (shared with T2 and T4; ask for a T3-only handoff).

## Step 1: get the handoff
Reopen the old session and paste this.

```text
We are moving this work to a shared project repo. Do not start new work and do not change any code.
Write a handoff document covering only the baseline comparison: training Rigid, RFT, MPM-Flat, and MPM-Rough locomotion policies and evaluating them, including `osmo/osmo_contact_benchmark.md` and `examples/RSS/locomotion/`.

Save it to /home/jkamohara/RSS_27/RSS_MPM_Project_Skill/outputs/T3.md. If you cannot write there, print it in full instead.

Use exactly these sections:
1. Scope: what this session worked on for this topic.
2. State of the code: branch, last commit, and every uncommitted or untracked file this work depends on.
3. Commands and configs: the exact commands, task IDs, and config files used for each result.
4. Artifacts: paths to checkpoints, logs, datasets, videos, and W&B run IDs.
5. Results so far: numbers with units. Mark each as "measured in this session" or "not verified".
6. Failed attempts: what was tried and did not work, and why.
7. Known bugs and open issues.
8. Next steps you would take.
9. Specific questions:
   - Which of the policies listed in `examples/RSS/locomotion/README.md` were trained with the matched recipe in `osmo/osmo_contact_benchmark.md`, and which predate it?
   - Does the rigid baseline randomize friction and contact compliance?
   - Which gait metrics are already logged (sinkage, slip, clearance, gait timing, pelvis acceleration, cost of transport)?

If you do not know something, write "unknown". Do not guess.
```

Read the result yourself before moving on. If it is thin, ask follow-up questions in the same session while its context is still available.

## Step 2: start the Claude session
```bash
cd ~/isaac/IsaacLab
git worktree add ~/isaac/worktrees/IsaacLab-T3 -b task/T3-baselines junnosuke/mpm_rl_task
cd ~/isaac/worktrees/IsaacLab-T3
claude --add-dir ~/RSS_27/RSS_MPM_Project_Skill
```

A new worktree contains only committed files. It has no Python environment and none of the untracked `logs/`, `exports/`, or `wandb/` directories. Set up the environment in the worktree as the repo's install instructions describe, and refer to existing checkpoints by their absolute path under `~/isaac/IsaacLab`.

## Step 3: first prompt
```text
Read ~/RSS_27/RSS_MPM_Project_Skill/ONBOARD.md, then ~/RSS_27/RSS_MPM_Project_Skill/tasks/T3.md, then ~/RSS_27/RSS_MPM_Project_Skill/outputs/T3.md.

outputs/T3.md is a handoff written by a previous agent. Treat it as unverified.
First, check it: confirm that the files, commits, task IDs, and artifacts it names exist, and list anything that does not match.
Then go through the acceptance criteria in tasks/T3.md and say for each whether it is done, partial, or not started.
Propose a plan and wait for my approval before launching training runs or changing shared code.
```

## Step 4: after the session confirms the handoff
- Update the owner, status, and "Current agent" column in [`tasks/README.md`](../tasks/README.md).
- Close the old session so it does not keep editing the same files.
- Record anything the handoff got wrong in [`LESSON.md`](../LESSON.md).
