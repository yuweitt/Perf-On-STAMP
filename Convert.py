import glob, os
import re
import sys

os.chdir(sys.argv[1])

for file in glob.glob("*trace"):
    print(file)
    outName = file + ".log"
    outF = open(outName, "w")
    exist_dic = {}
    time_dic = {}
    tid_state = {}
    with open(file) as f:
        for line in f:
            
            # Parse
            string = line.split()
            tid, time, event = string
            time = time.replace(":", "")
            time = time.replace(".", "")
            
            # Commit to return or to rollback
            if ("start" in event):
                tid_state[tid] = 0
                time_dic[tid] = time
            elif ("commit" in event and tid_state[tid] == 0 ):
                tid_state[tid] = 1
            elif ("commit_return" in event and tid_state[tid] == 1 ):
                tid_state[tid] = 2
            elif ("rollback" in event and tid_state[tid] == 1):
                tid_state[tid] = 3
            
            # rollback to delay
            elif ("rollback" in event and tid_state[tid] == 0):
                tid_state[tid] = 3
            elif ("delay" in event and tid_state[tid] == 3):
                tid_state[tid] = 4

            elif ("delay_return" in event and tid_state[tid] == 4):
                tid_state[tid] = 5

            # delay to rollback or commit
            elif ("rollback" in event and tid_state[tid] == 5):
                tid_state[tid] = 3
                time_dic[tid] = time
            elif ("commit" in event and tid_state[tid] == 5):
                tid_state[tid] = 1
                time_dic[tid] = time
            else:
                state = -1

            # Write
            sep = ","
            if (tid in exist_dic):
                # start to delay entry
                if(tid_state[tid] == 4):
                    outF.write(tid + sep + time_dic[tid] + sep + time + sep + str(0) + "\n")
                    time_dic[tid] = time
                # delay entry to delay return
                elif (tid_state[tid] == 5 ):
                    outF.write(tid + sep + time_dic[tid] + sep + time + sep + str(1) + "\n")
                # commit return
                elif (tid_state[tid] == 2):
                    outF.write(tid + sep + time_dic[tid] + sep + time + sep + str(2) + "\n")
                else:
                    state = -1
            else:
                exist_dic[tid] = True
                time_dic[tid] = time

    print(exist_dic)
    print(time_dic)

    outF.close()
