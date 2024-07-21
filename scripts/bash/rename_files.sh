dir="$1"
i=1

echo -e "Renaming all png,jpeg,jpg files in $dir. \nare you sure ?? (y/n)"
read input
if [ "${input,,}" != "y" ]; then
echo "User did not confirm execution.. ending script" && exit 1 
fi

for file in "$dir"/*{png,jpeg,jpg}; do
[ -f "$file" ] || continue # skip non exxistent files
[ "${file##*.}" == "mp4"] && continue # skip mp4 files

new_name="$dir/image_$((i++)).${file##*.}" # rename ($dir)/image_(i).(png/jpeg)
mv "$file" "$new_name" # rename the image
echo "file $file has been renamed to $new_name"
done

