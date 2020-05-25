#/bin/bash

# This script is used to draw off cpu flame graphs. And the output include all cpu flame and specified process flame.
# The frequency of perf record is defalut value. 

duration=$1
pid=$2
timestamp=`date "+%Y-%m-%d-%H-%M-%S"`

raw_data=perf.data.raw.${timestamp}
# TODO: if set frequency, the graph will be error :(
# echo "perf record -F ${hz} -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_stat_blocked -e sched:sched_stat_iowait -e sched:sched_stat_wait -e sched:sched_process_exit -g -a -o ${raw_data} sleep ${duration}"
# perf record -F ${hz} -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_stat_blocked -e sched:sched_stat_iowait -e sched:sched_stat_wait -e sched:sched_process_exit -g -a -o ${raw_data} sleep ${duration}
echo "perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_stat_blocked -e sched:sched_stat_iowait -e sched:sched_stat_wait -e sched:sched_process_exit -g -a -o ${raw_data} sleep ${duration}"
perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_stat_blocked -e sched:sched_stat_iowait -e sched:sched_stat_wait -e sched:sched_process_exit -g -a -o ${raw_data} sleep ${duration}

perf_data=perf.data.${timestamp}
echo "perf inject -v -s -i ${raw_data} -o ${perf_data}"
perf inject -v -s -i ${raw_data} -o ${perf_data}

graph_pid=${pid}-${timestamp}.svg
graph_all=all-${timestamp}.svg

echo "perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso,trace --pid ${pid} -i ${perf_data} | ./extract_trace.py | ./stackcollapse.pl | ./flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > ${graph_pid}"
perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso,trace --pid ${pid} -i ${perf_data} | ./extract_trace.py | ./stackcollapse.pl | ./flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > ${graph_pid}

echo "perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso,trace -i ${perf_data} | ./extract_trace.py | ./stackcollapse.pl | ./flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > ${graph_all}"
perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso,trace -i ${perf_data} | ./extract_trace.py | ./stackcollapse.pl | ./flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > c

echo "success:"
echo "${graph_pid}"
echo "${graph_all}"
