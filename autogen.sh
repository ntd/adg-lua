#!/bin/sh
# Run this to generate all the initial makefiles, etc.

step() {
    local message="$1"
    local command="$2"

    printf "$message... "

    if eval $command >/dev/null 2>&1; then
	printf "\033[32mok\033[0m\n"
    else
	local result=$?
	printf "\033[31mfailed\033[0m\n  ** \"$command\" returned $result\n"
	exit $result
    fi
}


dir=`dirname $0`
test -z "$dir" && dir=.

step	"Checking for top-level adg-lua directory" \
	"test -f '$dir/adg-demo.lua'"

step	"Creating dummy ChangeLog, if needed" \
	"test -f '$dir/ChangeLog' || touch '$dir/ChangeLog'"

step	"Regenerating autotools files" \
	"autoreconf -is -Wall '$dir'"


printf "Now run \033[1m$dir/configure\033[0m to customize your building\n"
