#!/usr/bin/env bash
# Open one tmux window per project session, each running Claude in the right directory.
#
#   scripts/sessions.sh            resume the named session in every window
#   scripts/sessions.sh --new      first launch: start new named sessions
#   scripts/sessions.sh --dry-run  print what would run, launch nothing
#   scripts/sessions.sh T1 T3      only these windows (combine with the flags above)
#
# Works under byobu too (it uses tmux). Windows whose directory does not exist are
# skipped; create worktrees first (see misc/T<n>_migration.md, Step 2).
set -euo pipefail

MASTER="$HOME/RSS_27/RSS_MPM_Project_Skill"
ISAACLAB="$HOME/isaac/IsaacLab"
TMUX_SESSION="rss-mpm"

# window | directory | Claude session name | extra --add-dir (optional)
SESSIONS=(
  "lead|$MASTER|rss-lead|"
  "paper|$HOME/RSS_27/RSS_Humanoid_MPM|rss-paper|$MASTER"
  "T1|$HOME/isaac/worktrees/IsaacLab-T1|rss-T1|$MASTER"
  "T2|$ISAACLAB|mpm-object-push|$MASTER"
  "T3|$HOME/isaac/worktrees/IsaacLab-T3|rss-T3|$MASTER"
  "T4|$HOME/isaac/worktrees/IsaacLab-T4|rss-T4|$MASTER"
  "T5|$HOME/isaac/IsaacLab-particle-nerd|rss-T5|$MASTER"
  "T6|$HOME/workspace/isaac_ros_deploy|rss-T6|$MASTER $ISAACLAB"
)

mode="resume"; dry=0; only=()
for arg in "$@"; do
  case "$arg" in
    --new) mode="new" ;;
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) only+=("$arg") ;;
  esac
done

wanted() {
  [ ${#only[@]} -eq 0 ] && return 0
  local w; for w in "${only[@]}"; do [ "$w" = "$1" ] && return 0; done
  return 1
}

if [ $dry -eq 0 ] && ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  tmux new-session -d -s "$TMUX_SESSION" -n home -c "$MASTER"
fi

for entry in "${SESSIONS[@]}"; do
  IFS='|' read -r win dir name extra <<<"$entry"
  wanted "$win" || continue
  if [ ! -d "$dir" ]; then
    echo "skip $win: $dir does not exist"; continue
  fi
  cmd="claude"
  for d in $extra; do cmd+=" --add-dir $d"; done
  if [ "$mode" = "new" ]; then cmd+=" --name $name"; else cmd+=" --resume $name"; fi

  if [ $dry -eq 1 ]; then
    printf '%-6s %s\n       %s\n' "$win" "$dir" "$cmd"; continue
  fi
  if tmux list-windows -t "$TMUX_SESSION" -F '#W' | grep -qx "$win"; then
    echo "skip $win: window already open"; continue
  fi
  tmux new-window -t "$TMUX_SESSION" -n "$win" -c "$dir"
  tmux send-keys -t "$TMUX_SESSION:$win" "$cmd" Enter
done

[ $dry -eq 1 ] && exit 0
if [ -n "${TMUX:-}" ]; then tmux switch-client -t "$TMUX_SESSION"; else tmux attach -t "$TMUX_SESSION"; fi
