#!/bin/bash

LOG_FILE="$HOME/c/logs/main_bash_log.log"
OLD_LOG_FILE="$HOME/c/logs/$(date '+%Y-%m-%d %H:%M:%S')_bash_log.log"
TMP_LOG_FILE="/tmp/tmp_bash_log.log"

LOGS_TO_KEEP=10
LOG_COUNT=$(ls -1 $HOME/c/logs/* 2>/dev/null | wc -l)


# Function to write to the debugging log file
write_debug_log () {
  local message="$1"
  # Append the message to the debugging log file with a timestamp
  echo -e "$message" >> "$LOG_FILE"
}

total_break_points=0
break_point () { ## counts total_break_points >> logs if true
  ((break_point++))

  local str="$@" # The text to display
  local dir="$HOME/c/bash/" # The directory to search 
  local breakpoint_location=$(grep -rl "break_point \"$str\"" "$dir")  # The  ""

  if [[ "$breakpoint_debugging" == true || "$2" == true && -n "$breakpoint_location" ]]; then 

  echo $'\x0a'"#---- ************ ----#"
  echo "$(basename ${BASH_SOURCE[1]}) line:"$(grep -n "break_point \"$@\"" "$breakpoint_location" ) 
  echo "#---- ************ ----#"

  fi
    #grep -n "break_point \"$@\"" $HOME/c/bash/env.sh ) 
}


echo_centered_text () { # centered echo
  local text
  [[ "$#" -gt 1 ]] && text="$2" || text="$1"
 
  #ignore '\`*`m' (Escapes color changes)
  local modified_text="$(echo $text | sed 's/\\[^ ]*m//g')"
  # Terminal_width
  local terminal_width=${COLUMNS:-$(tput cols)}
  # Calculate the position to start printing the text for centering
  local start_col=$(( (terminal_width - ${#modified_text}) / 2 ))

  #DEBUG
  # local proc=" text:$text \n mt_text:$modified_text \n t_count:${#text} \n mt_count ${#modified_text} \n og_delay:$(( (terminal_width - ${#text}) / 2 )) \n arg#:{$#} \ntw:$terminal_width  st:$start_col \n equation: \n width - text.len / 2 == start point \n $(( (terminal_width - ${#modified_text}) / 2 )) \n start_point * 2 + text.len == width \n $(( start_col + start_col + ${#modified_text} ))"
  # echo "$proc"

  # Print the text at the calculated starting column
  printf "%${start_col}s%s\n" "" "$(echo -e $text)"
}

# Print a head row the width of the terminal
HR () { echo $(printf "%`tput cols`s" | tr ' ' '_'); }

log_env_state () { # $1 == true for env end
  [[ "$1" == true ]] && HR && echo_centered_text $'\x0a'" BloodWeb_$SYS_TYPE""_Enviroment_Built" && HR && return 0
  [[ "$chafa_enabled" == true ]] && chafa ~/c/lib/img/logo.png --size=24x8 --stretch=on --bg=fafafa
  HR && echo ""
  echo_centered_text "Building ${WHITE}${PURPLE_FG}BloodBash${NORMAL} Version:${MAGENTA}${version}${NORMAL} :${BOLDER}${OVERLINE}${UNDERLINE}$(to_uppercase "$SYS_TYPE")${NORMAL} $(date +%-D) $(date +%-T) "
  HR && echo ""
}

dbg_log () { ## pass second arg as dbg paramater 
  if [[ "$debugging" == true && "$2" == true ]]; then 
    write_debug_log "$(date '+%Y-%m-%d %H:%M:%S') -   • $1 "
    [[ "$3" == true || "$linebreak_dbglog" == true ]] && write_debug_log "$br  • $1 " && return 0
  fi
}

src_log () { #$src_debugging
   write_debug_log "./$1 : Sourced Succesfully" "$src_debugging" # dbg srcing
} 



env_init () {
  cls && HR && echo_centered_text "#  Bloodweb v$version -initializing  # " && HR
  echo "$br"
  chafa ~/c/lib/img/logo.png --size=24x8 --stretch=on --bg=fafafa --center=on
  echo "$br"
  echo_centered_text "Build: Success..  Happy Scripting!"
  echo "$br$br$br$br$br$br$br"
}

if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$OLD_LOG_FILE"
    # If total logs exceed LOGS_TO_KEEP, remove the oldest logs until the count matches LOGS_TO_KEEP
    while [ $LOG_COUNT -gt $LOGS_TO_KEEP ]; do
        # Find the oldest file and remove it
        OLDEST_FILE=$(ls -t $HOME/c/logs/* | tail -n 1)
        rm -f "$OLDEST_FILE" 
        write_debug_log "BloodBash Version:$VERSION Compiled:$(date +%I:%M%p) $(date '+%Y-%m-%d')" true
        # Update LOG_COUNT
        LOG_COUNT=$(($LOG_COUNT - 1))
    done
else
    touch $LOG_FILE
    write_debug_log "BloodBash Version:$VERSION Compiled:$(date +%I:%M%p) $(date '+%Y-%m-%d')" true
fi
write_debug_log "Latest Stable version:$LAST_STABLE_VERSION" true
if [ $LOG_COUNT -ge $LOGS_TO_KEEP ]; then dbg_log "OLDEST_LOG_FILE: $OLDEST_FILE removed..." true ;fi