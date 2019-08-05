import socket
import time
import cv2
import os
import pyrealsense2 as rs
import numpy as np

def increase_brightness(img, value):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)
    if value > 0:
        lim = 255 - value
        v[v > lim] = 255
        v[v <= lim] += value
    else:
        v[v + value < 0] = 0
        v[v != 0] -= value*-1
    final_hsv = cv2.merge((h, s, v))
    img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return img

def take_picture(pipeline, filename):
    try:
        time.sleep(3)
        frames = pipeline.wait_for_frames()
        color_frame = frames.get_color_frame()
        color_image = np.asanyarray(color_frame.get_data())
        
        color_image = increase_brightness(color_image, 30)
        color_image = cv2.flip(color_image, 0)
        cv2.imwrite(filename, color_image)
    except:
        # Stop streaming
        pipeline.stop()
        
def send_image(file, tcp_socket, debug = False):

    file_size = os.stat(file).st_size  
    file_info = '%s|%s|'%(file,file_size)
    if debug:
        print(file_info)
    tcp_socket.sendall(file_info.encode('utf-8'))   #第一次发送请求，不是具体内容，而是先发送数据信息  

    f = open(file,'rb')
    has_sent = 0
    while has_sent != file_size:
        data = f.read(1)  
        tcp_socket.sendall(data)                    #发送真实数据  
        has_sent += len(data)  

    tcp_socket.shutdown(socket.SHUT_WR)
    f.close()
    if debug:
        print('sended')