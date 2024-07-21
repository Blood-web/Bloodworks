#!/bin/bash

log () { #padded echo
 echo "  $1"
}
export -f log

throw_error (){
  echo -e "${RED} ERROR ! $1"
}

deprecated () {
  throw_error "$1 is deprecated, use $2"
}



####  KEYWORD MANAGEMENT #### 

# Reserve keywrds used in dbg_log via `reserve_keywords`
set_dbg_words () { 
  debug_keywords=("keyword" "src" "ssh" "e_keys")
  for i in "${debug_keywords[@]}"; do
    reserve_keywords "dbg:$i"
  done
}

declare -gx reserved_keywords="" # glob list of key:word , ie: dbg:example ssh:V
reserve_keywords () { # O(n*n)
  local key="$1" 
  for i in $reserved_keywords; do #check dupe // exit if found
   if [[ ! "$i" == "$key" ]]; then continue;
   else dbg_log "Unable to reserve key: $key" "$keyword_debugging" && return 1;
   fi
  done
  # [[ "$2" == true ]] && local kseyword_debugging=true
  # Reserve Non-Dupes
  reserved_keywords+="$key$br" && dbg_log "$key has been reserved" "$keyword_debugging" 
}
return_keywords () {
  echo "$reserved_keywords" | sort
}



###>>#####  RANDOM GENERATION && NUMBERS   ###<<#####

random_num () {
  local prefix_0="false"
  # -o prefixes 0 to numbers < 10 (useful for dates)
  [[ $1 =~ "-o" ]] && prefix_0="true" && shift
  # init min/max
  local min && local max
  # If no arguments min(1)-max(100)
  [[ "$1" =~ ^[0-9]+$ ]] && min="$1" || min="1"
  [[ "$2" =~ ^[0-9]+$ ]] && max="$2" || max="100"
  # Get randomNum
  local result=$(( min + RANDOM % (max - min + 1)))
  # Prefix 0 if num <10
  [[ $result -lt 10 && "$prefix_0" == "true" ]] && result="0$result"
  # Return 
  echo "$result"
}

isNeg () { [ "$1" -lt 0 ] && echo true || echo false; }
isEven() { [ "$1" -eq 1 ] && echo true || echo false; }

inRange () { 
  [[ "$#" -lt 3 ]] && "InRange needs 3 arguments: 1(Integer to check) 2(Min) 3(Max)" && return 1
  [[ "$1" -ge "$2" ]] && [[ "$1" -le "$3" ]] && echo true || echo false
}

setRange () {
  local num="$1"
  [[ "$#" -lt 3 ]] && "SetRange needs 3 arguments: 1(Integer to set) 2(Min) 3(Max)" && return 1
  [[ "$num" -lt "$2" ]] && num="$3" # Set range
  [[ "$num" -gt "$3" ]] && num="$2" # Set range
  echo "$num"
}


bytes_to_relative () {
  local size=$1 # 
  local total # Return value
  # Penta >> Terra >> Giga >> Mega >> Kila >> Byte
  if [ "$size" -gt 1123899906842624 ]; then total="$(bc <<< "scale=2; $size / 1123899906842624")PB";
  elif [ "$size" -gt 1099511627776 ]; then total="$(bc <<< "scale=2; $size / 1099511627776")TB";
  elif [ "$size" -gt 1073741824 ]; then total="$(bc <<< "scale=2; $size / 1073741824")GB";
  elif [ "$size" -gt 1048576 ]; then total="$(bc <<< "scale=2; $size / 1048576")MB";
  elif [ "$size" -gt 1024 ]; then total="$(bc <<< "scale=2; $size / 1024")KB";
  else total="${size}B";
  fi
 
  echo "${total}"
}


###>>#####   SYS/File/Folder READS   ###<<#####

## SYSTEM READS

### Get size of dir in (r)Bytes
dir_size () {
  # $1 == location && $2 == subdir to ignore || null
  local dir="$1"
  local dir_size
  if [[ "$#" -gt 1 ]]; then 
    dir_size="$(du -h "$dir" --exclude="$2" --max-depth=0 | head -n 1 | cut -f1)B"
  else # do not ingore any subdirs
    dir_size="$(du -h "$dir" --max-depth=0 | head -n 1 | cut -f1)B"
  fi
  echo "$dir_size"
}

