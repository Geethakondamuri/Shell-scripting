#!/bin/bash

if [ -f components/$1.sh ];then
  bash components/$1.sh
else
  echo -e "\e[1;31mInvalid Inputs\[0m"
  echo -e "\e[1;32mAvailable Inputs are frontend|mongodb|catalogue|redis|user|cart|mysql|shipping|payment|rabbitmq|dispatch\e[0m"
fi
