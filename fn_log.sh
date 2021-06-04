#!/bin/bash
[[ "$SERVICE" == "" ]] && SERVICE="script"


LOGFL=/var/log/${SERVICE}.log
#Function to record event logs using shell script in bash.
#Sintaxe fnLog "<[D|I|A|E]>" "Message" "opcional N or exit code>"
# Where D=Debugging, I=Information, A=Alert and E=ERROR
fnLog(){
    [[ "$VERBOSE" == "" ]] && VERBOSE=1
    DATA=$(date "+%b %d %H:%M:%S")
    #Default message
    D_MSG=""
    case $1 in
        "D") [[ $VERBOSE -gt 2 ]] && echo -e "$DATA - $SERVICE[DEBUG] - $2" |tee -a $LOGFL;;
        "I") [[ $VERBOSE -gt 1 ]] && echo -e "$DATA - $SERVICE[INFO] - $2" |tee -a $LOGFL;;
        "A") [[ $VERBOSE -ge 1 ]] && echo -e "$DATA - $SERVICE[WARNNING] - $2" |tee -a $LOGFL;;
        "E") echo -e "$DATA - $SERVICE[ERROR] - $2"|tee -a $LOGFL;
             [[ "${3^^}" != "N" ]] && { [[ "$3" ~= ^[0-9]+$ ]] && exit $3 || exit 1 ; };;
    esac
}
