#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                Todo List Script                            ║
# ║                                                                            ║
# ║ This script manages a simple to-do list with support for recurring tasks,  ║
# ║ archiving completed tasks, and displaying tasks in a formatted manner.     ║
# ║                                                                            ║
# ║ Features:                                                                  ║
# ║ - Add, delete, and list to-do items                                        ║
# ║ - Handle recurring tasks                                                   ║
# ║ - Archive completed tasks                                                  ║
# ║ - Display tasks with optional color formatting                             ║
# ║                                                                            ║
# ║ Dependencies:                                                              ║
# ║ - BloodBash(Aliases.sh): For adding the color to output                    ║
# ║ - figlet: for displaying the title in a stylized font                      ║
# ║ - lolcat: for adding color to the title                                    ║
# ║                                                                            ║
# ║ Potential Issues:                                                          ║
# ║ - Ensure figlet and lolcat are installed and available in the PATH         ║
# ║ - Proper handling of special characters in to-do items                     ║
# ║ - File permissions for reading/writing to the to-do files                  ║
# ║                                                                            ║
# ║ Usage:                                                                     ║
# ║ - Running the Script:                                                      ║
# ║   ./this_file.sh <arguments>                                               ║
# ║   tasklist|t <arguments>  (BloodBash)                                      ║
# ║                                                                            ║
# ║ - Interactive Mode:                                                        ║
# ║   Run the script without any arguments to enter interactive mode. Follow   ║
# ║   the prompts to manage your to-do list.                                   ║
# ║                                                                            ║
# ║ - Command-Line Arguments:                                                  ║
# ║   You can run specific parts of the script using the following arguments:  ║
# ║                                                                            ║
# ║   - View Task List:                                                        ║
# ║     ./set_task.sh -view                                                    ║
# ║     ./set_task.sh -v                                                       ║
# ║                                                                            ║
# ║   - Delete Task:                                                           ║
# ║     ./set_task.sh -delete <line_number>optional                            ║
# ║     ./set_task.sh -d <line_number>optional                                 ║
# ║                                                                            ║
# ║   - Generate Report:                                                       ║
# ║     ./set_task.sh -report                                                  ║
# ║     ./set_task.sh -r                                                       ║
# ║                                                                            ║
# ║ - Customization:                                                           ║
# ║   Modify the script to customize file paths and settings as needed.        ║
# ║                                                                            ║
# ║ Sections:                                                                  ║
# ║ - File Paths: Defines paths for to-do, recurring, and archive files        ║
# ║ - Settings: Configurable settings such as date format and task limit       ║
# ║ - Functions: Contains functions for managing to-do items                   ║
# ║ - Initialize Files: Ensures necessary files are created if not found       ║
# ║ - Command Line Arguments: Handles command-line arguments                   ║
# ║ - Menu Options / Functions: Advanced options for viewing, sorting, and more║
# ║ - Main Script: The main logic for interacting with the user                ║
# ╚════════════════════════════════════════════════════════════════════════════╝


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                                File Paths                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Get the path of the script and usd it to define the file paths (for portability) [ last_location: /$HOME/c/scripts/tasklist ]
THIS_PATH=$(dirname "$(realpath "$0")")
THIS_FILE=$THIS_PATH/set_task.sh
TASK_FILE="$THIS_PATH/task_list.txt"
RECURRING_FILE="$THIS_PATH/recurring_tasks.txt"
ARCHIVE_FILE="$THIS_PATH/deleted_tasks.txt"
BACKUP_DIR="$HOME/c/backup/tasklist"

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                                 Settings                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

