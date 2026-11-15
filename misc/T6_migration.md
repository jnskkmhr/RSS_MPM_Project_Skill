# Migrating T6 to Claude: Sim-to-sim sanity check before hardware deployment

Follow the shared steps in [README.md](README.md) first (commit the dirty trees). Task definition: [`tasks/T6.md`](../tasks/T6.md).

## Where the work is now
Codex session "IsaacLab isaac_ros integ" in `~/isaac/IsaacLab`.

## Step 1: get the handoff
Reopen the old session and paste this.

```text
We are moving this work to a shared project repo. Do not start new work and do not change any code.
Write a handoff document covering only the deployment path: exporting policies from IsaacLab, building policy bundles in `~/workspace/isaac_ros_deploy`, and checking them in its MuJoCo simulation.

Save it to /home/jkamohara/RSS_27/RSS_MPM_Project_Skill/outputs/T6.md. If you cannot write there, print it in full instead.

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
   - What is the exact procedure to export a policy from IsaacLab and turn it into a bundle in `isaac_ros_deploy`?
   - Which bundles have been run closed-loop in the MuJoCo simulation with non-zero commands, and what happened?
   - Which interface settings must match training (observation order, history, joint order, action scale, gains, rate), and where is each defined on both sides?
   - Anything in `VALIDATION.md` that is now out of date?

If you do not know something, write "unknown". Do not guess.
```

Read the result yourself before moving on. If it is thin, ask follow-up questions in the same session while its context is still available.

## Step 2: start the Claude session
T6 spans two repos. Run the session in the deployment repo and give it read access to IsaacLab for the export side.

```bash
cd ~/workspace/isaac_ros_deploy
claude --add-dir ~/RSS_27/RSS_MPM_Project_Skill --add-dir ~/isaac/IsaacLab
```

If T6 needs to change IsaacLab export code while other tasks are running there, make those changes in a worktree (`git worktree add ~/isaac/worktrees/IsaacLab-T6 -b task/T6-export junnosuke/mpm_rl_task`), not in the shared checkout.

## Step 3: first prompt
```text
Read ~/RSS_27/RSS_MPM_Project_Skill/ONBOARD.md, then ~/RSS_27/RSS_MPM_Project_Skill/tasks/T6.md, then ~/RSS_27/RSS_MPM_Project_Skill/outputs/T6.md.

outputs/T6.md is a handoff written by a previous agent. Treat it as unverified.
First, check it: confirm that the files, commits, task IDs, and artifacts it names exist, and list anything that does not match.
Then go through the acceptance criteria in tasks/T6.md and say for each whether it is done, partial, or not started.
Propose a plan and wait for my approval before launching training runs or changing shared code.
```

## Step 4: after the session confirms the handoff
- Update the owner, status, and "Current agent" column in [`tasks/README.md`](../tasks/README.md).
- Close the old session so it does not keep editing the same files.
- Record anything the handoff got wrong in [`LESSON.md`](../LESSON.md).
