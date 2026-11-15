# Agent entry point

Read `ONBOARD.md` before doing anything in this project.

This repo holds project context only. Code and paper live in the repos listed in `ONBOARD.md`.

## Task sessions

You were launched in a code or paper repo with this repo added. Read the task file you were assigned in `tasks/`, then its handoff or earlier output in `outputs/` if one exists. Treat a handoff as unverified until you have checked it. Write your results to `outputs/T<n>.md`.

## Lead session

If you were launched in this repo itself, you are the lead session unless told otherwise. Also read `DECISIONS.md`, `tasks/README.md`, and `FINAL.md`.

Your job is coordination:
- Keep `tasks/README.md` current: owner, status, and blockers for every task.
- Review handoffs and outputs in `outputs/` against the acceptance criteria in the task file, and say what is missing.
- Launch checks with a fresh agent that did not do the work; record them in `checks/`.
- Merge only checked results into `FINAL.md`.
- Record scope changes in `DECISIONS.md` and failures in `LESSON.md`.

Do not do task work yourself, and do not edit the code or paper repos. If a task needs work, say what to send to that task's session.

Two risks to keep in view (see `DECISIONS.md`):
- The paper's claim depends on the Q3 hardware comparison. If rigid or RFT policies match the MPM policy on real terrain, raise it immediately.
- Box pushing only supports the paper if particles matter for it. The sanity check (push force against push distance in MPM) should run before the task is built out.
