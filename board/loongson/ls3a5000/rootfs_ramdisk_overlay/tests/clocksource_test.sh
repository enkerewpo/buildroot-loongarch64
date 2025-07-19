#!/bin/bash

echo "[*] date +%s every 1s"
for i in $(seq 3); do date +%s; sleep 1; done

echo "[*] sleep 5 timing test"
t0=$(date +%s)
sleep 5
t1=$(date +%s)
echo "Elapsed: $(($t1 - $t0)) seconds"

echo "[*] timer interrupts"
BEFORE=$(cat /proc/interrupts | grep -i timer)
sleep 2
AFTER=$(cat /proc/interrupts | grep -i timer)
echo "Before: $BEFORE"
echo "After: $AFTER"

# 18:     152705   CPUINTC  11  timer
# parse the number of timer interrupts and calculate the difference
TIMER_INTERRUPTS_BEFORE=$(echo "$BEFORE" | awk '{print $2}')
TIMER_INTERRUPTS_AFTER=$(echo "$AFTER" | awk '{print $2}')
TIMER_INTERRUPTS_DIFF=$(($TIMER_INTERRUPTS_AFTER - $TIMER_INTERRUPTS_BEFORE))
echo "Timer interrupts: $TIMER_INTERRUPTS_DIFF"

# 100 MHz