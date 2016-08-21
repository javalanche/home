#!/bin/sh

# jsf: I found this here: https://gist.github.com/kbzod/2968555
# jsf: And changed the name from colorize-maven.sh to mvn-color.sh
# jsf: And changed the function from color_maven to mvn-color
# Written by Mike Ensor (mike@ensor.cc)
# Copywrite 2012
# Use as needed, modify, have fun!
# Modified by Bill Havanki
# This was intended to be used for Maven3 + Mac OSX, but it's been modified for Cygwin and Linux.
#   Maybe it still works on OSX?
# Changes from original:
# - Cygwin support
# - xterm-16color support
# - additional colorization: downloaded files
# - improved highlighting in various places
# - altered sed calls to support Cygwin escape sequences
#
# To use:
# in your ".bashrc" or ".bash_profile" add the following lines:
#
# export MAVEN_HOME=/path/to/maven
# . /path/to/script/colorize-maven.sh
# alias maven=$M2_HOME/bin/mvn
#
# Now "mvn" will be colorized, but "maven" will not be.
#

c_black=
c_cyan=
c_magenta=
c_red=
c_white=
c_green=
c_yellow=
c_blue=
c_bg_black=
c_bg_cyan=
c_bg_magenta=
c_bg_red=
c_bg_white=
c_bg_green=
c_bg_yellow=
c_bg_blue=
c_end=
c_bold=


xterm_color() {
        #       0       Black
        #       1       Red
        #       2       Green
        #       3       Yellow
        #       4       Blue
        #       5       Magenta
        #       6       Cyan
        #       7       White

    # Yes, this could be a map
    c_bold=`tput setaf 0`
    c_bg_bold=`tput setab 0`
    c_black=`tput setab 0`
    c_bg_black=`tput setab 0`
    c_cyan=`tput setaf 6`
    c_bg_cyan=`tput setab 6`
    c_magenta=`tput setaf 5`
    c_bg_magenta=`tput setab 5`
    c_red=`tput setaf 1`
    c_bg_red=`tput setab 1`
    c_white=`tput setaf 7`
    c_bg_white=`tput setab 7`
    c_green=`tput setaf 2`
    c_bg_green=`tput setab 2`
    c_yellow=`tput setaf 3`
    c_bg_yellow=`tput setab 3`
    c_blue=`tput setaf 4`
    c_bg_blue=`tput setab 4`
    c_end=`tput sgr0`
}

cygwin_color() {
    c_bold='\x1b[1m'

    c_black='\x1b[0;30m'
    c_red='\x1b[1;31m'
    c_green='\x1b[1;32m'
    c_yellow='\x1b[1;33m'
    c_blue='\x1b[1;34m'
    c_magenta='\x1b[1;35m'
    c_cyan='\x1b[1;36m'
    c_white='\x1b[0;37m'

    c_bg_black='\x1b[40m'
    c_bg_red='\x1b[41m'
    c_bg_green='\x1b[42m'
    c_bg_yellow='\x1b[43m'
    c_bg_blue='\x1b[44m'
    c_bg_magenta='\x1b[45m'
    c_bg_cyan='\x1b[46m'
    c_bg_white='\x1b[47m'

    c_end='\x1b[0m'
}

ansi_color() {
    c_bold=   '[1m'
    c_blue=   '[1;34m'
    c_black=  '[1;30m'
    c_green=  '[1;32m'
    c_magenta='[1;35m'
    c_red=    '[1;31m'
    c_cyan=   '[1;36m'
    c_end=    '[0m'
}

mvn-color() {

    # pick color type
    if [ $USER = 'javier' -o $TERM = 'xterm-16color' ]
    then
        xterm_color
    elif [ $USER = 'JF732H' ]
    then
        cygwin_color
#    elif [ $TERM = 'ansi' ]
#    then
#           ansi_color
        else
            echo -e "${c_red}WARNING:::Terminal '${TERM}' is not supported at this time. Colorized output will not happen for Maven${c_end}"
        fi

        error=${c_bold}${c_red}
        info=${c_white}
        warn=${c_yellow}
        success=${c_green}
        projectname=${c_bold}${c_cyan}
        skipped=${c_white}
        downloading=${c_magenta}
        downloaded=${c_green}

        $M2_HOME/bin/mvn $* | sed -u -e "s/\(\[INFO\]\) Building \(.*\)/${info}Building ${projectname}\2${c_end}/g" \
                -e "s/\(Time elapsed: \)\([0-9]\+[.]*[0-9]*.sec\)/${c_white}\1${c_cyan}\2${c_end}/g" \
                -e "s/\(Downloading: .*\)/${downloading}\1${c_end}/g" \
                -e "s/\(Downloaded: .*\)/${downloaded}\1${c_end}/g" \
                -e "s/BUILD SUCCESS/${success}BUILD SUCCESS${c_end}/g" \
                -e "s/BUILD FAILURE/${error}BUILD FAILURE${c_end}/g" \
                -e "s/WARNING: \([-a-zA-Z0-9./\\ :]\+\)/${warn}WARNING: \1${c_end}/g" \
                -e "s/SEVERE: \(.\+\)/${c_white}${c_bg_red}SEVERE: \1${c_end}/g" \
                -e "s/Caused by: \(.\+\)/${c_white}${c_bg_green}Caused by: \1${c_end}/g" \
                -e "s/Running \(.\+\)/${c_green}Running \1${c_end}/g" \
                -e "s/FAILURE \(\[[0-9]\+.[:0-9]\+s\]\)/${error}FAILURE \1${c_end}/g" \
                -e "s/SUCCESS \(\[[0-9]\+.[:0-9]\+s\]\)/${success}SUCCESS \1${c_end}/g" \
                -e "s/\[INFO\] \(.*\)/${info}\1${c_end}/g" \
                -e "s/INFO: \(.\+\)/${c_white}\1${c_end}/g" \
                -e "s/\[WARN\] \(.*\)/${warn}\[WARN\] ${c_white}\1${c_end}/g" \
        -e "s/\(\[WARN.*\)/${warn}\1${c_end}/g" \
                -e "s/\[ERROR\] \(.*\)/${error}\[ERROR\] ${c_white}\1${c_end}/g" \
        -e "s/\(\[ERROR.*\)/${error}\1${c_end}/g" \
        -e "s/\(<<< FAILURE!\)/${error}\1${c_end}/g" \
        -e "s/Tests run: \([0-9]*\), Failures: \([0-9]*\), Errors: \([0-9]*\), Skipped: \([0-9]*\)/Tests run: ${c_green}\1${c_end}, Failures: ${warn}\2${c_end}, Errors: ${error}\3${c_end}, Skipped: ${skipped}\4${c_end}/g"
}

alias mvn=mvn-color
