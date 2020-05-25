#!/usr/bin/python
#encoding=utf-8
import sys

'''
This script reads perf script output, parsing mongod command name.
'''

is_header = True
for line in sys.stdin:
    if is_header:
        # There are some wired event headers in mongod, like 'repl wr.orker 9 25829  4154.757496:     371710 cycles:'
        fields = line.split()
        header = '_'.join(fields[0:len(fields)-4]) + line[len(' '.join(fields[0:len(fields)-4])):]
        print header,
        is_header = False
        continue
    if len(line.strip()) == 0:
        is_header = True
        print line,
        continue
    print line,

