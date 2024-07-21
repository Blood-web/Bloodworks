#!/bin/bash

##########################   META BEGIN  ########################### 

#___  Author   :  Bloodweb.net          _____________#
#___  fileName :  $HOME/c/ssh/ssh.sh            ____________#
#___  helpFile :  $this_dir/README.md                       __________#  
#___  About    :  Builds ssh and staging functions        >>   -#
             # :: #ext-desc# --#

#___  Imports :   (Keys from other locations)
        #  * ./env.sh ( $HOME , $SSH_ENV )
        #  *

#___  Commons :   (Keys created via - this file)
        #  *  ssh_sync_log       = runs dbg_log obfs using $ssh_log as a parameter
        #  *  all_ssh_Akeys      = # letters
        #  *  ssh_Akeys          = # letters !this location
        #  *  all_ssh_addrs      = # name@ip
        #  *  ssh_addrs          = # name@ip !this location

#___  Debugging:
        #  * ssh_log

#___  Notes :
        # To set up passwordless ssh:
         #  ssh-keygen (generate RSA on new devices) 
         #  ssh-copy-id $ssh  (do this both ways for passwordless ssh)

###########################   META END   ########################### 

ssh_log () {
  dbg_log "$1" true #"$ssh_debugging"
}

#Ssh Locations
all_ssh_Akeys="" # letters
rsync_nodes="" # All Valid ssh addresses
ssh_nodes="" # All ssh Nodes
all_sockets=() # all devices with an apache page
RsyncExtended_nodes="M L" # Nodes subject to failure

declare -Agx BSSH_D=( # Jackewers prod & general development
  [host]="dev"
  [name]="bloodweb-dev"
  [ip]="192.168.1.117"
  [socket]="jackewers.com"
  [a_key]="D"
  [rsync]=true
)
declare -Agx BSSH_M=( # mobile
  [name]="bloodweb-mob"
  [ip]="192.168.1.127"
  [port]="8022"
  [a_key]="M"
  [skippable]=true
)
declare -Agx BSSH_P=( # Bloodweb production
  [host]="dep"
  [name]="bloodweb"
  [ip]="192.168.1.107"
  [ip2]="122.148.245.193" #Glob
  [socket]="bloodweb.net"
  [a_key]="P"
  [rsync]=true
)

# declare -Agx BSSH_O=( # Expirmental - test here
#   [name]="octo-pi"
#   [ip]="192.168.1.177"
#   [a_key]="O"
# )

declare -Agx BSSH_L=( # Laptop #1 - only valid @home.net
  [host]="lap"
  [name]="bloodweb-lp"
  [ip]="192.168.1.137"
  [a_key]="L"
  [rsync]=true
)

propogate () { # Syncs all ssh clients (! mob)
  for i in $rsync_nodes; do
    [[ "$i" =~ "$SSH_ENV" ]] && echo "Cannot self_propogate -> Skipping $i" && continue
    stage "to" "$i" # Stage to node
  done
}

stage () {
  [[ $# -lt 2 ]] && propogate && return 1
  local location="$2"
  
  [[ "$1" == "to" || "$1" == "push" ]] && rsync -av --delete --exclude-from="/home/$USER/c/var/exclude/rsync.txt" ~/c/ "$location":~/c/  
  [[ "$1" == "fm" || "$1" == "pull" ]] && rsync -av --delete --exclude-from="/home/$USER/c/var/exclude/rsync.txt" "$location":~/c/ ~/c/       
  write_targeted_rsync "${SSH_ENV%%@*}:_${1}_:${location%%@*}"
}

###############################################
##################   Main   ###################
###############################################

main () {
  declare -n SSH_
  for SSH_ in ${!BSSH_@}; do
    a_key="${SSH_[a_key]}" && SSH_[key]="ssh_${SSH_[a_key]}" # Set ssh_[a_key]*
    
    # set default port 
    [ ! -n "${SSH_[port]}" ] && SSH_[port]=22
    
    # Set the SSH address
    SSH_[ssh]="${SSH_[name]}@${SSH_[ip]}"
    # Alpha Connect keys
    all_ssh_Akeys+=" $a_key"
    
    # Handle SSH Nndes
    [[ "$ssh_nodes" =~ "$a_key" ]] && ssh_nodes=${ssh_nodes//"$a_key"/"${SSH_[ssh]}"} || ssh_nodes+="${SSH_[ssh]} " 
    # Add items to Rsync Nodes
    # Attempt to establish an SSH connection
    if [[ "$SSH_ENV" =~ "" && "${SSH_[rsync]}" == true ]]; then
      if ssh -o BatchMode=yes -o ConnectTimeout=1 "${SSH_[ssh]}" exit &> /dev/null; then
        echo "SSH connection to ${SSH_[ssh]} on is possible."
        rsync_nodes+="${SSH_[ssh]} "
      else
        echo "SSH connection to ${SSH_[ssh]} on failed."
      fi
    
    fi
    # Device has apache connection
    [ -n "${SSH_[socket]}" ] && all_sockets+="${SSH_[ssh]}:${SSH_[socket]} "


    # Reserve $aKey
    alias "${a_key}"="echo ${SSH_[ssh]}"
    # Function declaration  # quick ssh // can pass commands
    alias "ssh_${SSH_[a_key]}"="ssh ${SSH_[ssh]} $@"

    reserve_keywords "SSH:$a_key_${SSH_[ssh]}"
    # Handles logging    
    log_str="SSH:$a_key-key_set = ${SSH_[ssh]}" && ssh_log "$log_str" 
  done
}


###############################################
#################    EOF     ##################
###############################################

# Do not edit past this point
main "$@"
#^ calls main and passes all args


