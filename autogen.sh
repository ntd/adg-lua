#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

if test ! -f $srcdir/configure.ac -o ! -f $srcdir/examples/Adg.lua; then
    echo "**Error**: '$srcdir' does not look like the top-level adg-lua directory"
    exit 1
fi

cd $srcdir
libtoolize --automake || exit $?
autoreconf -is -Wall || exit $?
./configure "$@" && echo "Now type 'make' to compile $PROJECT."
