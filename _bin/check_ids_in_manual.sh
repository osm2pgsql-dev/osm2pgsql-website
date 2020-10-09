#!/bin/sh
#
#  Check for non-unique ids in the manual
#
#  Run `jekyll build` before calling this.
#

grep id= _site/doc/manual.html | cut -d\" -f2 | sort | uniq -c | grep -v 1

