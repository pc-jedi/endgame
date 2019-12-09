#!/usr/bin/env bash

set -eo pipefail

if [[ "$EUID" -ne 0 ]]
  then echo "Please run as root"
  exit
fi

promode=false
skillmode=false
numberofprocess=1

while (( "$#" )); do
  case "$1" in
    -p|--pro)
      promode=true
      shift 2
      ;;
    -s|--skill)
      skillmode=true
      numberofprocess=3
      shift
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

    echo

    if [[ "$skillmode" = true ]]; then
        echo "with skill-mode enabled"
    else
        echo "you can enable skill-mode (select on out of 3) by starting with -s or --skill"
    fi

    echo

    read -p "Press Enter"
    # clear screen
    printf "\033c"
}

function rules() {
    cat << "EOF"
THE RULES

1. Prepare a drink
2. The goal is to kill a process without killing the machine.
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

    result=()

    for (( i = 0; i < ${numberofprocess}; ++i )); do
        rand=$(( $RANDOM % ${#r[@]} ))
        pid=$(echo ${r[$rand]} | awk '{print $2}')
        process=$(echo ${r[$rand]} | awk '{for (i=11; i<NF; i++) printf $i " "; print $NF}')

        result[$i]="${pid} '${process}'"
    done

    if [[ "$skillmode" = false ]]; then
        echo "The following process has been selected"
        echo "$pid $process"

        read -p "Kill it with -9? (Y/n)" answer
        case ${answer:0:1} in
        n|N )
            echo "You skipped. Drink!"
        ;;
        * )
            if ! kill -9 ${pid}; then
                echo "Process was already dead. Drink!"
            fi
        ;;
        esac
    else
        echo "Select one of the following process"
        for i in "${!result[@]}"; do
            printf "%s\t%s\n" "$i" "${result[$i]}"
        done

        read -p "Which process to kill? (0-2)" answer
        case ${answer} in
        0|1|2 )
            pid=$(echo ${result[${answer}]} | awk '{print $1}')

            if ! kill -9 ${pid}; then
                echo "Process was already dead. Drink!"
            fi
        ;;
        * )
            echo "Wrong input. Drink!"
        ;;
        esac
    fi

    echo "Waiting 5s for the process to react".

    sleep 5

    if kill -0 ${pid} > /dev/null 2>&1; then
        echo "Process did not die. Drink!"
    else
        echo "SUCCESS you killed ${pid}."
    fi

    read -p "Press enter to continue with next person."
done
