# Perf-On-STAMP


## Code Modified  
Replace `stm_internal.h` in `tinySTM/src` (stm_delay entry)  
Replace `thread.*` in `STAMP/lib/` (thread affinity)  


## Perf Probe and Run
### Usage  
Run Under STAMP directory  
`$./perProbeRun.sh`  
You will be asked to select **Perf Status[0]** or **Perf Record[1]**  
Perf Status will show Perf console, Perf Record will generate `perftrace` in the `ptrace` directory.

## STAMP 
Written by Tonie Lai  
Run Under STAMP directory  
`$./stamp.sh`  
Log file will be generate under `$STAMMP_BASE/recore/run_log` directory
