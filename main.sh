# This FIle Automatically Adds the Bash Envimorment to RC
# #  # #

RC_LOCATION="$HOME/.bashrc"
ENV_LOCATION="$HOME/c/bash/env/.config"

echo "Sourcing ENV items to RC"

if grep -q "BloodWeb Custom" $RC_LOCATION; then
    echo "Enviroment Already exists in BashRC"
else
    echo "Enviromentpkill not in RC"
    echo -e "\n# BloodWeb Custom Sourcing\nsource $ENV_LOCATION\n# BloodWeb Custom Sourcing " >> "$RC_LOCATION"
    echo "Enviroment Sourced Successfully, resetting "
fi