stage_files () (
#(Rcg)Stage
read -p "$brWhich Rocogo Action?:$br 1:Push Stage,$br 2:Pull stage,$br 3:Fill Stage (file),$br 4:Backup Stage,$br 5:View Stage (Dir), Your Response :" stage_resp
 [ "$stage_resp" == "1" ] && push_stage
 [ "$stage_resp" == "2" ] && pull_stage
 [ "$stage_resp" == "3" ] && fill_stage
 [ "$stage_resp" == "4" ] && backup_stage
 [ "$stage_resp" == "5" ] && view_stage
)


BloodWeb_rocogo () (
 log "Rocogo - Starting"

 read -p " :Rocogo Utilities:$br 1:Quick-Edits$br 2:Staging Area,$br 3:Specific File,$br Please enter a number(1-3) or file url$br Your Response :" rocogo_resp

# Quick-Edit
##  : [ Single File Nano ]
[ "$rocogo_resp" == "1" ] && BloodWeb_quickedits
# Staging
##  : [ Base Prep ]
[ "$rocogo_resp" == "2" ] && stage_files
)


view_stage () {
 tree $L_S
}
backup_stage () {
 log " Backing UP scripts "
 cp -fRv $HOME$e_scripts $HOME$e_backup
}

move_stage () (
  read -p $'Push Or Pull? (1/2) : ' P_P
 log "Which location?"
 read -p $' 1: (P) Production/Deployment,\x0a 2: (D) Local Development,\x0a 3: (V) Expirimemtal Devlopment,\x0aPlease enter a number (1-3) or a letter' pass_response
 #Deployment
 [ "$pass_response" == "1" ] && location="$env_P"
 #Development
 [ "$pass_response" == "2" ] && location="$env_D"
 #Novo
 [ "$pass_response" == "3" ] && location="$env_V"
)
push_stage () {
  scp -R "$home_dir"push/* "$location:~/c/STAGE/pull"
}
pull_stage () {
  log "Passing Item:$homedir$scope to $location"
}
 [ "$P_P" == "1" ] && push_stage && log "Stage Pushed to $location"
 [ "$P_P" == "2" ] && pull_stage && log "Stage Pulled from $location"

fill_stage () {
  [ "$item_to_pass" == "3" ] && read -p $'File: '
}

