#!/bin/bash
# Pass file name

# stream edit > -i (edit the file in place, rather than printing changes)
    # open/close pattern / /
    # ^ Anchor pattern to line begin
    # $ Anchor pattern to line end
    # d delete

remove_newlines () {
    local filename="$1"
    sed -i '/^$/d' "$filename"
}

# Specific Use file edits


rewrite_var () { 

  local var="$1"                                           # The variable to rewrite
  local file_to_edit=$(grep -rl "$var=" "$HOME/c/bash/")   # The first file found to contain "$var="
  local val_to_write="$2"                                  # Specify Bool to set as (Optional)

  if [ -n "$file_to_edit" ]; then                 # File in $dir has $var >> flipping >> true>false | false>true
    sed -i "/$var=/c\\${var}=${val_to_write}"  "$file_to_edit" && dbg_log "Var found and rewritten successfully ${var}${!var}" "$write_debugging"
  fi
  
}


build_keywords () {
  keys="$(cat "$HOME"/c/var/keywords/Words.txt)"
  local build
  local extension="$1"

  build_wordlist () { # GET THE LIST
    local insert # Output
    local keycount=1 # Total Keys
    local word_break=5 # Words per line 
    for i in $keys; do
      [[ "$keycount" == 1 ]] && insert+=$'\x0a    '"'$i'" && ((keycount++)) && continue
      (( keycount % word_break == 1 )) && insert+=$'\x0a    '",'$i'" || insert+=", '$i'"
      ((keycount++)) 
    done
    echo "$insert"
  }

  case "$extension" in 
    "" | "js" | "JS")
      build="window.Key_Words_Array=["$(build_wordlist)$'\x0a];'
    ;;
    *)
      build="["$(build_wordlist)$'\x0a]'
    ;;
  esac
  
  echo "$build"
}

write_keys_to () {
  local file="$1"
  if [[ "$#" == 1 ]]; then
    local extension=$(basename "$file" | cut -d'.' -f2)
    build_keywords "$extension" > "$file"
  elif [[ "$#" -gt 1 ]]; then
    shift # Remove $1(Output-file)  
    build_keywords "$@" > "$file"
  fi
}

# Appends custom code to bash.bashrc
write_env_to_rc () {

   dbg_log ".env not in ~/.bashrc " true  
   echo -e "\n# BloodWeb Custom Sourcing\nsource $(path_env)\n# BloodWeb Custom Sourcing " >> "$RC_LOCATION"
   dbg_log "env successfully appended to ~/.bashrc" true

} 