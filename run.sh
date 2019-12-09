#!/usr/bin/env bash

set -eo pipefail

promode=${PROMODE:-false}


function toArray {
    SAVEIFS=$IFS   # Save current IFS
    IFS=$'\n'      # Change IFS to new line
    r=($1) # split to array $names
    IFS=${SAVEIFS}   # Restore IFS
}

function intro() {
    cat << "EOF"

 ________                  __
|        \                |  \
| $$$$$$$$ _______    ____| $$  ______    ______   ______ ____    ______
| $$__    |       \  /      $$ /      \  |      \ |      \    \  /      \
| $$  \   | $$$$$$$\|  $$$$$$$|  $$$$$$\  \$$$$$$\| $$$$$$\$$$$\|  $$$$$$\
| $$$$$   | $$  | $$| $$  | $$| $$  | $$ /      $$| $$ | $$ | $$| $$    $$
| $$_____ | $$  | $$| $$__| $$| $$__| $$|  $$$$$$$| $$ | $$ | $$| $$$$$$$$
| $$     \| $$  | $$ \$$    $$ \$$    $$ \$$    $$| $$ | $$ | $$ \$$     \
 \$$$$$$$$ \$$   \$$  \$$$$$$$ _\$$$$$$$  \$$$$$$$ \$$  \$$  \$$  \$$$$$$$
                              |  \__| $$
                               \$$    $$
                                \$$$$$$
 v0.1
EOF
    read -p "Press Enter to start."
    # clear screen
    printf "\033c"
}

intro

while true; do
    # clear screen
    printf "\033c"

    if [[ "$promode" = true ]]; then
        processes=$(ps -AF --no-header)
    else
        processes=$(ps --ppid 2 --deselect -F --no-header)
    fi

    readarray -t r <<<"$processes"

    i=$(( $RANDOM % ${#r[@]} ))

    pid=$(echo ${r[$i]} | awk '{print $2}')
    process=$(echo ${r[$i]} | awk '{for (i=11; i<NF; i++) printf $i " "; print $NF}')

    echo "The following process has been selected"
    echo "$pid $process"

    read -p "Use -9 (SIGKILL)? (y/N)" answer
    case ${answer:0:1} in
    y|Y )
        if ! kill -9 ${pid} > /dev/null 2>&1; then
            echo "Process was already dead. Take a shot!"
        fi
    ;;
    * )
        if ! kill -15 ${pid} > /dev/null 2>&1; then
            echo "Process was already dead. Take a shot!"
        fi
    ;;
    esac

    sleep 5

    if ! kill -0 ${pid} > /dev/null 2>&1; then
        echo "Process did not die. Take a shot!"
    fi

    read -p "Press enter to continue with next round"
done