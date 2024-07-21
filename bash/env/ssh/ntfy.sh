#!/bin/bash
# Push notif >> Mobile

# Minimum time that must be between nfty calls
ntfy_time_between=""

ntfy () {
  curl \
    -H "Title: Bloodweb - Rsync" \
    -H "Priority: min" \
    -H "Tags: computer,heavy_check_mark" \
    -sd "$@" \
    ntfy.sh/BloodWeb > /dev/null
}

# nfty "Message" "Title" "Priority"
  #  title = 'BloodBash' + '- $2'
  #  priorirty = 'min' | '$3'
  #   -sd && > /dev/null supresses terminal output
nfty () {
  # Variable_chain: ## message > title > priority > tags
  local message="$1" && local title="BloodBash${2:+ - $2}" && local priority="${3:-min}"  
  
  #echo "Debugging (nfty): $br Title=$title message=$message priority=$priority" && return 1
  curl \
  -H "Title: $title" \
  -H "Priority: $priority" \
  -H "Tags: computer,heavy_check_mark" \
  -sd "$message" \
  ntfy.sh/BloodWeb > /dev/null

}
