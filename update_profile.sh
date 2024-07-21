#!/bin/bash

# Usage: ./update_profile.sh name "New Name" handle "@NewHandle" currently "Reading" mood "Happy"

# MySQL credentials
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"
DB_NAME="your_db_name"
DB_HOST="your_db_host"

# URL of the JSON file
JSON_URL="http://www.bloodweb.net/Jackewers.com/profile.json"

# Temporary local file to store the JSON
TMP_FILE="profile.json"

# Function to update a field in the JSON file
update_field() {
    local field="$1"
    local value="$2"
    jq --arg v "$value" --arg f "$field" '.[$f] = $v' "$TMP_FILE" > tmp.json && mv tmp.json "$TMP_FILE"
}

# Download the current JSON file
curl -s "$JSON_URL" -o "$TMP_FILE"

# Check if the JSON file was downloaded correctly
if ! jq empty "$TMP_FILE" > /dev/null 2>&1; then
    echo "Error: Invalid JSON file downloaded."
    cat "$TMP_FILE"
    exit 1
fi

# Retrieve the age from MySQL
#AGE=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -D "$DB_NAME" -se "SELECT age FROM profile WHERE id=1;")
AGE="32"
# Check if the age value is valid
#if ! [[ "$AGE" =~ ^[0-9]+$ ]]; then
#    echo "Error: Invalid age value retrieved from MySQL."
#    echo "Age: $AGE"
#    exit 1
#fi

# Update the age field in the JSON file
update_field "age" "$AGE"

# Read command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        name|handle|currently|mood)
            field="$1"
            value="$2"
            shift # past argument
            shift # past value
            update_field "$field" "$value"
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Upload the updated JSON file back to the server
curl -X PUT -T "$TMP_FILE" "$JSON_URL"

