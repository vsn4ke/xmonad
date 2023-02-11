#!/bin/sh
w=$(xprop -name panel | grep 'program specified minimum size' | cut -d ' ' -f 5) 
s=10; width=$((w/s));
echo "$(for i in `seq $width`; do echo -n " "; done)"