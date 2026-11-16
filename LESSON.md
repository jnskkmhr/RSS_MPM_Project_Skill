# Lessons

What went wrong and how it was fixed. One entry each, written as a rule someone can follow. If a lesson keeps recurring, promote it to the Rules in `ONBOARD.md`.

Format:

```
- **YYYY-MM-DD, T<n>. <rule in one line>.** What happened: <one sentence>. Fix: <one sentence>.
```

- **2026-11-15, T4. Check the handoff's git state against the repo before trusting it.** What happened: outputs/T4.md said HEAD was bc77a1a41 with a dirty tree and untracked `contrib/velocity_mpm/`, but the work had since been committed as dcdc2ff3c ("Snapshot MPM RSS work"). Fix: the worktree was branched from the snapshot commit, so a clean checkout does contain those files.
- **2026-11-15, T5. Treat a handoff's untracked-file list as a lower bound; run `git status` yourself.** What happened: outputs/T5.md listed the dependent untracked files, and every path it named exists with HEAD `f9b9704fe` matching, but it omitted untracked `examples/particle_nerd/documentation/*local*` files, `exports/`, `skills/env_construction.md` and two `changelog.d/` fragments. Fix: commit from the full `git status` output, not the handoff's list.
