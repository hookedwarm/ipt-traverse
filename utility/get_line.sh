#!/bin/bash
# get a line from a file
# get line 5 from "afile":
# ./get_line.sh 5 ./afile
cat "$2" | head -n $1 | tail -n 1
