#!/bin/bash
# Reserve Keywords made via this file
reserved_time_keys="cur_date todays_date todays_day todays_int test_dates_str test_dates_arr random_dd random_mm"
for i in $reserved_time_keys; do reserve_keywords "time:$i"; done


cur_date="date"

todays_date=$(date '+%Y-%m-%d') # 'YYYY-MM-DD'
todays_day="$(date '+%A')" # 'Monday'
todays_int="$(date '+%u')" #  1  (1-7)
todays_seconds=$(date +%s) # 16993993 

todays_dd=$(date '+%d')
todays_mm=$(date '+%m')

random_dd=$((1 + RANDOM % 31))
random_mm=$((1 + RANDOM % 12))

test_dates_str="25-08-2023 26-08-2023 29-08-2023 30-08-2023 31-08-2023"
test_dates_arr=("2003-08-21" "2020-04-01" "2020-03-26")

find_date () {
  local operator=">" # Assumes returned date should be latest 
  [[ "$1" == "-o" ]] && operator="<" && shift # shift out -o before getting dates
  [[ "$1" == "-l" ]] && operator=">" && shift # -l is not required
  local dates=("$@") && local return_date="${dates[0]}"

  for i in "${dates[@]}"; do #replace latest_date if condition met
    [[ "$operator" == ">" && "$i" > "$return_date" ]] && return_date="$i" || continue
    [[ "$operator" == "<" && "$i" < "$return_date" ]] && return_date="$i" || continue
  done

  echo "$return_date"
}


alias TZ_AWST="TZ=Australia/Perth date"
alias TZ_AEST="TZ=Australia/Sydney date"
alias TZ_GMT="TZ=United_Kingdom date"

all_TimeZones=("Australia/Perth" "Australia/Sydney" "United_Kingdom/England" "Asia/Tokyo" "Canada/Central" "Europe/Germany")

#break_point "Time - Date midway"

# Prints all_Timezones and relative time,,
PTZ () {
  echo "The Time in $1 is : "$(TZ=$1 date)
}

print_allTimeZones () {
  for i in "${all_timeZones[@]}"
  do
    PTZ "$i"
  done
}

date_difference () {
  local current_date
  
  if [ ! -z "$3" ]; then 
   current_date=$(date -d "$2" +%s) && shift 2  
  else
    current_date=$(date +%s)    
  fi

  local result

  for arg in "$@"; do
    case "$arg" in 
      -s) # Seconds
        result=$((current_date - $(date -d "$2" +%s)))
      break
      ;;
      -m) # Minutes
         result=$(calc $((current_date - $(date -d "$2" +%s))) / 60)        
      break
      ;;
      -h | -H) # Hours
         result=$(calc $((current_date - $(date -d "$2" +%s))) / 60 / 60 )        
      break
      ;;
      -d) # Days
        result=$(( (current_date - $(date -d "$2" +%s)) / 86400 )) 
      break
      ;;  
      -w) # Weeks
        result=$(calc $((current_date - $(date -d "$2" +%s))) / 60 / 60 / 24 / 7) 
      break
      ;;  
      -y | -Y) # Years
        result=$(calc $((current_date - $(date -d "$2" +%s))) / 60 / 60 / 24 / 365) 
      break
      ;;    
      *) # Default Seconds
        result=$((current_date - $(date -d "$1" +%s))) 
      break
      ;;  
    esac
  done
  echo "$result" 
}