### Reads packages.list and installs critical packages
read_packages () {
file="$HOME/c/bash/var/packages.list"
package_count=0

  while IFS= read -r line; do
   if [[ "$package_count" -eq 0 ]]; then ((package_count++)); continue; fi # Skip item 0
   
    IFS=":" read -ra parts <<< "$line" ## Split the file seperated by ":"
    
    [[ "${parts[0]}" =~ '"' ]] && package="$(echo ${parts[0]} | cut -d'"' -f2)" || package="${parts[0]}"
    package_name=$(echo "$package" | cut -d'"' -f1)

    [[ "${parts[2]}" == "1"  ]] && terminal="true" || terminal="false"
    installed=$(has_package "$package_name") ## True | False
    echo "     *${parts[0]} --isInstalled:$installed --isRequired:${parts[1]} --isTerminalCapable:${terminal}" 

    ((package_count++))
  done < $file
}

read_and_install_packages () {
  file="$HOME/c/bash/var/packages.list"
  package_count=0

  while IFS= read -r line; do
    if [[ "$package_count" -eq 0 ]]; then ((package_count++)); continue; fi # Skip item 0
   
    IFS=":" read -ra parts <<< "$line" ## Split the file seperated by ":"

    [[ "${parts[0]}" =~ '"' ]] && package="$(echo ${parts[0]} | cut -d'"' -f2)" || package="${parts[0]}"
    package_name=$(echo "$package" | cut -d'"' -f1)

    [[ "${parts[2]}" == "1"  ]] && terminal="true" || terminal="false"

    installed=$(has_package "$(echo ${parts[0]} | cut -d'"' -f1)")
    if [[ ! "$installed" == true && "${parts[1]}" == 1 ]]; then
      echo "Installing package $package.."
      [[ "${parts[1]}" == "1" ]] && sudo apt install "$package" -y
    fi

    if [[ $terminal == true && "$installed" == "true" ]]; then
     export AVAILABLE_TERMINALS="${AVAILABLE_TERMINALS}$(echo -e "${BLUE}/$package${NORMAL}") "  
    fi     
  
  done < $file
}

### Check sys has package
has_package () { 
 dpkg -l | grep -q "^ii  $1 " && echo true || echo false; 
}


#Find and nano file3
fan_file () {
 find . -name $1 -exec nano {} \; -quit
}

read_line () {
  LINE_NO=$1
  FILE="$2"
  i=0
  while read line; do
    i=$(( i + 1 ))
    test $i = $LINE_NO && echo "$line";
  done <"$FILE"
}
export -f read_line

replace_line () {
 "$HOME/c/bash/scripts/replace_line.sh" "$1" "$2" "$3"
}


list_dir () {
  local dir="$1"
    # Run the ls command in the specified directory and capture the output in a variable
    output=$(ls "$dir")
    # Convert the output into an array with elements separated by spaces
    files=($output)
    # Print the array
    echo "${files[@]}"
}




###>>#####   Speech   ###<<#####

trysay () {
  if [[ "$#" -lt 1 ]]; then echo "Please Provide arguments" && say "Please Provide arguments" && return 0
  else 
    say "$@"
  fi
}


###>>#####   Variable Formatting & Alteration   ###<<#####

DISPLAY_ALIASES () {
    sed -n '/## Aliases Begin/,/## Aliases End/{//!p;}' $(path_aliases)
}

###>>#####   Colours   ###<<#####
DISPLAY_ALL_TERMINAL_EDITS () { 
    local result
    for i in $(seq 1 107); do result+=$(echo -e "\x1B[${i}mitem:$i${NORMAL} "); done;
    echo $result
}
### BOOLEAN 

# Change Variable Values
  # flip_bool       /      edit inline (Change the file it exists in)
  # toggle_bool     /      soft change (Refresh terminal to reset)
    ## If $var not found and ! contains "_debugging", retry event w/ `$var"_debugging"``
flip_bool () {
  local var="$1"                                  # The boolean variable to flip
  local dir="$HOME/c/bash/"                       # The Directory to search  
  local file_to_edit=$(grep -rl "$var=" "$dir")   # The first file found to contain "$var="
  local bool="$2"                                 # Specify Bool to set as (Optional)

  if [ -n "$file_to_edit" ]; then                 # File in $dir has $var >> flipping >> true>false | false>true
    if [[ "$bool" == true || "$bool" == false ]]; then #Force Bool
      sed -i "s/$var=true/$var=$bool/" "$file_to_edit" && sed -i "s/$var=false/$var=$bool/" "$file_to_edit"
      dbg_log "$var:${!var}>$bool :> found in file $file_to_edit" "$write_debugging"
      return 0
    fi
    
    # true >> false
    grep -q "$var=true" "$file_to_edit" && sed -i "s/$var=true/$var=false/" "$file_to_edit" && dbg_log "true>>false" "$write_debugging" && return 0
    # false >> true
    grep -q "$var=false" "$file_to_edit" && sed -i "s/$var=false/$var=true/" "$file_to_edit" && dbg_log "false>>true" "$write_debugging" && return 0
    # Not a boolean
    dbg_log "Var: $var is not a boolean ${!var}" "$write_debugging"
  
  else  # Rerun search with "_debugging" appended to var (if not already) 
    [[ ! $var =~ "_debugging" ]] && (dbg_log "$var not found >> trying as '$var\_debugging' and retrying flip" true && flip_bool "${var}_debugging" "$bool") || dbg_log "Variable $var could not be found" "true"
  fi
}
toggle_bool () {
  local var_name="$1"
  [[ "${!var_name}" == true ]] && new_value=false || new_value=true 
  eval "$var_name=\"$new_value\""
}


# echo_debug_vars () {
#   local int=0
#   for i in "${debugging_vars[@]}"; do echo "$i:${LAST_DEBUGGING_STATE[int]} int$((int++))"; done
# }

# load_last_debugging_state () {
#     local var_count=0
#     for i in "${debugging_vars[@]}"; do flip_bool $i ${LAST_DEBUGGING_STATE[$var_count]} && ((var_count++)); done
#     flip_bool "DEBUG_STATE_MUTATED" false ## Unmutate    
# }

# flip_debug_vars () {
#     # If debugging state Unmodified (Defualt), -> Rewrite LAST_DEBUGGING_STATE
#     if [[ ! "$DEBUG_STATE_MUTATED" == true ]]; then
#         tmp_debug_state=$(for i in "${debugging_vars[@]}"; do echo -n "${!i} "; done) 
#         new_debug_state=$(echo "$tmp_debug_state" | sed -e 's/[[:space:]]*$//')
#         rewrite_var LAST_DEBUGGING_STATE "($new_debug_state)"    
#         flip_bool "DEBUG_STATE_MUTATED" true # MUTATE
#     fi
#     for i in "${debugging_vars[@]}"; do flip_bool "$i" $1; done 
# }


###>>#####  String Alteration   ###<<#####

to_uppercase () {
  echo "$@" | tr '[:lower:]' '[:upper:]'
}

to_lowercase () {
    echo "$@" | tr '[:upper:]' '[:lower:]'
}

rtr_count () { # return string count
  echo "${#1}"
}

rtr_strlen_as () { # return $2 for $1.len
new_str=$(printf '%*s' "${#1}" | tr ' ' "$2")
echo "$new_str"
} 

for_int_rtr () { # rtr intd x for y
  local result=""
 for i in $(seq 1 "$1"); do
   echo ""
 done
}

reverse_str () { # returns 'xyz' as 'zyx'
  echo "$1"|rev
}


###  QUOTED ITEMS 

remove_quotes () { # return " x 'y' \"z\" a" -> x y z a
  echo "$1" | awk "{ gsub(/[\'\"]/, \"\"); print }"
}

extract_quotes () { # return " x 'y' z 'a' " -> y \n a
 [[ "$1" == *\"* ]] && echo "$1" | grep -o '"[^"]*"'  | tr -d '"' && return 0
 [[ "$1" == *\'* ]] && echo "$1" | grep -o "'[^']*'"  | tr -d "'" && return 0
}

###  NEW LINES

remove_newlines () {
  echo -n "$@" | tr '\n' ' '
}

replace_newlines () {
  local key="$1" && shift
  echo -e "$@" | tr '\n' "$key"
}

### TODOS
build_todo () {
  local file="$(path_todo)"
  # Diff between last todo date and todays_date
  local dif=$(date_difference -d "$(read_line 2 $file)")
  # Update todos if dif >= 1 
  [ $dif -lt 1 ] && return 1 || dbg_log "Updating Todos" "$todo_debugging"
  # Replace date (line1)
  replace_line 1 $file $todays_date
  # Replace the final num on each line -> tmp file 
  awk -v dif="$dif" 'NR == 1 {print; next} {for (i=1; i<=NF; i++) {if ($i ~ /^[0-9]+$/) {if ($i <= dif) $i = "!!"; else $i = $i - dif}}; print}' "$file" > "$file.tmp" 
  mv "$file.tmp" "$file" ## Rewrite File
}

read_todo () {
  local file="$(path_todo)"
  log "|| $(echo -e "${UNDERLINE}${BLINK}TODO list: ${NORMAL}")"
  while IFS= read -r line; do
    [[ $line == -* ]] && log " $line"
  done < "$file"
}
