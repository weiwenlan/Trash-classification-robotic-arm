from ftp_utils import *

waitState(3)
recv_ftp('realsense.jpg')
recv_ftp('result.jpg')
recv_ftp('data.txt')
changeState(4)