DATE_FORMAT="%Y-%m-%d"
# Limit task display on initial view (doesn't affect view calls)
TASK_SOFT_LIMIT=10
# Abosulute max tasks to display at once (affects all calls except SHOW ALL)
TASK_HARD_LIMIT=25
# Enable or disable debug mode
DEBUG_MODE=false 
# Enable or disable color output    
STRIP_COLORS=false
# Enable or disable notifications for overdue tasks
ENABLE_NOTIFICATIONS=true
# Backup settings
BACKUP_ENABLED=true
BACKUP_DIR="$HOME/task_backups"
BACKUP_INTERVAL_DAYS=7


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                         Category Mapping                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Array keys for categories (first element is the alpha)
this_keys=("this" "thisfile" "this_file" "this_file.sh" "set_task" "set_task.sh" "tasklist" "tasklist.sh") 
# BoodWeb.net || BloodBash
blood_keys=("blood" "Blood" "bloodweb" "Bloodweb" "bloodweb.net" "Bloodweb.net" "bloodbash" "Bloodbash")
# Jackewers,com
jack_keys=("jackewers.com" "jack" "Jack" "jackewers" "Jackewers" "Jackewers.com")
# Miscellanious Coding
code_keys=("code" "program" "coding" "programming" "development" "dev")
# 3D Printing
design_keys=("design" "3d" "3dprinting" "3dprint" "3dprinters" "3dprinter" "printing" "printers" "printer" "vinyl" "vinylcutting" "vinylcutter" "vinylcutters" "cricut")
# Shopping
shopping_keys=("shopping" "Shopping" "groceries" "*shopping")
# Work / Office specific tasks
work_keys=("work" "office" "job" "career")
# Any personal things, Appointments, Health ..ect
personal_keys=("personal" "private" "self" "individual")
# Miscellanious tasks
misc_keys=("misc" "miscellaneous" "other" "various" "general")

# Define categorymap associative array
declare -A categorymap
categorymap=(
    ["this"]=${YELLOW}${UNDERLINE}
    ["jackewers.com"]=${CYAN}
    ["blood"]=${MAGENTA}
    ["code"]=${GREEN}
    ["recurring"]=${GREEN_BG}
    ["design"]=${RED}
    ["shopping"]=${YELLOW}
    ["work"]=${ORANGE}
    ["personal"]=${BLUE}
    ["misc"]=${GRAY}
)

