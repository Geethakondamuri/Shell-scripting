#!/bin/bash
ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo -e "\e[1;31mYou should be the root user to execute this script\[0m"
exit 1
fi

if [ -f components/$1.sh ];then
  bash components/$1.sh
else
  echo -e "\e[1;31mInvalid Inputs\[0m"
  echo -e "\e[1;32mAvailable Inputs are frontend|mongodb|catalogue|redis|user|cart|mysql|shipping|payment|rabbitmq|dispatch\e[0m"
  exit 1
fi
