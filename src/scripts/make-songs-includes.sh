#!/bin/bash

inputs=$(for f in `ls $SRC_DIR/songs/*.tex`; do echo "\input{songs/$(basename $f | cut -d. -f 1)}"; done)
content=$(< $SRC_DIR/songs.tex)
macro="{{INCLUDES}}"

echo "${content/$macro/$inputs}" > $SRC_DIR/pre-build.tex