# Function to validate and get the primary category
get_primary_category() {
    local category="$1"
    local keys_arrays # Get all arrays ending with _keys
    keys_arrays=$(compgen -A variable | grep '_keys$')
    
    for keys_array_name in $keys_arrays; do
        declare -n keys_array="$keys_array_name"
        for key in "${keys_array[@]}"; do
            if [[ "$category" == "$key" ]]; then
                echo "${keys_array_name%_keys}"
                return
            fi
        done
    done
    
    echo "misc"  # Default category if no match is found
}


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                  Main Functions (ADD,DELETE,LIST...)                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Generate the title with figlet and lolcat
draw_title() {
    TITLE="Todo List"
    figlet -f small "$TITLE" | lolcat
}
# Function to strip colors if COLOR_ENABLED is false
format_text() {
    local text="$1"
    local stripColor="$2"
    if [ "$STRIP_COLORS" = false ]; then echo -e "$text" && return
    else echo "$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')"
    fi
}
# This function should be exported to keyFunctions.sh
expand_range() {
    local range=$1
    local start=${range%-*}
    local end=${range#*-}
    seq $start $end
}


help() {
    echo """TMS - Task Management System
    Description: A simple to-do list manager with support for recurring tasks, archiving, and more.
    Usage: ./main.sh [option]
    Options:
       ARGS         Example                             ACTION
      -a, add       task days_to_complete category      Add a new to-do item
      -v, view      (ALL)                               View to-do items
      -d, delete    task1 task2 task4-8                 Delete a to-do item
      -r, report                                        Generate a report
      -s, sort                                          Sort to-do items
      -b, backup                                        Backup to-do items
      -h, help                                          Display this help message"""

}

# Increase the count for recurring tasks
increase_completions() {
    local task_text="$1"
    local recurring_file="$RECURRING_FILE"

    # Read the existing line for the task
    local line=$(grep -F "$task_text" "$recurring_file")

    if [ -n "$line" ]; then
        # Extract the current completions count
        local completions=$(echo "$line" | awk -F'|' '{print $4}')
        local days_to_complete=$(echo "$line" | awk -F'|' '{print $2}')
        local date_added=$(echo "$line" | awk -F'|' '{print $3}')

        # Increment the completions count
        local new_completions=$((completions + 1))

        # Update the line in the file with the new completions count
        sed -i "s#${task_text}|${days_to_complete}|${date_added}|${completions}#${task_text}|${days_to_complete}|${date_added}|${new_completions}#g" "$recurring_file"
    fi
}

calculate_days_left() {
    local date_added="$1"
    local days_to_complete="$2"
    # Get the current date
    local current_date=$(date +%Y-%m-%d)
    # Calculate days passed
    local days_passed=$(( ( $(date -d "$current_date" +%s) - $(date -d "$date_added" +%s) ) / 86400 ))
    # Calculate days left
    local days_left=$((days_to_complete - days_passed))
    # Return days left
    echo "$days_left"
}
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          Prompt Commands                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

prompt_user_to_add() {
    task=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Please provide a task to add: " bash -c 'read -e input; echo $input')
    if [ -z "$task" ]; then echo "No task provided.. Please enter a task or 'exit' to quit. :" && prompt_user_to_add && exit 1; fi
    days=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Days to complete: " bash -c 'read -e input; echo $input')
    category=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Category: " bash -c 'read -e input; echo $input')
    add_task "$task" "$days" "$category"
}

prompt_user_to_delete() {
    list_tasks "ALL"
    task_numbers=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the number(s) of the to-do to delete (e.g., 1 2 3):  " bash -c 'read -e input; echo $input')
    if [ -z "$task_numbers" ]; then echo "No numbers entered. Exiting." && return;  
    else
        delete_task "$task_numbers"
    fi
}



# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                  Main Functions (ADD,DELETE,LIST...)                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Function to add a to-do item
add_task() {
    if [ -z "$1" ] || [ "$1" == "" ]; then prompt_user_to_add && return; fi

    local task_text="$1"
    local days_to_complete="${2:-1}"
    local date_added=$(date +%Y-%m-%d)
    local category="${3:-misc}"
    local primary_category=$(get_primary_category "$category")
    local category_color=""

    if [ -z "$days_to_complete" ]; then days_to_complete=30; fi
    if [[ "$category" == "recurring" ]]; then
        echo "$task_text|$days_to_complete|$date_added|0" >> "$RECURRING_FILE"
        format_text "\n ${MAGENTA}Added Recurring Todo${WHITE}: ${BOLDER}$task_text${NORMAL} (Every $days_to_complete days, Date added: $date_added)"
        add_recurring_tasks
        return
    fi

    echo "$task_text|$days_to_complete|$date_added|$primary_category" >> "$TASK_FILE"
    format_text "\n ${MAGENTA}Added Todo${WHITE}: ${BOLDER}$task_text${NORMAL} category:${categorymap[$primary_category]}$primary_category${NORMAL} (Days to complete: ${GREEN}$days_to_complete${NORMAL} days, Date added: $date_added)"
}

edit_task() {
    local task_to_edit="$1"    # Task Number
    local field_to_edit="$2"   # Field to edit
    local new_value="$3"       # New value

    # Prompt for task if not provided
    if [ -z "$task_to_edit" ]; then list_tasks && task_to_edit=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Which task would you like to edit?  " bash -c 'read -e input; echo $input'); fi

    # Prompt for field to edit if not provided
    if [ -z "$field_to_edit" ]; then
        echo "Which field would you like to edit?"
        echo -e "1) Task \n2) Days to complete \n3) Category"
        field_choice=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the number corresponding to the field:  " bash -c 'read -e input; echo $input')
        case "$field_choice" in
            1|task) field_to_edit="task" ;;
            2|days) field_to_edit="days_to_complete" ;;
            3|category) field_to_edit="category" ;;
            *) echo "Invalid choice"; return 1 ;;
        esac
    fi

    # Prompt for new value if not provided
    if [ -z "$new_value" ]; then new_value=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the new value for $field_to_edit:  " bash -c 'read -e input; echo $input'); fi

    # Update the task
    case "$field_to_edit" in
        # Update the task description
        "task") sed -i "s/^$task_to_edit|.*$/$new_value|$(echo "$task_to_edit" | cut -d'|' -f2-)/" "$TASK_FILE";;
        # Update the days to complete
        "days_to_complete") sed -i "s/^\($task_to_edit|[^|]*|\)[^|]*\(.*\)$/$\1$new_value\2/" "$TASK_FILE";;
        # Update the category
        "category") sed -i "s/^\($task_to_edit|[^|]*|[^|]*|\)[^|]*\(.*\)$/$\1$new_value\2/" "$TASK_FILE";;
        *) echo "Invalid field to edit"; return 1 ;;
    esac

    echo "Task updated successfully."
}


