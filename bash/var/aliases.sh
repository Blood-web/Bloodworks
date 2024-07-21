#!/bin/bash
###>>#####   ALIASES   ###<<#####
# ! Important : "## Alias Begin" and "## Alias End" are markers used by other functions and should not be editted or removed.
# Call `display_aliases` to... display aliases, duh.

## Aliases Begin

alias e="exit"                    # Exits terminal
alias cls="clear"                 # Clears terminal
alias r="clear && exec bash"      # Resets terminal
alias l="echo"                    # Logs to terminal
alias clsls="clear && ls"         # Clear the screen and read the current dir
alias python="python3"            # Python3 is Python
alias py="python3"                # py is python3

alias sync_pico="python3 ~/c/scripts/python/sync_pico_files.py $@"
alias update_profile=""

#formatting
export hr=$'\x0a'                    # Newline
export br=$'\x0a'                    # Line Break
export pad="       "                 # Pad text by 8 whitespaces

## Aliases End

###>>#####   Terminal Edits   ###<<#####
# ! Important : "## Terminal CSS Begin" and "## Terminal CSS End" are markers used by other functions and should not be editted or removed.
# Call `DISPLAY_ALL_TERMINAL_EDITS` to loop thorugh availabe edits.

## Terminal CSS Begin
# Reset
NORMAL="\x1B[0m"
# Font-Colours
RED="\x1B[91m"
GRAY="\x1B[90m"
BLUE="\x1B[94m"
CYAN="\x1B[96m"
GREEN="\x1B[92m"
WHITE="\x1B[97m"
YELLOW="\x1B[93m"
ORANGE="\x1B[33m"
MAGENTA="\x1B[95m"
# Background (DEEP)
RED_BG="\x1B[41m"
BLUE_BG="\x1B[94m"
CYAN_BG="\x1B[96m"
GREEN_BG="\x1B[92m"
WHITE_BG="\x1B[97m"
ORANGE_BG="\x1B[93m"
MAGENTA="\x1B[95m"
# Foregrond (LIGHT Background)
RED_FG="\x1B[41m"
BLUE_FG="\x1B[44m"
CYAN_FG="\x1B[46m"
GREEN_FG="\x1B[42m"
WHITE_FG="\x1B[47m"
PURPLE_FG="\x1B[45m"
YELLOW_FG="\x1B[43m"
# Font_Weight
BOLDER="\x1B[1m"
LIGHTER="\x1B[2m"
# Text-Decoration
BLINK="\x1B[5m"
NEGATIVE="\x1B[7m"
UNDERLINE="\x1B[4m"
OVERLINE="\x1B[53m"
DOUBLE_UNDERLINE="\x1B[21m"
STRIKE_THROUGH="\x1B[9m"
## Terminal CSS End
