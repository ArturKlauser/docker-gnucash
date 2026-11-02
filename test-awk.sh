#!/bin/bash
sec_fractions=10
sleep_time=$(awk "BEGIN {print 1/$sec_fractions}")
echo "sleep time: $sleep_time"
