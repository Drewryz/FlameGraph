#!/usr/bin/python
#encoding=utf-8
import sys

'''
This script reads perf script output, extracting function name and time(ms) of event traces.
This is a example of makeing a off cpu flame graph:
    perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso,trace -i perf_data | \
    ./extract_trace.py | \
    ./stackcollapse.pl | \
    ./flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > offcpu.svg
'''

def get_command(s):
    trashs = s.split()
    return ' '.join(trashs[0:len(trashs)-1])


def get_period_ms(s):
    trashs = s.split()
    return int(trashs[2])/1000000


is_header = True
for line in sys.stdin:
    if is_header:
        # There are some wired event headers in mongod, so...
        fields = line.split('[')
        command = get_command(fields[0])
        period_ms = get_period_ms(fields[1])
        is_header = False
        continue
    if len(line.strip()) == 0:
        if period_ms > 0:
            print command
            print period_ms
            print
        is_header = True
        continue
    if period_ms > 0:
        trace = line.split()
        symbol = " ".join(trace[1:len(trace)-1])
        print symbol

