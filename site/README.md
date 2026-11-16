# Site: slides per task

Each task presents its plots, videos, and snapshot figures as HTML slides here. `outputs/T<n>.md` stays the record that gets checked; the slides show what it states.

## Layout

```
site/
  index.html     links to every task's slides, with the task status
  T<n>/
    index.html   the slides
    fig/         plots and still images (PNG or SVG), tracked in git
    media/       videos, ignored by git
```

Folder names match the task: `site/T1` goes with `tasks/T1.md`, `outputs/T1.md`, and `checks/T1.md`.

## Rules

1. **The output is the source for numbers.** Every number on a slide also appears in `outputs/T<n>.md` with its provenance. If they disagree, the output is right and the slide is fixed. `outputs/T<n>.md` links to `site/T<n>/index.html`.
2. **Plain HTML, no build step.** `index.html` opens from disk in a browser, uses relative paths only, and loads nothing from the network. One slide per acceptance criterion, in the order of the task file, plus a title slide and a "not done / caveats" slide.
3. **Every figure and video states its source** in a caption: the script that produced it, the raw data path, the repo commit (and whether the tree was dirty), and the run or checkpoint ID. A figure without this cannot be checked.
4. **Every result is labelled `unchecked` or `checked`.** A result is `unchecked` until `checks/T<n>.md` passes it. Only the lead changes a label to `checked`. The paper takes figures only for results listed in `FINAL.md`.
5. **Figures are generated, not edited by hand.** The plotting script lives in the code repo next to the experiment. `fig/` holds its output. Regenerate the figure when the data changes.
6. **No large files in git.** Files in `fig/` are at most 1 MB each. Videos go in `media/`, which git ignores; the caption gives the durable path of the original (outside `/tmp`). Keep clips short and state the playback speed.
7. **Missing results are shown as missing.** A slide for a criterion with no result says "not done" and why. Do not fill it with a related plot that answers a different question.
8. **Failures are shown.** Failed trials, early terminations, and out-of-memory limits appear on the slide for the criterion they affect, not only in the caveats.
