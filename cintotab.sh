#!/usr/bin/bash
# cintotab.sh, MIT License, Wei-Lun Chao <bluebat@member.fsf.org>, 2021.

ICON=gtk-apply
COMMAND=
for i in gcin2tab oxim2tab cin2tab cin2gtab; do
    if which $i; then
        [ -z "$COMMAND" ] && COMMAND=$i || COMMAND+=\!$i
    fi
done
INPUT=
OUTPUT=$HOME
OPTIONS=$(yad --on-top --center --width=320 \
        --window-icon="$ICON" \
        --title "CIN to TAB" \
        --align=right \
        --form \
        --field="Command:":CB "$COMMAND" \
        --field="Input File:":FL "$INPUT" \
        --field="Output Dir:":DIR "$OUTPUT" \
        --button="yad-cancel":1 --button="yad-execute":0)

EXITCODE=$?
if [ "$EXITCODE" -eq 0 ]; then
    COMMAND=$(echo $OPTIONS | awk -F '|' '{ print $1 }')
    INPUT=$(echo $OPTIONS | awk -F '|' '{ print $2 }')
    OUTPUT=$(echo $OPTIONS | awk -F '|' '{ print $3 }')
    CINNAME=$(basename "$INPUT" .cin)
    if [ -z "$COMMAND" -o -z "$INPUT" -o -z "$OUTPUT" ]; then
        yad --on-top --window-icon="$ICON" --title "Error" --image "dialog-error" --text "\nEmpty Command, Input File or Output Dir?" --button=yad-ok
        exit 1
    else
        case "$COMMAND" in
            gcin2tab|cin2gtab) RESULT=$(/usr/bin/cp -f "$INPUT" /tmp/; "$COMMAND" /tmp/"$CINNAME".cin; /usr/bin/mv -f /tmp/"$CINNAME".gtab "$OUTPUT") ;;
            oxim2tab) RESULT=$("$COMMAND" "$INPUT" -o "$OUTPUT"/"$CINNAME".tab) ;;
            cin2tab) RESULT=$(/usr/bin/cp -f "$INPUT" /tmp/; "$COMMAND" /tmp/"$CINNAME".cin; /usr/bin/mv -f /tmp/"$CINNAME".tab* "$OUTPUT") ;;
        esac            
        yad --on-top --window-icon="$ICON" --text "$RESULT" --title "Log of Conversion" --center --width=360 --wrap --no-buttons
    fi
fi
