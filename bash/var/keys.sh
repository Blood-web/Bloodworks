#!/bin/bash
########### ###>>#####   Keys   ###<<##### ########### 
VERSION="0.0.5" #Current_Version
LAST_COMPILED_DATE="Wed 03 Jul 2024 16:13:55 AWST" #Last_Population
LAST_COMPILED_DEVICE="pc:bloodweb-lp@192.168.1.137" #Last device to load BB
LAST_TARGETED_RSYNC="bloodweb-lp:_to_:bloodweb-nova 2023-09-16"
LAST_TARGETED_RSYNC="bloodweb-lp:_to_:bloodweb 2024-06-27"
LAST_RSYNC_DIRECTION="" # (PUSH/PULL)
LAST_GLOBAL_RSYNC="" # Device 
BB_DETAILS="Blood Bash is a sourced bash configuration, designed to allow for quick and easy edits"
BB_RESOURCES="" # Programs
BB_LIBS="" #libs



debugging=true 
attach_debugger=true  # if debugger ! attached, add, else ^^


# LOG_[Variable_Name] are variables that will affect the stdout of sourcing
##  These Variables may also affect additional stdout

# Logs begining and ends of files ## required log_env_state
log_events=true

# Alows break_point usage in file sourcing
LOG_FILE_SOURCING_SUCCESS=true
# After srcing, log the order that files were sourced in 
LOG_FILE_SOURCING_ORDER=false

LOG_LOCAL_BACKUP_COMMITS=true # Log when local backup are written

LOG_STABLE_BACKUP_COMMITS=true # Log when local backup are written
 
###########################   DEBUGGING   ############################

# Logs code break_points in files
breakpoint_debugging=true  #false
# Keys specifically used for debugging ÷ dbg:$key
keyword_debugging=false
# Sourcing additional files
src_debugging=true 
# 
ssh_debugging=false
# Logs Backup info | commits
backup_debugging=true #false
# Logs writing file (Default:true)
write_debugging=true #false
# Runs the blogging function
env_state_debugging=true
# Restrict andvanced blogging notes
env_advanced_debugging=false
# logs the enviroment sourcing state (bash.bashrc) #   
env_source_debugging=false
# Print out bbi
build_info_debugging=true #false
#
todo_debugging=false

# Above Variable_list ( All variables that end in "_debugging" )
debugging_vars=($(grep '_debugging=' $HOME/c/bash/var/keys.sh | cut -d '=' -f 1)) #| awk -F'_' '{print $1}'))
# Filter self          * ^^^^^^^^^ * 
debugging_vars=($(echo "${debugging_vars[@]}" | tr ' ' '\n' | grep -v "debugging_vars" | tr '\n' ' '))
# Contains the last true | false values for debugging_vars
LAST_DEBUGGING_STATE=(false false true false true true true true true false true)
# State
DEBUG_STATE_MUTATED=false


