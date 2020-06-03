#!/bin/sh
TIMEFORMAT=$'\nreal\t%3lR user\t%3lU sys\t%3lS'

for f in 1 2 3; do
    ../java-with-debug 8002 MinHeap &
    sleep 1
    setup-plt -l frp-debugger > /dev/null &&
    time mred -L frp.ss frtime -r $1
done