dir="$1"

result=\"$(ls -m "$dir" | sed 's/, /\",\"/g; s/,$/"/')\"

echo "$result"
