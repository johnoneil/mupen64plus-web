#!/bin/bash
# prepare-files.sh
# filter all files in CWD so names no longer contain
# spaces, parentheses, exclamation points, etc.
# This is to make them easier to handle via make+bash

    
rename 's/ /_/g' *.*
rename 's/\!/-/g' *.*
rename 's/\(/\[/g' *.*
rename 's/\)/\]/g' *.*

