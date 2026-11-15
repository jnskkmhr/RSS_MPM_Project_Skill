# Migrating T5 to Claude: Particle NeRD speedup and transfer (Q5)

Follow the shared steps in [README.md](README.md) first (commit the dirty trees). Task definition: [`tasks/T5.md`](../tasks/T5.md).

## Where the work is now
Cursor agent (argon) in `~/isaac/IsaacLab-particle-nerd`.

## Step 1: get the handoff
Reopen the old session and paste this.

```text
We are moving this work to a shared project repo. Do not start new work and do not change any code.
Write a handoff document covering only Particle NeRD: data collection, Transolver training, contact estimator, closed-loop evaluation, and NeRD-backed G1 policy training.

Save it to /home/jkamohara/RSS_27/RSS_MPM_Project_Skill/outputs/T5.md. If you cannot write there, print it in full instead.

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
   - Is `examples/particle_nerd/agent/README.md` current? List anything it gets wrong or leaves out.
   - Which checkpoint is the selected one, on what data and material range was it trained, and what are its rollout errors?
   - Has a locomotion policy been trained in NeRD and evaluated in MPM? With what result?
   - What throughput and VRAM numbers exist against MPM, and how were they measured?

If you do not know something, write "unknown". Do not guess.
```

Read the result yourself before moving on. If it is thin, ask follow-up questions in the same session while its context is still available.

## Step 2: start the Claude session
T5 is the only task in this checkout, so no worktree is needed.

```bash
cd ~/isaac/IsaacLab-particle-nerd
git status          # commit or stash the Cursor agent's uncommitted changes first
claude --add-dir ~/RSS_27/RSS_MPM_Project_Skill
```

Stop the Cursor agent before the Claude session starts editing, so two agents do not write to the same tree.

## Step 3: first prompt
```text
Read ~/RSS_27/RSS_MPM_Project_Skill/ONBOARD.md, then ~/RSS_27/RSS_MPM_Project_Skill/tasks/T5.md, then ~/RSS_27/RSS_MPM_Project_Skill/outputs/T5.md.

outputs/T5.md is a handoff written by a previous agent. Treat it as unverified.
First, check it: confirm that the files, commits, task IDs, and artifacts it names exist, and list anything that does not match.
Then go through the acceptance criteria in tasks/T5.md and say for each whether it is done, partial, or not started.
Propose a plan and wait for my approval before launching training runs or changing shared code.
```

## Step 4: after the session confirms the handoff
- Update the owner, status, and "Current agent" column in [`tasks/README.md`](../tasks/README.md).
- Close the old session so it does not keep editing the same files.
- Record anything the handoff got wrong in [`LESSON.md`](../LESSON.md).
