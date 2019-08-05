import sys
import time

def prompt(outputstr,color='GREEN'):
    if color=='RED':
        colorstr='\033[31m'
    elif color=='YELLOW':
        colorstr='\033[33m'
    elif color=='BLUE':
        colorstr='\033[34m'
    elif color=='GREEN':
        colorstr='\033[32m'
    prompt_sentence(colorstr+outputstr+'\033[0m')

def prompt_sentence(outputstr):
    localtime = time.strftime("%H:%M:%S", time.localtime())
#    print(str(localtime) + '|' + str(sys._getframe().f_code.co_filename).split('/')[-1] + '|line' + str(sys._getframe().f_lineno) + '|' + outputstr)
    print(str(localtime) + '|' + outputstr)
