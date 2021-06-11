set -e
## Reminders
cat <<< " Before running stamp, make sure that the following files are properly adjusted.
[STAMP_BASE]/lib/tm.h

If perf is needed, make sure that the following files are modified.
[STAMP_BASE]/common/Defines.common.mk
[STAMP_BASE]/common/Makefile.stm

Notice that the script currently only support TinySTM usage. Therefore make sure that the parameters in the listed files are properly set. Otherwise, it would be possible to cause unexpected behaviour.

This script is intended to used as multi-thread testing. Therefore the best-use would be limited on it. If there is anything need to change, feel free to contact me.

"


## Parameters
# STAMP_BASE="/home/sylab/PunchShadow/TM/stamp"
# STM_BASE="/home/sylab/PunchShadow/TM/TinySTM"
# RECORDING_DIR="/home/sylab/TonieLai/stamp/recordings"
STAMP_BASE="/home/yuweitt/stm/stm-tracing/stamp-0.9.10"
STM_BASE="/home/yuweitt/stm/stm-tracing/tinySTM"
RECORDING_DIR="/home/yuweitt/stm/stm-tracing/stamp-0.9.10/record"
REBUILD=true
CYCLES=10


#TODO: Currently only support single suffix
declare -a suffices
suffices+=(seq)
# suffices+=(stm)

declare -a stamp_tests
stamp_tests+=(bayes)
stamp_tests+=(genome)
stamp_tests+=(intruder)
stamp_tests+=(kmeans)
# stamp_tests+=(labyrinth)
stamp_tests+=(ssca2)
stamp_tests+=(vacation)
# stamp_tests+=(yada) 

# declare -a THREAD_NUM=("1" "2" "4" "8" "16")

declare -a THREAD_NUM=("4")


declare -A stamp_cmd
stamp_cmd["bayes"]="-v32 -r4096 -n10 -p40 -i2 -e8 -s1 -t" 
stamp_cmd["genome"]="-g16384 -s64 -n16777216 -t"
stamp_cmd["intruder"]="-a10 -l128 -n8152 -s1 -t"
stamp_cmd["kmeans"]="-m40 -n40 -t0.00001 -i ${STAMP_BASE}/kmeans/inputs/random-n65536-d32-c16.txt -p"
stamp_cmd["ssca2"]="-s20 -i1.0 -u1.0 -l3 -p3 -t"
stamp_cmd["yada"]="-a15 -i ${STAMP_BASE}/yada/inputs/ttimeu1000000.2 -t"
stamp_cmd["vacation"]="-n2 -q90 -u98 -r1048576 -t4194304 -t"




## Confirm
if [[ ! -e ${STAMP_BASE}  || ! -e ${STM_BASE}  ]]; then
    echo "Bad Base. Stoping the script."
    exit 0
fi


echo -e "Current STAMP_BASE\t:${STAMP_BASE}"
echo -e "Current STM_BASE\t:${STM_BASE}"
echo -e "Current RECORDING_DIR\t:${RECORDING_DIR}"
echo -e "REBUILD is setting as ${REBUILD}"
echo -e "Running Tests \t :${stamp_tests[@]}"
echo -e "Running Suffices \t :${suffices[@]}"
echo -e "thread_nums \t :${THREAD_NUM[@]}"
echo -e "Cycles \t :${CYCLES}"

echo "[REMARK] Check whether the following parameters met STM_BASE."
cat ${STAMP_BASE}/common/Defines.common.mk | grep ^STM

read -r -p "Continue? [y/N] " resp
case "$resp" in
    [yY][eE][sS]|[yY]) 
        echo "Good."
        ;;
    *)
        echo "Stoping the script."
        exit 0
        ;;
esac

## Re-build 

for bench_test in ${stamp_tests[@]}; do
    if [[ ! -e "${STAMP_BASE}/${bench_test}"  || ${REBUILD} ]] ; then
        cd "${STAMP_BASE}/${bench_test}" &&  \
        make -f Makefile.${suffices[0]} clean && \
        make -f Makefile.${suffices[0]}
    fi
done

# Saving the current status of testing.
LOG_DIR="${RECORDING_DIR}/run_log/$(date '+%Y_%m_%d_%H_%M_%S')"
LOG_FILE="${LOG_DIR}/script_parameters"
mkdir -p ${LOG_DIR}


echo -e "Current STAMP_BASE\t:${STAMP_BASE}"        >> ${LOG_FILE}   
echo -e "Current STM_BASE\t:${STM_BASE}"            >> ${LOG_FILE}   
echo -e "Current RECORDING_DIR\t:${RECORDING_DIR}"  >> ${LOG_FILE}       
echo -e "REBUILD is setting as ${REBUILD}"          >> ${LOG_FILE}   
echo -e "Running Tests \t :${stamp_tests[@]}"       >> ${LOG_FILE}       
echo -e "Running Suffices \t :${suffices[@]}"       >> ${LOG_FILE}       
for i in "${!stamp_cmd[@]}"; do
    echo "${i} | ${stamp_cmd[$i]}" >> ${LOG_FILE} 
done


cat ${STM_BASE}/Makefile  | grep "^DEFINES"  >> ${LOG_FILE}

for ((j=0; j<${CYCLES}; j++)); do
    for nthreads in "${THREAD_NUM[@]}"; do
        mkdir -p ${LOG_DIR}/${bench_test}
        for bench_test in  ${stamp_tests[@]}; do
            echo "${STAMP_BASE}/${bench_test}/${bench_test} ${stamp_cmd[${bench_test}]} ${nthreads}"
           	eval "${STAMP_BASE}/${bench_test}/${bench_test} ${stamp_cmd[${bench_test}]} ${nthreads}"  | grep "ime" |  tee -a  ${LOG_DIR}/${bench_test}.log
		done

        echo -n -e "thread counts=${nthreads}:" | tee -a  ${LOG_DIR}/${bench_test}/rst
        #cat  "${LOG_DIR}/${bench_test}/${nthreads}.log" | awk -F" " '{sum+=$2} END {print sum/NR}' | tee -a  ${LOG_DIR}/${bench_test}/rst
    done
done








