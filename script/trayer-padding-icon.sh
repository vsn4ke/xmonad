#!/bin/sh


# Width of the trayer window
w=$(xprop -name panel | grep 'program specified minimum size' | cut -d ' ' -f 5) 
s=10
width=$((w/s))
pixels=$(for i in `seq $width`; do echo -n " "; done)

echo "$pixels"
