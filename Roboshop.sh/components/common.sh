
 LOG_FILE=/tmp/roboshop.log
 rm -f

## Declaring a function
STAT(){
  if [ $1 -eq 0 ]; then
    echo "\e[1;31mSUCCESS\e[0m"
  else
    echo "\e[1;31mFAILED\e[0m"
    exit 2
  fi
}