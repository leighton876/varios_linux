#!/bin/bash

#################################
# Speech Script by Dan Fountain #
# Modified by Pablo Castagnino  #
# TalkToDanF@gmail.com          #
#################################

INPUT=$*
STRINGNUM=0

if [ -z $1 ]; then
    clear
    echo "Modo de empleo:"
    echo "(el primer es es el idioma)"
    echo "./voz_google.sh es hola mundo."
else

    ary=(${INPUT:2})
    echo "---------------------------"
    echo "Speech Script by Dan Fountain"
    echo "TalkToDanF@gmail.com"
    echo "---------------------------"
    for key in "${!ary[@]}"
    do
    SHORTTMP[$STRINGNUM]="${SHORTTMP[$STRINGNUM]} ${ary[$key]}"
    LENGTH=$(echo ${#SHORTTMP[$STRINGNUM]})
    #echo "word:$key, ${ary[$key]}"
    #echo "adding to: $STRINGNUM"
    if [[ "$LENGTH" -lt "100" ]]; then
    #echo starting new line
    SHORT[$STRINGNUM]=${SHORTTMP[$STRINGNUM]}
    else
    STRINGNUM=$(($STRINGNUM+1))
    SHORTTMP[$STRINGNUM]="${ary[$key]}"
    SHORT[$STRINGNUM]="${ary[$key]}"
    fi
    done

    for key in "${!SHORT[@]}"
    do
    #echo "line: $key is: ${SHORT[$key]}"

    echo "Playing line: $(($key+1)) of $(($STRINGNUM+1))"
    mpg123 -q "http://translate.google.com/translate_tts?tl=${1}&q=${SHORT[$key]}"
    done
fi