echo_debug_vars () { # Pass specific item # || else reads all

    if [[ $# -gt 0 ]]; then 
        local int="$1"
        [[ ${debugging_vars[$int]} ]] && echo "${debugging_vars[$int]}" || echo "int : $i is out of debugging var range"

    else  
        local int=0;for i in "${debugging_vars[@]}"; do # loop through all debugging vars 
        # local bool_start_point="$(calc 20 - $(rtr_strlen_as "$i" " "))"    
            echo "$((int++)) : $i : ${!i}"
        # echo "${vars[@]}"
            #  ${LAST_DEBUGING_STATE[int]}"; 
        done; 
    fi

}

toggle_debug () {
    if [[ $# -gt 0 ]]; then
        for i in $@; do
            if [[ $(isNaN "$i") -eq 1 ]]; then
                local debug_item=$(echo_debug_vars "$i")
                flip_bool "$debug_item"  # Change var state true >> false || false >> true    
                echo "Changing :lal $debug_item state"
            else
                echo "error toggle_debug $# is not an integer"
            fi
        done
    return 1
    else
        echo_debug_vars
        read -p "$hr Item(INT) to change: " debug_item_to_flip 
        # Check valid item to change || break
        [[ $(isNaN "$debug_item_to_flip") -eq 0 ]] && echo "$ debug_item :Not a valid int" && return 1
        # Store variable
        local debug_item=$(echo_debug_vars "$debug_item_to_flip")
        
    fi

    flip_bool "$debug_item"  # Change var state true >> false || false >> true    
    echo "Changing : $debug_item state"
    # read -p "Flip another?: " int

    # if [[ $(isNaN "$int") -eq 0 || "$int" == "y" ]]; then
    #    toggle_debug "$int"
    # fi  
}


load_last_debugging_state () {
    local var_count=0
    for i in "${debugging_vars[@]}"; do flip_bool $i ${LAST_DEBUGGING_STATE[$var_count]} && ((var_count++)); done
    flip_bool "DEBUG_STATE_MUTATED" false ## Unmutate    
}

flip_debug_vars () {
    # If debugging state Unmodified (Defualt), -> Rewrite LAST_DEBUGGING_STATE
    if [[ ! "$DEBUG_STATE_MUTATED" == true ]]; then
        tmp_debug_state=$(for i in "${debugging_vars[@]}"; do echo -n "${!i} "; done) 
        new_debug_state=$(echo "$tmp_debug_state" | sed -e 's/[[:space:]]*$//')
        rewrite_var LAST_DEBUGGING_STATE "($new_debug_state)"    
        flip_bool "DEBUG_STATE_MUTATED" true # MUTATE
    fi
    for i in "${debugging_vars[@]}"; do flip_bool "$i" $1; done 
}

#######################################################################

# Terminal name (sh, bash, dash)
SHELL_NAME="${0##-}" 
# All /etc/shells || Bash assumed 
ALL_SHELLS=$( [ -e /etc/shells ] && tail -n +2 /etc/shells | grep -oE '/[^/]+$' | sort -u | tr '\n' ' ' ) || echo "bash"

AVAILABLE_TERMINALS="$(echo -e "$BLUE$SHELL_NAME$NORMAL \b${ALL_SHELLS///$SHELL_NAME/}")"

GRAPHICAL_STARTUP=true

###########################   File / Folders   ############################

# Byte Size #

## Project Main
## W BACKUP
export TOTAL_REPO_SIZE="$(dir_size "$HOME/c")"
### W/O BACKUP
export LOCAL_REPO_SIZE="$(dir_size "$HOME/c" "backup")"

## Backup
### Total BACKUP size
export TOTAL_BACKUP_SIZE="$(dir_size "$HOME/c/backup")"
### local BACKUP size
export LOCAL_BACKUP_SIZE="$(dir_size "$HOME/c/backup/local")"
### stable BACKUP size
export STABLE_BACKUP_SIZE="$(dir_size "$HOME/c/backup/stable")"

export LAST_STABLE_BACKUP="$(ls -t $HOME/c/backup/stable | tail -n 1)"

###########################        MISC       ############################

# Device Stuff
## Swaps left/right click for (USB) mouse
SOUTH_PAW_MOUSE=false #true
XMOUSE_ID=$(xinput list | grep 'USB.*Mouse\|Mouse.*USB' | cut -f2 | cut -c4-)

if [[ ! "$XMOUSE_ID" == "" ]]; then
    XMOUSE_MAP=$(xinput get-button-map "$XMOUSE_ID" | cut -f1-3 -d ' ')  

    if [[ "$SOUTH_PAW_MOUSE" == true && ! "$XMOUSE_MAP" == "3 2 1" ]]; then
    xinput set-button-map "$XMOUSE_ID" 3 2 1 && echo "South Paw mouse settings: ON"
    elif [[ ! "$SOUTH_PAW_MOUSE" == true && ! "$XMOUSE_MAP" == "1 2 3" ]]; then
    xinput set-button-map "$XMOUSE_ID" 1 2 3 && echo "South Paw mouse settings: OFF"
    #else
    #echo "Mouse Settings already set" 
    fi
fi

# User-wide Sourcing Location
RC_LOCATION=$HOME/.bashrc
# User has sourcing ??
RC_SOURCING=$(echo $(grep -q "bash/env/.config" "$RC_LOCATION" && echo true || echo false))

# Connection // web based variables
HAS_INTERNET=$(ping -c 1 -W 1 "www.bloodweb.net" &> /dev/null && echo true || echo false)
# APACHE web socket
HAS_WEB_SOCKET=$([ -d "/var/www/html/" ] && echo true || echo false)
WEBPAGE_URL=$([[ "$HAS_WEB_SOCKET" == true ]] && [[ -e /var/www/html/CNAME ]] && echo $(cat /var/www/html/CNAME) || echo -e "${RED}${NEGATIVE}null")

notify_ntfy=true #"notify - notify"

quick_test=true
test_functions=true # test_arg
run_tests=false # Runs //test/test.sh ## may or may not use testing_functions

# Displays Bweb logo on terminal begin
chafa_enabled=true
# $br before each dbg_log 
linebreak_dbglog=false

# Below variables only alter state if required and will always check for availability
addto_sourcing=true # appends enviroment.sh to bash sourcing location if not already in
add_stage=true # makes staging dir and sub folders

# Backup
daily_localbackup_onlaunch=true ## checks for /backup/local/$todays_Date
overwrite_localbackup=true  ## local/$todays_date rewrite on shell
backup_logs=#true # verbose backup

max_local_backups=5 # removes oldest local backup if count exceeded
display_graphical_backup=#true # display a graphical backup during blogging (backup_range_graph)


# Generate test/test.txt
build_testing_file=true
testing_file_contents="This file is a test file ,generated env.sh (If it does not already exist). This is accomplished via:
\`[[ \"\$build_testing_file\" == true ]] && echo -e \"\$testing_file_contents\" > \"$HOME/c/test/test.txt\" \`
\n##############                                                                             ##############
\n# Feel free to mutate/remove this filae at will, as it will be regenerated on the next bash terminal #
\n##############                                                                             ##############
\nI am line 10, the end of this file."




