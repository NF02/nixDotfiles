# Ponte tra Waybar e Hyprland per i pulsanti workspace.
# Usa i dispatcher Lua di Hyprland (0.55+), che Waybar 0.15 non usa ancora.
set -euo pipefail

readonly MIN_WS=1
readonly MAX_WS=9

monitors_json() { hyprctl -j monitors; }
workspaces_json() { hyprctl -j workspaces; }

print_workspace() {
  local n="${1}"
  local monitors workspaces

  monitors=$(monitors_json)
  workspaces=$(workspaces_json)

  # shellcheck disable=SC2016
  jq -nc \
    --argjson n "$n" \
    --argjson monitors "$monitors" \
    --argjson workspaces "$workspaces" '
      ($monitors | map({id: .activeWorkspace.id, focused: .focused})) as $active
      | ($active | any(.id == $n)) as $isActive
      | ($active | any(.focused and .id == $n)) as $isFocused
      | ($workspaces | map(select(.id == $n)) | first) as $ws
      | ($ws.windows // 0) as $windows
      | {
          text: ($n | tostring),
          class: (
            ["ws"]
            + (if $isActive then ["active"] else [] end)
            + (if $isFocused then ["focused"] else [] end)
            + (if $windows > 0 then ["occupied"]
               elif ($isActive | not) then ["empty"]
               else [] end)
          ),
          tooltip: (
            "Workspace \($n)\n"
            + (if $isFocused then "Attivo (monitor con focus)"
               elif $isActive then "Visibile su un altro monitor"
               else "Non attivo" end)
            + (if $windows > 0 then
                 "\nFinestre: \($windows)"
                 + (if ($ws.lastwindowtitle // "") != "" then "\nUltima: \($ws.lastwindowtitle)" else "" end)
               else
                 "\nNessuna finestra"
               end)
            + (if ($ws.monitor // "") != "" then "\nMonitor: \($ws.monitor)" else "" end)
          )
        }'
}

print_secret() {
  local monitors

  monitors=$(monitors_json)

  # shellcheck disable=SC2016
  jq -nc --argjson monitors "$monitors" '
    ($monitors | map(select((.specialWorkspace.name // "") != "")) | first) as $special
    | ($special != null) as $open
    | {
        text: "",
        class: (
          ["secret"]
          + (if $open then ["active"] else ["empty"] end)
        ),
        tooltip: (
          "Workspace segreto (SUPER+S)"
          + (if $open then
               "\nAperto: \($special.specialWorkspace.name) su \($special.name)"
             else
               "\nChiuso"
             end)
        )
      }'
}

focus_workspace() {
  hyprctl dispatch "hl.dsp.focus({ workspace = ${1} })" >/dev/null
}

move_window() {
  hyprctl dispatch "hl.dsp.window.move({ workspace = ${1}, follow = false })" >/dev/null
}

relative_workspace() {
  local dir="${1}"
  local current target

  current=$(hyprctl activeworkspace -j | jq -r '.id')
  if [[ ! ${current} =~ ^[0-9]+$ ]]; then
    current=${MIN_WS}
  fi

  target=$((current + dir))
  if ((target < MIN_WS)); then
    target=${MAX_WS}
  elif ((target > MAX_WS)); then
    target=${MIN_WS}
  fi

  focus_workspace "${target}"
}

toggle_secret() {
  hyprctl dispatch 'hl.dsp.workspace.toggle_special("secret")' >/dev/null
}

case "${1:-}" in
  status)
    if [[ -z ${2:-} ]]; then
      echo "numero workspace mancante" >&2
      exit 2
    fi
    print_workspace "${2}"
    ;;
  secret-status)
    print_secret
    ;;
  focus)
    focus_workspace "${2:?numero workspace mancante}"
    ;;
  move)
    move_window "${2:?numero workspace mancante}"
    ;;
  rel)
    relative_workspace "${2:?direzione mancante}"
    ;;
  secret-toggle)
    toggle_secret
    ;;
  *)
    echo "uso: $0 {status N|secret-status|focus N|move N|rel +1/-1|secret-toggle}" >&2
    exit 2
    ;;
esac
