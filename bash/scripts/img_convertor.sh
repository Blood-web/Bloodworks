accepted_formats=(".jpeg" ".png")
img_to_convert="$1"

function ends_with_extension (){
    local input="$1"
    for ext in "${accepted_formats[@]}"; do
        if [[ "$input" == *"$ext" ]]; then return 0; fi
    done
    return 1
}


if [[ $1 && $2 ]] && ends_with_extension "$img_to_convert"; then
  if command -v python3 &>/dev/null;then
    python3 ~/c/scripts/python/convert_to_webp.py "$img_to_convert" 80
  else 
    echo "Python 3 is not installed, cannot run img_convertor"
  fi
else
  echo -e "${RED}ERROR${NORMAL}: \"$1\" or \"$2\" are not valid image extensions \nPlease pass an a valid image and extension as arguments in the following format: img_convertor \"image.png\" \"${accepted_formats[@]}\""
fi
