#m##########################x##############
################ FILE BEGIN ################
############################################
# File name = STAGE/Scripts/cripts.sh
# True path = /data/data/com.termux/files/home/STAGE/Scripts/scripts.sh

# Automatically sourced on termux session via $HOME + STAGE/Scripts/Enviroment.sh
# Sources  Adfitiinal programs :
#   [ (Quick-Edits),  Rocogo, Illidia, ]
############################
############################################
###         :: COMMONS ::               ###
# 
###          :: COMMONS - END ::         ###
############################################


############################################
################ META END ##################
############################################

# Program declarati8n standard.:

#declare -A Prog_Example(
#    [name]='example'
#    [file_name]='Example.sh'
#    [ssh_loc]="$env_M" (OG most likely found here)
#    [location]="c:/parent/"
#    [sourceable]=true|false
#    [desc]="A brief Description of the program (255) characters"
#    [comp_desc]="A comprehensive Description Including flags and shorthands"
#    [key]="Best func call that wont interfere with other native bash funcs ie..Intern//intern"
#    [func]="//do this"
#)

# end standard
debuging=true
list_programs=false
totalprogramcounter=0

declare -Agx Prog_Enviroment=(
    [name]='Enviroment'
    [call_key]="env_edit"
    [file_name]='Enviroment.sh'
    [location]="env/"
    [sourceable]=false
    [ssh_loc]="$env_M"
    [desc]="A linux Enviromemt tool"
    [comp_desc]=" A quick and easy resource for finding and executing exisiting functions"
    [func]="nano +120 ${S_L}env/Enviroment.sh"
)
declare -A Prog_Intern=(
    [name]='Intern'    
    [call_key]="intern"
    [file_name]='Scripts.sh'
    [location]="Scripts/"
    [sourceable]=false
    [ssh_loc]="$env_M"
    [desc]="a comprehension utility for all programs"
    [comp_desc]=" A quick and easy resource for finding and executing exisiting functions"
    [func]="intern_input"
)

declare -A Prog_QuickEdits=(
    [name]='QuickEdits'
    [call_key]="bb_qe"
    [file_name]='Scripts.sh'
    [ssh_loc]="$env_M"
    [location]="Scripts/"
    [sourceable]=false
    [desc]="Allows for quick access to referenced files"
    [func]="BloodWeb_quickedits"
)
declare -A Prog_Rocogo=(
    [name]='Rocogo'
    [call_key]="roco"
    [file_name]='Rocogo.sh'
    [location]="Scripts/Programs/"
    [ssh_loc]="$env_M"
    [sourceable]=true
    [desc]="Allows for quick management of files"
    [func]="echo 'rrp'"
)

set_programa () {
declare -n Prog_
for Prog_ in ${!Prog_@}; do
  Prog_[id]="$totalprogramcounter"
  Prog_[ref]="${Prog_[location]}""${Prog_[file_name]}"
  alias "${Prog_[call_key]}"="${Prog_[func]}"
  
  [[ "$list_programs" == true ]] && display_program_info "Prog_${Prog_[name]}"
  if [[ "${Prog_[sourceable]}" == true ]]
    then
      source $HOME"${Prog_[ref]}" && dbg_log "$pad Sourced: Sucessfully" "$list_programs"
  fi

  totalprogramcounter=$((totalprogramcounter+1)) #inc loop
done
}


display_program_info () {
  local -n e="$1" # local name ref
    echo "$pad   _______<<<_____>>>_______"
    echo "$pad   Name: ${e[name]}"
    echo "$pad   Id: ${e[id]}"
    echo "$pad   File Ref: ${e[ref]}"
    echo "$pad   sourcable: ${e[sourceable]} "
}

list_programa () (
declare -n Prog_
dbg_log " * Listing Available Programa *"
for Prog_ in ${!Prog_@}; do  
  progName="Prog_${Prog_[name]}"
  display_program_info "$progName" 
done
log "   _______<<<_Total Programs: $totalprogramcounter ____>>>_______"
)

set_programa

alias timer='export ts=$(date +%s);p='\''$(date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S")'\'';watch -n 1 -t echo $p;eval "echo $p"' 

intern_input () (
 log "  * Intern Active *  "
 location=""
 final_call=""
 echo "$br  Which Tools to use?"
 read -p " -1:Rocogo (File-passing):,$br -2:Illida (Image Management),$br -3:Quick-Edits,$br -4:Help (runs BW_bashscript_help)$brPlease enter a number(1-4)$brYour Response : " intern_response
 #Rocogo File Management
 [ "$intern_response" == "1" ] && BloodWeb_rocogo
# Illidia Image Editing
 [ "$intern_response" == "2" ] && illidia
#Quick Edits - Env, Functions, Intern 
 [ "$intern_response" == "3" ] && BloodWeb_quickedits
)

illidia () {
 log "Illidia - Starting"
}

BloodWeb_quickedits () {
 log "Quick -Edits"
 read -p " 1:Enviroment (Enviroment.sh)),$br 2:Functions (Scripts.sh),$br 3:Programs (Rocogo,Illidia), $br Your Response : " target
#Enviroment
[ "$target" == "1" ] && nano $HOME$e_enviroment
#Scripts.sh
[ "$target" == "2" ] && nano $HOME$e_bashscripts
#Intern #Rocogo #Illidia #
[ "$target" == "3" ] && read -P "Select Program [ 1:Rocogo, 2:Illidia, ] : " prog_edit_targ
[ "$prog_edit_targ" == "1"] && nano $HOME$e_rocogo
[ "$prog_edit_targ" == "2"] && nano $home_dir$e_rocogo
#Quick-Edits
[ "$target" == "4" ] && nano $home_dir$e_quickedits
}

BW_help () {
  log "  *** ₿loodWeb -B.A.S.H_Commands --Begin ***"
  SingleKey_help
  log $'  A comprehensive list of Custom BloodWeb functions and aliases'
  log $'  cls == clear\x0atimer == 00.00.00 stopwatch'
  log $'  Staging - (r,m,x,goto)_Stage ==\x0a  r[show all in st] \x0a  m[move passed file argument to stage($1)] '
  log $'\x0a\x0a  *** BlooWeb -B.A.S.H_Commands --End  ***\x0a'
}

log "** Scripts.sh Succesfully included in this terminal ** $br //BW_help for more information"


############################################
################  EOF   ##################
############################################


