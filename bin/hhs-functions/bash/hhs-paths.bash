#!/usr/bin/env bash

#  Script: hhs-paths.bash
# Created: Oct 5, 2019
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <http://unlicense.org/>
# !NOTICE: Do not change this file. To customize your functions edit the file ~/.functions

# @function: Print each PATH entry on a separate line.
# shellcheck disable=SC2155
function __hhs_paths() {

  local pad pad_len path_dir custom private

  HHS_PATHS_FILE=${HHS_PATHS_FILE:-$HOME/.path} # Custom paths
  PATHS_D="/etc/paths.d"                        # Private system paths
  PVT_PATHS_D="/private/etc/paths"              # General system path dir

  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: ${FUNCNAME[0]} [options] <args>"
    echo ''
    echo 'Options: '
    echo '                     : Lists all PATH entries.'
    echo '           -a <path> : Add to the current <path> to PATH.'
    echo '           -r <path> : Remove from the current <path> from PATH.'
    echo '           -e        : Edit current HHS_PATHS_FILE.'
    echo '           -c        : Attempt to clears non-existing paths. System paths are not affected'
    return 1
  else
    if [ -z "$1" ] || [ "-c" = "$1" ]; then
      [ -f "$HHS_PATHS_FILE" ] || touch "$HHS_PATHS_FILE"
      pad=$(printf '%0.1s' "."{1..70})
      pad_len=70
      columns=66
      echo ' '
      echo "${YELLOW}Listing all PATH entries:"
      echo ' '
      IFS=$'\n'
      for path in $(echo -e "${PATH//:/\\n}"); do
        path="${path:0:$columns}"
        [ -f "$HHS_PATHS_FILE" ] && custom="$(grep ^"$path"$ "$HHS_PATHS_FILE")"
        [ -d "$PVT_PATHS_D" ] && private="$(grep ^"$path"$ $PVT_PATHS_D)"
        [ -d "$PATHS_D" ] && path_dir="$(grep ^"$path"$ $PATHS_D/*)"
        echo -en "${HHS_HIGHLIGHT_COLOR}${path}"
        printf '%*.*s' 0 $((pad_len - ${#path})) "$pad"
        [ "${#path}" -ge "$columns" ] && echo -en "${NC}" || echo -en "${NC}"
        if [ -d "$path" ]; then
          echo -en "${GREEN} ${CHECK_ICN} => ${WHITE}"
        else
          if [ "-c" = "$1" ]; then
            ised -e "s#(^$path$)*##g" -e '/^\s*$/d' "$HHS_PATHS_FILE"
            export PATH=${PATH//$path:/}
            echo -en "${RED} ${CROSS_ICN} => "
          else
            echo -en "${ORANGE} ${CROSS_ICN} => "
          fi
        fi
        [ -n "$custom" ] && echo -n "at $HHS_PATHS_FILE"
        [ -n "$path_dir" ] && echo -n "at $PATHS_D"
        [ -n "$private" ] && echo -n "at $PVT_PATHS_D"
        if [ -z "$custom" ] && [ -z "$path_dir" ] && [ -z "$private" ]; then
          echo -n "Shell exported"
        fi
        echo -e "${NC}"
      done
      IFS="$HHS_RESET_IFS"
      echo -e "${NC}"
    elif [ "-e" = "$1" ]; then
      vi "$HHS_PATHS_FILE"
      return 0
    elif [ "-a" = "$1" ] && [ -n "$2" ]; then
      ised -e "s#(^$2$)*##g" -e '/^\s*$/d' "$HHS_PATHS_FILE"
      if [ -d "$2" ]; then
        echo "$2" >>"$HHS_PATHS_FILE"
        export PATH="$2:$PATH"
      else
        echo "${RED}Can't add a path \"$2\" that does not exist${NC}"
        return 1
      fi
    elif [ "-r" = "$1" ] && [ -n "$2" ]; then
      ised -e "s#(^$2$)*##g" -e '/^\s*$/d' "$HHS_PATHS_FILE"
      export PATH=${PATH//$2:/}
    fi
  fi

  # Remove all $PATH duplicated entries
  export PATH=$(echo -en "$PATH" | awk -v RS=: -v ORS=: '!arr[$0]++')

  return 0
}