# Function to delete a to-do item by its number
delete_task() {
    if [ ! -s "$TASK_FILE" ]; then echo "No to-do items found." && return; fi

    if [ -z "$1" ]; then 
        prompt_user_to_delete
    else
        task_numbers="$@"
    fi

    # Check if any argument contains 'p'
    delete_permanently=$( [[ "$@" == *p* ]] && echo true || echo false )

    # Remove any letters and dashes connected to letters
    clean_args=$(echo "$task_numbers" | awk '{gsub(/[a-zA-Z-]*[a-zA-Z]/, ""); print}')
    
    # Create an array to store the numbers
    task_numbers_array=()
    
    # Process each argument
    for arg in $clean_args; do
         # If the array contains a range, expand it. Otherwise, add the number to the array
        [[ "$arg" =~ ^[0-9]+-[0-9]+$ ]] && task_numbers_array+=($(expand_range "$arg")) || task_numbers_array+=("$arg")
    done
 
    # Sort numbers in descending order (to avoid shifting line numbers)
    sorted_numbers=($(for num in "${task_numbers_array[@]}"; do echo $num; done | sort -nr))

    # echo "Deleting to-do items: ${sorted_numbers[@]} deleted_permanently: $delete_permanently"
    # return

    # Loop through each number and delete the corresponding to-do item
    for num in "${sorted_numbers[@]}"; do
        # Catch invalid numbers and skip them
        if ! [[ "$num" =~ ^[0-9]+$ ]] || (( num < 1 || num > $(list_tasks | wc -l) )); then echo "Invalid number: $num. Skipping." && continue; fi
        
        local task_item=$(sed "${num}q;d" "$TASK_FILE")
        IFS='|' read -r task_text days_to_complete date_added category <<< "$task_item"

        # Handle case where no to-do text is found
        if [ -z "$task_text" ]; then echo "No task found at number $num. Skipping." && continue
        fi

        local today=$(date +%Y-%m-%d)
        local days_diff=$(( ( $(date -d "$today" +%s) - $(date -d "$date_added" +%s) ) / 86400 ))

        local completed_item="$task_text|completed in $days_diff days|Added on $date_added|Completed on $(date +%Y-%m-%d)"
        echo "$completed_item" >> "$ARCHIVE_FILE"
        sed -i "${num}d" "$TASK_FILE"
        
        format_text "${RED}Deleted${NORMAL} item $num: \"$task_text\" and ${BOLDER}tracked${NORMAL} in ${UNDERLINE}$ARCHIVE_FILE${NORMAL}."

        if [[ "$category" == "recurring" ]]; then
            # Permenantly delete the item if the 'p' flag is passed or increase completions 
            [[ "$delete_permenantly" == true ]] && delete_recurring_task "$task_text" || increase_completions "$task_text"
            # delete_recurring=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "This is a recurring item. Do you want to delete it from the recurring list? (y/n):  " bash -c 'read -e input; echo $input')
        fi
    done
}

