#!/usr/bin/env bash

### Utility functions to work with files
file_exists() {
  if [[ -f "$1" ]]; then
    true
  else
    false
  fi
}
# check for existence of pattern $2 in file $1
line_exists() {
  local file="$1"
  local line="$2"

  if ! file_exists "$file" || ! grep -qe "$line" "$file"; then
    false
  else
    true
  fi
}
# prepare newline at eof to make adding newlines easier
eol_exists_or_append() {
  local file="$1"
  local eof
  eof=$(tail -c 1 "$file")

  if [ -n "$eof" ]; then
    printf "\\n" >>"$file"
  fi
}
# append line $2 to file $1
line_exists_or_append() {
  local file="$1"
  local line="$2"
  local new="${3:-$2}"

  if ! line_exists "$file" "$line"; then
    eol_exists_or_append "$file"
    echo "$new" >>"$file"
  fi
}
# Print a debug message to stdout
dbg_msg() {
  local application="$1"
  shift

  # the debug-level of the message
  local level="$1"
  local color
  case "$level" in
  error)
    level=0
    color="\u001b[31;1m"
    shift
    ;;
  warn)
    level=1
    color="\u001b[33;1m"
    shift
    ;;
  info)
    level=2
    color="\u001b[32;1m"
    shift
    ;;
  *)
    level=2
    color="\u001b[32;1m"
    ;;
  esac

  # the minimum debug level to display
  local display=${STYLER_DEBUG:-"0"}
  case "$display" in
  error) display=0 ;;
  warn) display=1 ;;
  info) display=2 ;;
  esac

  # if the user wants to be informed, send it out there
  if (("$level" <= "$display")); then

    # send it to notification daemon if libnotify exists
    if command -v notify-send >/dev/null; then
      local urgency
      case "$level" in
      0) urgency="critical" ;;
      1) urgency="normal" ;;
      2 | *) urgency="low" ;;
      esac
      notify-send --urgency="$urgency" "$(tr '[:lower:]' '[:upper:]' <<<\["$application"])" "$@"

    fi
    # otherwise just print it out
    printf "%b%-15s %s \u001b[0m\n" "$color" "$(tr '[:lower:]' '[:upper:]' <<<\["$application"])" "$@"
  fi

}
