import glob, os
import re
import sys
import numpy as np
import matplotlib.pyplot as plt

application = ['genome', 'intruder', 'kmeans', 'ssca2', 'vacation', 'labyrinth', 'bayes', 'yada']
Time = []
color = ['lightcoral', 'yellowgreen', 'lightgreen', 'c' ]

# sub directory
os.chdir(sys.argv[1])
subdirs = [x[0] for x in os.walk('.')]
subdirs.pop(0)
subdirs.sort()
test_num = len(application)

# Calculate Average Execution of each stamp test
def genAverage(FileName, ssca):
    iteration = 10
    with open(FileName, 'r+') as fh:
        sum = 0
        for line in fh:
            if(ssca):
                if("all" not in line):
                    continue
            n = re.findall("\d+\.+\d+", line)[-1]
            
            sum += float(n)
        average = sum / iteration
        Time.append(average)
        outFile.write("Average : "+ str(average))
        outFile.write("\n")

# Plot chart
def plot():
    tab = 0.25
    x = np.arange(len(application))
    width = 0.2
    for i, dirs in enumerate(subdirs):
        plt.bar(x + i*width, Time[i*test_num : (i+1)*test_num], width, color=color[i], label=pow(2, i))
        for index, value in enumerate(Time[i*test_num : (i+1)*test_num]):
            plt.text(index-tab+i*tab,value, str(float("{:.2f}".format(value))), color='black', fontweight='bold')
    plt.xticks(x + width / 2, application)
    plt.ylabel('Timming')
    plt.legend(bbox_to_anchor=(1,1), loc='upper left')
    plt.show()



# Walks through directorys
for dirs in subdirs:
    outFile = open(dirs + "/summary.txt", "w")
    for file in glob.glob(dirs + "/*.log"):
        outFile.write("--------------------------------\n")
        outFile.write(file)
        outFile.write("\n")
        if("ssca" in file):
            genAverage(file, 1)
        else:
            genAverage(file, 0)
print(Time)
plot()