add_recurring_tasks() {
    # Read the recurring to-dos file
    while IFS='|' read -r task_text days_to_complete last_added_date completions; do
        # Calculate the next due date
        next_due_date=$(date -d "$last_added_date + $days_to_complete days" +"$DATE_FORMAT")
        current_date=$(date +"$DATE_FORMAT")
         
    # Check if the to-do is due to be added again
    if ! grep -qF "$task_text" "$TASK_FILE"; then
    # If the next due date is in the past (or today), add the to-do item      
        if [[ "$current_date" > "$next_due_date" || "$current_date" == "$next_due_date" ]]; then
            format_text "${MAGENTA}${UNDERLINE}Regenerating task${NORMAL} : $task_text"
            echo "$task_text|$days_to_complete|$date_added|recurring" >> "$TASK_FILE"
            # Update the last added date
            sed -i "s#^\($task_text|$days_to_complete|\)[^|]*|\([0-9]*\)#\1$current_date|\2#g" "$RECURRING_FILE"            

        elif [[ "$completions" -eq 0 ]]; then
            format_text "${MAGENTA}Regenerating task${NORMAL} : $task_text"
            echo "$task_text|$days_to_complete|$date_added|recurring" >> "$TASK_FILE"
        fi
    fi
    done < "$RECURRING_FILE"
}

