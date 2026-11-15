# Migrating T2 to Claude: Policies across embodiments and tasks (Q2)

Follow the shared steps in [README.md](README.md) first (commit the dirty trees). Task definition: [`tasks/T2.md`](../tasks/T2.md).

## Where the work is now
Two sessions in `~/isaac/IsaacLab`: Codex "IsaacLab mpm moving patch development" and Claude "mpm-object-push".

## Step 1: get the handoff
Reopen the old session and paste this. Paste it into the Codex session; the Claude session is being kept, so ask it only to append its own state to the same file under a heading "Claude session".

```text
We are moving this work to a shared project repo. Do not start new work and do not change any code.
Write a handoff document covering only the embodiment and task work: G1 box pushing on MPM, the manipulator particle-pushing task (UR10 now, Franka planned), and any PPO + DAgger whole-body training.

Save it to /home/jkamohara/RSS_27/RSS_MPM_Project_Skill/outputs/T2.md. If you cannot write there, print it in full instead.

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
   - What is the state of G1 box pushing on MPM: which task ID trains, and what does the policy do today?
   - What exists for the manipulator task, and what is missing to move from UR10 to Franka?
   - Is PPO + DAgger for whole-body box pushing implemented? If so, where?

If you do not know something, write "unknown". Do not guess.
```

Read the result yourself before moving on. If it is thin, ask follow-up questions in the same session while its context is still available.

## Step 2: start the Claude session
The Claude session "mpm-object-push" already holds the box-pushing work, so keep it rather than starting over.

```bash
cd ~/isaac/IsaacLab
claude --resume          # pick "mpm-object-push"
```

Inside the session, run `/add-dir ~/RSS_27/RSS_MPM_Project_Skill` so it can read the master repo.

If you want T2 isolated from the other tasks, move it to its own worktree once the dirty tree is committed, and start a new session there instead:

```bash
cd ~/isaac/IsaacLab
git worktree add ~/isaac/worktrees/IsaacLab-T2 -b task/T2-embodiments junnosuke/mpm_rl_task
cd ~/isaac/worktrees/IsaacLab-T2
claude --add-dir ~/RSS_27/RSS_MPM_Project_Skill
```

A new worktree has no Python environment and none of the untracked `logs/`, `exports/`, or `wandb/` directories.

## Step 3: first prompt
```text
Read ~/RSS_27/RSS_MPM_Project_Skill/ONBOARD.md, then ~/RSS_27/RSS_MPM_Project_Skill/tasks/T2.md, then ~/RSS_27/RSS_MPM_Project_Skill/outputs/T2.md.

outputs/T2.md is a handoff written by a previous agent. Treat it as unverified.
First, check it: confirm that the files, commits, task IDs, and artifacts it names exist, and list anything that does not match.
Then go through the acceptance criteria in tasks/T2.md and say for each whether it is done, partial, or not started.
Propose a plan and wait for my approval before launching training runs or changing shared code.
```

## Step 4: after the session confirms the handoff
- Update the owner, status, and "Current agent" column in [`tasks/README.md`](../tasks/README.md).
- Close the old session so it does not keep editing the same files.
- Record anything the handoff got wrong in [`LESSON.md`](../LESSON.md).
