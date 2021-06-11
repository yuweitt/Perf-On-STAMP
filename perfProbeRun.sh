STAMP_BASE="/home/yuweitt/stm/stm-tracing/stamp-0.9.10"

# Stamp Benchmark list
declare -a stamp_tests
stamp_tests+=(bayes)
stamp_tests+=(genome)
stamp_tests+=(intruder)
stamp_tests+=(kmeans)
stamp_tests+=(labyrinth)
stamp_tests+=(ssca2)
stamp_tests+=(vacation)
stamp_tests+=(yada)

# Stamp Benchmark Config
declare -A stamp_cmd
stamp_cmd["bayes"]="-v32 -r1024 -n2 -p20 -s0 -i2 -e2 -t" 
stamp_cmd["genome"]="-g16384 -s64 -n16777216 -t"
stamp_cmd["intruder"]="-a10 -l128 -n262144 -s1 -t"
stamp_cmd["kmeans"]=" -m40 -n40 -t0.00001 -i ${STAMP_BASE}/kmeans/inputs/random-n65536-d32-c16.txt -p"
stamp_cmd["labyrinth"]="./labyrinth -i ${STAMP_BASE}/labyrinth/inputs/random-x512-y512-z7-n512.txt -t"
stamp_cmd["ssca2"]="-s20 -i1.0 -u1.0 -l3 -p3 -t"
stamp_cmd["vacation"]="-n2 -q90 -u98 -r1048576 -t4194304 -t"
stamp_cmd["yada"]="-a15 -i ${STAMP_BASE}/yada/inputs/ttimeu1000000.2 -t"
nthreads=4

# Probe Function List
probe="probe_"
start="stm_start"
commit="stm_commit"
commit_r="stm_commit_return__return"
rollback="stm_rollback"
# delay="stm_delay"
# delay_r="stm_delay_return__return"
ul="_"

# probe_list="stm_start stm_commit stm_commit%return stm_rollback stm_delay stm_delay%return"
probe_list="stm_start stm_commit stm_commit%return stm_rollback"

sudo perf probe --del=*stm*
for bench_test in ${stamp_tests[@]};do
	cd "$STAMP_BASE/$bench_test"
	for var in $probe_list
	do
		name=${var/"%"/"_"}
  		eval "sudo perf probe -x $bench_test ${bench_test}_${name}=$var"
	done
done
# sudo perf probe --list


# -e $probe$bench_test:$bench_test$ul$delay \
# -e $probe$bench_test:$bench_test$ul$delay_r \

read -r -p "Perf status [0] / Perf record [1] " resp
case "$resp" in 
  [0])
    for bench_test in ${stamp_tests[@]};do
      cd "$STAMP_BASE/$bench_test"
      echo $PWD
      eval "sudo perf stat -v -e $probe$bench_test:$bench_test$ul$start \
                        -e $probe$bench_test:$bench_test$ul$commit\
                        -e $probe$bench_test:$bench_test$ul$commit_r\
                        -e $probe$bench_test:$bench_test$ul$rollback \
                        ./$bench_test ${stamp_cmd[${bench_test}]} ${nthreads}"
    done
  ;;
  [1])
    for bench_test in ${stamp_tests[@]};do
      cd "$STAMP_BASE/$bench_test"
      echo $PWD
      eval "sudo perf record -v -e $probe$bench_test:$bench_test$ul$start \
                          -e $probe$bench_test:$bench_test$ul$commit\
                          -e $probe$bench_test:$bench_test$ul$commit_r\
                          -e $probe$bench_test:$bench_test$ul$rollback \
                          ./$bench_test ${stamp_cmd[${bench_test}]} ${nthreads}"
      sudo perf script --ns -F tid,time,event > ../${bench_test}ptrace
    done
  ;;
  *)
    exit 0
  ;;
esac