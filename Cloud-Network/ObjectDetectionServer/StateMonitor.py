from ftp_utils import *
from prompt_utils import *

def outputState(state):
    if state==0:
        info = 'Begin'
    elif state==1:
        info = 'Picture Requested'
    elif state==2:
        info = 'Picture Taken'
    elif state==3:
        info = 'Object Detection'
    elif state==4:
        info = 'Picture Shown'
    elif state==5:
        info = 'Arm Moved'
    
    prompt('STATE ' + str(state) + ' ' + info)

while True:
    try:
        currentState = int(checkState())
        outputState(currentState)
        nextState = (currentState+1)%5
        waitState(nextState)
    except:
        prompt('exception occurred in StateMonitor.py','RED')

