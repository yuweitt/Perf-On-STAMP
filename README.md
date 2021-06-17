# Perf-On-STAMP


## Code Modified  
Replace `stm_internal.h` in `tinySTM/src` (stm_delay entry)  
Replace `thread.*` in `STAMP/lib/` (thread affinity)  


## Perf Probe and Run
### Usage  
Run Under STAMP directory. Make sure to specify file name in command argument.  
ex. `$./perProbeRun.sh CTL_BACKOFF`  
The file name will be like `2021_06_17_CTL_BACKOFF`  
If not specified, the file name will only contain date, and older version will be replaced.  
You will be asked to select **Perf Status[0]** or **Perf Record[1]**  
Perf Status only shows Perf console, Perf Record generates `perftrace` in the `ptrace` directory.

## STAMP 
Written by Tonie Lai  
Run Under STAMP directory.  
A few modified. Make sure to specify file name in command argument.   
ex. `$./stamp.sh ETL_BACKOFF`  
Log file will be generate under `$STAMMP_BASE/recore/run_log` directory
