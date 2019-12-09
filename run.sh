#!/usr/bin/env bash

set -eo pipefail

if [[ "$EUID" -ne 0 ]]
  then echo "Please run as root"
  exit
fi

promode=false

while (( "$#" )); do
  case "$1" in
    -p|--pro)
      promode=true
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1"
      exit 1
      ;;
    *) # preserve positional arguments
      shift
      ;;
  esac
done


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
 v0.2
EOF
    if [[ "$promode" = true ]]; then
        echo "with pro-mode enabled"
    else
        echo "you can enable pro-mode (incl. kernel threads) by starting with -p or --pro"
    fi


    read -p "Press Enter"
    # clear screen
    printf "\033c"
}

function rules() {
    cat << "EOF"
THE RULES

Prepare a drink
EOF
    read -p "Press Enter to start."
    # clear screen
    printf "\033c"
}

intro

rules

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

    read -p "Use -15 (SIGTERM) else -9? (Y/n)" answer
    case ${answer:0:1} in
    y|Y )
        if ! kill -15 ${pid}; then
            echo "Process was already dead. Drink!"
        fi
    ;;
    * )
        if ! kill -9 ${pid}; then
            echo "Process was already dead. Drink!"
        fi
    ;;
    esac

    echo "Waiting 5s for the process to react".

    sleep 5

    if kill -0 ${pid} > /dev/null 2>&1;; then
        echo "Process did not die. Drink!"
    fi

    read -p "Press enter to continue with next round"
done