delete_recurring_task() {
    local task_text="$1"
    sed -i "/$task_text/d" "$RECURRING_FILE"
    format_text "Recurring to-do item \"$task_text\" ${RED}deleted${NORMAL}."
}


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                           Task Sorting                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Function to display sort options menu
display_sort_tasks() {
    format_text "\nSort options:"
    for i in "${!sort_options[@]}"; do
        IFS=' ' read -r -a option <<< "${sort_options[$i]}"
        format_text "$((i+1)). ${UNDERLINE}${option[1]}${NORMAL}"
    done

    sort_choice=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter your choice:  " bash -c 'read -e input; echo $input')
    if [[ "$sort_choice" =~ ^[0-9]+$ ]] && (( sort_choice > 0 && sort_choice <= ${#sort_options[@]} )); then
        IFS=' ' read -r -a option <<< "${sort_options[$((sort_choice-1))]}"
        ${option[0]}
    else
        echo "Invalid option. Please try again."
    fi
}

# Function to sort tasks
sort_tasks() {
    if [[ ! "$1" ]]; then
        display_sort_tasks
    else
        for i in "${!sort_options[@]}"; do
            IFS=' ' read -r -a option <<< "${sort_options[$i]}"
            if [[ "${option[0]}" == "$1" ]]; then
                ${option[0]}
                return
            fi
        done
        echo "Invalid sort option"
    fi
}

# Function to sort by days left - low
sort_by_days_left_low() {
    grep -v 'recurring' "$TASK_FILE" | sort -t '|' -k2,2n > /tmp/sorted_non_recurring.txt
    grep 'recurring' "$TASK_FILE" | sort -t '|' -k2,2n > /tmp/sorted_recurring.txt
    cat /tmp/sorted_non_recurring.txt /tmp/sorted_recurring.txt > "$TASK_FILE.tmp"
    mv "$TASK_FILE.tmp" "$TASK_FILE"
    echo "Sorted by days left - low"
}

# Function to sort by days left - high
sort_by_days_left_high() {
    awk -F '|' '
    {
        days_left = system("calculate_days_left " $3 " " $2)
        if ($4 ~ /recurring/) {
            print "0|" $0
        } else {
            print days_left "|" $0
        }
    }' "$TASK_FILE" | sort -t '|' -k1,1nr | cut -d '|' -f2- > "$TASK_FILE"
}

# Function to sort by category - alphabetical
sort_by_category() {
    sort -t '|' -k4 "$TASK_FILE" -o "$TASK_FILE"
}

# Function to sort tasks alphabetically
sort_alphabetically() {
    sort -t '|' -k1 "$TASK_FILE" -o "$TASK_FILE"
}

# Function to sort by date added
sort_by_date_added() {
    sort -t '|' -k3 "$TASK_FILE" -o "$TASK_FILE"
}

# Function to list all to-do items
list_tasks() {
    if [ ! -s "$TASK_FILE" ]; then echo "No to-do items found." && return; fi

    local total_tasks=$(wc -l < "$TASK_FILE")
    # Check if the user wants to view all tasks otherwise use the passed limit or the hard limit
    local limit
    if [[ "$1" == "ALL" ]]; then
        limit="$total_tasks"
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        limit="$1"
    else
        limit="$TASK_HARD_LIMIT"
    fi

    if [ "$total_tasks" -gt "$limit" ]; then format_text "Showing $limit of $total_tasks tasks. Use 'tasklist view ALL' or adjust TASK_LIMITS to see all tasks.\n"; fi

    local line_number=1
    local displayed_tasks=0

    while IFS='|' read -r task_text days_to_complete date_added category; do
        local days_left=$(calculate_days_left "$date_added" "$days_to_complete")

        if [ "$days_left" -le 0 ]; then
            format_text " ${BOLDER}${line_number}${NORMAL}. $task_text (${categorymap[$category]}$category${NORMAL}) (${RED}${UNDERLINE}OVERDUE${NORMAL})"
            ((displayed_tasks++))
        elif [ ! "$1" == "OVERDUE" ]; then
            format_text " ${BOLDER}${line_number}${NORMAL}. $task_text (${categorymap[$category]}$category${NORMAL}) (${BOLDER}${UNDERLINE}$days_left${NORMAL} ${GREEN}days left${WHITE})"
            ((displayed_tasks++))
        fi

        ((line_number++))
        if [ "$displayed_tasks" -ge "$limit" ]; then break; fi
    done < "$TASK_FILE"
    echo -e ""
}

# Function to edit a to-do item
edit_task() {
    local task_number="$1"
    local task_item=$(sed "${task_number}q;d" "$TASK_FILE")
    IFS='|' read -r task_text days_to_complete date_added <<< "$task_item"

    new_task_text=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the new to-do text (current: $task_text):  " bash -c 'read -e input; echo $input')
    new_days_to_complete=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the new days to complete (current: $days_to_complete):  " bash -c 'read -e input; echo $input')

    new_task_text=${new_task_text:-$task_text}
    new_days_to_complete=${new_days_to_complete:-$days_to_complete}

    sed -i "${task_number}s/.*/$new_task_text|$new_days_to_complete|$date_added/" "$TASK_FILE"
    echo "To-do item $task_number updated."
}


backup() {
    echo "beginning backup"
    BACKUP_DIR="$HOME/c/backup/tasklist"

    # Create a log file name with date
    # Create a backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then mkdir -p "$BACKUP_DIR"; fi
    # if dir is not empty then clear it
    if [ "$(ls -A $BACKUP_DIR)" ]; then format_text "${RED}Removing${NORMAL} old backup content" && rm -r $BACKUP_DIR/*; fi
    
    touch "$BACKUP_DIR/backup_log.txt"
    # Create copies of the TASK_FILE,ARCHIVE_FILE and RECURRING_TASKS in the backup directory
    cp "$TASK_FILE" "$BACKUP_DIR/task_list.txt"
    cp "$ARCHIVE_FILE" "$BACKUP_DIR/deleted_tasks.txt"
    cp "$RECURRING_FILE" "$BACKUP_DIR/recurring_tasks.txt"
    # Creat a log file of the backup
    STRIPCOLORS="$STRIP_COLORS"
    local log_content="$(generate_report)"
    echo -e "Backup created on $(date +%Y-%m-%d) \n $log_content" >> "$BACKUP_DIR/backup_log.txt"    
    # read -p "Backup created in $BACKUP_DIR. Read the file?(Y/n):  " input
    # if [[ "$input" == "Y" || "$input" == "y" ]]; then cat "$BACKUP_DIR/backup_log.txt"; fi
    STRIP_COLORS="$STRIPCOLORS"
}

# Function to export to-do list to a file
export_tasks() {
    filename=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter the filename to export to (e.g., tasks.csv):  " bash -c 'read -e input; echo $input')
    cp "$TASK_FILE" "$filename"
    echo "To-do list exported to $filename."
}

# Function to list deleted to-do items
list_deleted_tasks() {
    # Check that deleted file has contents
    if [ ! -s "$ARCHIVE_FILE" ]; then echo "No deleted to-do items found."; fi

    format_text "\nDeleted to-do items"
    local i=1
    while IFS='|' read -r task_text days_to_complete date_added date_completed ; do
        format_text "${i}. $task_text ($days_to_complete) $date_added"
        ((i++))
    done < "$ARCHIVE_FILE"
}

# Function to generate statistics and reports
generate_report() {
    local total_tasks=$(wc -l < "$TASK_FILE")
    local completed_tasks=$(wc -l < "$ARCHIVE_FILE")
    local overdue_tasks=$( list_tasks | grep "0 days left" | wc -l ) 
    local total_recurring=$(wc -l < "$RECURRING_FILE")
    local top3_categories=$(cut -d '|' -f 4 "$TASK_FILE" | sort | uniq -c | sort -nr | head -n 3 | while read -r count category; do format_text "${categorymap[$category]}${category}${NORMAL} ($count)"; done | tr '\n' ' ')
    
    echo "Statistics Report:"
    format_text "Total to-do items: ${BOLDER}$total_tasks${NORMAL}"
    format_text "Completed to-do items: ${GREEN}$completed_tasks${NORMAL}"
    format_text "Overdue to-do items: ${RED}$overdue_tasks${NORMAL}"
    format_text "Total recurring to-do items: ${BOLDER}$total_recurring${NORMAL}"
    format_text "\nTop 3 Categories: $top3_categories"
}

# Function to handle user authentication
user_authentication() {
    username=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter username:  " bash -c 'read -e input; echo $input')
    read -sp "Enter password: " password
    echo

    local user_record=$(grep "^$username:" "$USER_FILE")
    if [[ -z "$user_record" ]]; then
        echo "User not found. Please register."
        return 1
    fi

    IFS=':' read -r stored_username stored_password <<< "$user_record"
    if [[ "$password" == "$stored_password" ]]; then
        echo "Authentication successful."
        return 0
    else
        echo "Authentication failed."
        return 1
    fi
}

exit_level() {
    local level="${1:-1}"
    [ "$level" -eq 0 ] && echo "Exiting.. Goodbye!" && exit 1 || return
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                           Initialize Files                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Initialize to-do,deleted and recurring files if not exist         # File Overview (each newline reads as follows)#
if [ ! -f "$TASK_FILE" ]; then touch "$TASK_FILE" ;fi               # Todo | Days to complete       | Date added       | Category 
if [ ! -f "$ARCHIVE_FILE" ]; then  touch "$ARCHIVE_FILE" ;fi        # Todo | completed in (x) days  | Date added       | Date completed
if [ ! -f "$RECURRING_FILE" ]; then touch "$RECURRING_FILE" ;fi     # Todo | Interval               | Date last added


# Check if any recurring tasks are due to be added
add_recurring_tasks


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                        Command line arguments                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

handle_arguments() {
        arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        case "$arg" in
            add|-a|a)
            if [ "$#" -lt 2 ]; then prompt_user_to_add
            else
                task_text=$2
                days_to_complete=$3
                category=$4
                add_task "$task_text" "$days_to_complete" "$category"
            fi
                ;; 
            view|-v|v) list_tasks "${2:-$TASK_SOFT_LIMIT}";;
            delete|-d|d)
                if [ -z "$2" ]; then echo "Please provide the task number to delete." && exit 1; fi
                shift # Remove the -d argument 
                delete_task "$@"
                ;;
            report|-r|r) generate_report;;
            sort|-s|s) sort_tasks "$2";;    
            backup|-b|b) backup ;;        
            *)
                echo "Invalid argument: $arg. Use 'view' to list tasks or 'delete <task_number>' to delete a task."
                exit 1
                ;;
        esac
        exit 0
}

if [ "$#" -gt 0 ]; then handle_arguments "$@"; 
else draw_title;
fi


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                            Menu Options                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
# Function Name | Display Name

# The Main Menu options  
main_options=(
    "add_task|Add Task"
    "list_tasks|List Tasks"
    "delete_task|Delete Task"
    "display_advanced_options|Advanced Options"
    "exit_program|Exit"
)

advanced_options=(
    "advanced_view Open_advanced_view_selection Advanced View"
    "sort_tasks sort Sort"
    "import_tasks import Import from backup"
    "backup backup Backup"
    "set_recurring_task set_recurring Set Recurring"
    "generate_report report Generate Report"
    "edit_file edit Edit file directly (nano)"
    "user_authentication auth User Authentication"
)

# Define view options and corresponding functions
declare -A view_options=(
    ["1"]="list_tasks 'ALL'"
    ["2"]="list_deleted_tasks '100'"
    ["3"]="view_overdue_tasks '100'"
)

sort_options=(
    "sort_by_days_left_low Sort by Days Left - Low"
    "sort_by_days_left_high Sort by Days Left - High"
    "sort_by_category Sort by Category"
    "sort_alphabetically Sort Tasks Alphabetically"
    "sort_by_date_added Sort by Date Added"
)

# Function to display advanced options menu
display_advanced_options() {
    format_text "\nAdvanced options:"
    for i in "${!advanced_options[@]}"; do
        IFS=' ' read -r -a option <<< "${advanced_options[$i]}"
        format_text "$((i+1)). ${UNDERLINE}${option[2]}${NORMAL}"
    done

    advanced_choice=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter your choice:  " bash -c 'read -e input; echo $input')
    if [[ "$advanced_choice" =~ ^[0-9]+$ ]] && (( advanced_choice > 0 && advanced_choice <= ${#advanced_options[@]} )); then
        IFS=' ' read -r -a option <<< "${advanced_options[$((advanced_choice-1))]}"
        ${option[0]}
    else
        echo "Invalid option. Please try again."
    fi
}
# Function to display view options menu
advanced_view() {
    format_text "\nView options: \n1. ${UNDERLINE}LIST${NORMAL} \n2. ${UNDERLINE}SHOW${NORMAL} Deleted \n3. ${UNDERLINE}VIEW${NORMAL} Overdue"
    view_choice=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter your choice:  " bash -c 'read -e input; echo $input')
    if [[ -n "${view_options[$view_choice]}" ]]; then
        ${view_options[$view_choice]}
    else
        echo "Invalid option. Please try again."
    fi
}

display_main_options() {
    format_text "\nPlease choose an option:"
    for i in "${!main_options[@]}"; do
        IFS='|' read -r function_name display_name <<< "${main_options[$i]}"
        format_text "$((i+1)). ${UNDERLINE}${display_name}${NORMAL}"
    done

    main_choice=$(rlwrap -H ~/.input_history -P "$prompt_message" -S "Enter your choice: " bash -c 'read -e input; echo $input')
    main_choice=$(echo "$main_choice" | tr '[:upper:]' '[:lower:]') # Normalize to lowercase

    for i in "${!main_options[@]}"; do
        IFS='|' read -r function_name display_name <<< "${main_options[$i]}"
        display_name_first_word=$(echo "$display_name" | awk '{print tolower($1)}') # Get the first word and normalize to lowercase
        # Call main function if the choice matches the index or the first word of the display name
        if [[ "$main_choice" == "$((i+1))" || "$main_choice" == "$display_name_first_word" ]]; then
            $function_name
            return
        fi
    done

    echo "Invalid option. Please try again."
}
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                               Main Loop                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# List the to-do items on interactive startup
list_tasks 

# Main loop to interact with the user
while true; do
    display_main_options
done