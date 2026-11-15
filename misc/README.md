# Migration guides

How to move each task from its current agent session to a Claude session that works from this repo. One guide per task:

| Task | Guide | Current agent | Target |
|---|---|---|---|
| T1 | [T1_migration.md](T1_migration.md) | Codex | New Claude session in its own worktree |
| T2 | [T2_migration.md](T2_migration.md) | Codex + Claude | Keep the Claude session; fold in the Codex handoff |
| T3 | [T3_migration.md](T3_migration.md) | Codex (shared) | New Claude session in its own worktree |
| T4 | [T4_migration.md](T4_migration.md) | Codex (shared) | New Claude session in its own worktree |
| T5 | [T5_migration.md](T5_migration.md) | Cursor (argon) | New Claude session in the NeRD checkout |
| T6 | [T6_migration.md](T6_migration.md) | Codex | New Claude session in `isaac_ros_deploy` |

## Do this once, before any task

1. **Commit what is on disk.** `~/isaac/IsaacLab` and `~/isaac/IsaacLab-particle-nerd` both have uncommitted changes, and `~/isaac/IsaacLab/examples/RSS/` is untracked. Worktrees and collaborators only see committed files.
   ```bash
   cd ~/isaac/IsaacLab && git status
   cd ~/isaac/IsaacLab-particle-nerd && git status
   ```
   Review the list before committing; `~/isaac/IsaacLab` shows deleted files under `contrib/g1_29dof_mpm/` that may be an unfinished move.
2. **Get all handoffs before closing any old session.** The Codex session "IsaacLab mpm moving patch development" holds T2, T3, and T4; ask it for three separate handoffs (the prompts are in each guide).
3. **Migrate one task first.** Run one task end to end, fix whatever the process gets wrong, then do the rest.

## Order

T6 and T1 are the most self-contained, so start with one of them. T3 before T4 and T5, since both depend on its training recipe and reference policy.

## Rules during migration

- One agent per working tree. Never leave an old session running in a tree a new session is editing.
- A handoff is a claim, not a result. The new session verifies it before building on it.
- The handoff goes in `outputs/T<n>.md` with status "partial"; it is replaced by real results as the task proceeds.

The per-task guides share one structure and one handoff format. If you change the format, change it in all six.

## Opening all sessions at once

`scripts/sessions.sh` opens one tmux window per session (lead, paper, T1 to T6), each in its own directory with the master repo added. It works under byobu as well.

```bash
scripts/sessions.sh --new T1      # first launch of a task: starts a Claude session named rss-T1
scripts/sessions.sh               # later: resumes every named session
scripts/sessions.sh --dry-run     # print the commands without launching
```

Sessions are resumed by name (`rss-T1`, ..., `rss-lead`, `rss-paper`; T2 uses the existing `mpm-object-push`), so start each one through the script with `--new` the first time. Windows whose worktree does not exist yet are skipped.
