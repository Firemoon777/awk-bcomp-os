#!/bin/bash

rm -f bcomp-in bcomp-out
mkfifo bcomp-in bcomp-out
sleep 999999 > bcomp-in &
sleep 999999 > bcomp-out &

./bcomp -c <bcomp-in | sed -u 's/^/bcomp> /' > bcomp-out &

gawk -f bcomp-os.awk ./bcomp-out &

cat | sed -u 's/^/shell> /' > bcomp-out

rm -f bcomp-in bcomp-out
pkill -P $$
