#!/bin/bash
# This file sources all other bash files when .config is sourced 

##   Inserted early for keyFunctions usage
source ~/c/bash/scripts/keyFunctions.sh
##   Inserted early for Below functions usage
source ~/c/bash/env/file_index
##   Inserted early for keys usage
source ~/c/bash/var/keys.sh
##   Inserted early for break_point usage
source ~/c/bash/dbg/debug.sh 


###################################### # ## MAIN ## # ######################################
# Perform Mutations on file indexes
main () {
declare -n b
for b in ${!MF_@}; do
 a="${b[name]}" && z="${b[key]}" && l="${b[loc]}" && d="${b[desc]}" && h="${b[help]}"
 b[src]="${l}${a}" # writes short src Assumes ($home)/c 
 b[path]="$HOME/c/${l}${a}" # writes abs root to location 
 src="${b[path]}" 

reserve_keywords "file:$z" && reserve_keywords "folder:$l" # Ensure keywords don't conflict

# alias "${z}_help"="echo ${h}" #$d"  # Display help
 alias "nano_$z"="nano $src" # quick nano file
 alias "bano_$z"="nano +9999 $src" # nano EOF 
 alias "cat_$z"="cat $src" # show file contents 
 alias "goto_$z"="cd $HOME/c/${l}" # jump to containing folder
 alias "path_$z"="echo $src" 
# alias "append_to_$z"="$1 >> $src" write to EOF
done
}

main $a


## Ghetto sourcing order based on (Priority->Alphabet)
### ( Is the best that could be done for now, for session sourcing)
source_array=()
# Create an indexed array to hold the names of associative arrays
name_array=()
# Function to source associative arrays by priority
source_associative_arrays_by_priority() {

  local priority="$1"
  for assoc_array_name in "${name_array[@]}"; do
    source_priority="${assoc_array_name}[Source_Priority]"
    if [[ "${!source_priority}" -eq "$priority" ]]; then
      # Build the reference
      src_loc="${assoc_array_name}[loc]" && src_name="${assoc_array_name}[name]"
      src_path="$HOME/c/${!src_loc}${!src_name}"
      # Source the file and add the file to source_array
      source "${src_path}" && source_array+=("${!src_name}:${!source_priority}") 
      echo "${GREEN}File sourced${NORMAL} :${!src_name}\n" >> $TMP_LOG_FILE
      # Debug
        #[[ "$LOG_FILE_SOURCING_SUCCESS" == true ]] && 
    fi
  done
}

# Loop through associative arrays and add their names to name_array
for arr in ${!MF_@}; do
  if [[ $arr =~ ^MF_ ]]; then
    source_priority="${arr}[Source_Priority]"
    if [[ "${!source_priority}" -gt 0 && ${!source_priority} -lt $((SOURCE_PRIORITY + 1)) ]]; then 
      name_array+=("$arr") 
    fi
  fi
done

# Get unique priorities
unique_priorities=($(for assoc_array_name in "${name_array[@]}"; do
  source_priority="${assoc_array_name}[Source_Priority]"
  echo "${!source_priority}"
done | sort -u))

# Source associative arrays by priority
for priority in "${unique_priorities[@]}"; do
  source_associative_arrays_by_priority "$priority"
done 

if [[ "$LOG_FILE_SOURCING_ORDER" == true ]]; then echo "debug.sh:0 keyFunctions.sh:0 keys.sh:0 ${source_array[*]}"; fi