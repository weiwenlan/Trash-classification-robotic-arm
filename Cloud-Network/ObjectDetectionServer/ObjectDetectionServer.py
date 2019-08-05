from ftp_utils import *
from detect_an_image import *
from prompt_utils import *

RAW_IMG_NAME='realsense.jpg'
OUT_IMG_NAME='result.jpg'
OUT_TXT_NAME='result.txt'
OUT_CNTDATA_NAME='data.txt'

###############################func#################################

def doOnePic():
    try:
        #wait for signal
        prompt('wating for STATE2')
        waitState(2)
        prompt('STATE2 detected')

        #check raw image existence
        if exist_ftp(RAW_IMG_NAME):
            #download raw image
            recv_ftp(RAW_IMG_NAME)
            prompt('raw image received')
        else:
            prompt('raw image does not exist')
        
        #detect objects in raw image
        detect(RAW_IMG_NAME,OUT_IMG_NAME,OUT_TXT_NAME,OUT_CNTDATA_NAME)
        
        #upload result
        send_ftp(OUT_IMG_NAME)
        send_ftp(OUT_TXT_NAME)
        send_ftp(OUT_CNTDATA_NAME)
        prompt('result uploaded')

        #change signal
        changeState(3)
        prompt('change to STATE3')
    except:
        prompt('exception occurred in ObjectDetectionServer.doOnePic')

###############################main#################################

while True:
    doOnePic()

