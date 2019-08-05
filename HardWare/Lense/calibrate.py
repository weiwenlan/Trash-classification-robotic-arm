import cv2, pickle
import numpy as np
import pyrealsense2 as rs
from coordinate_convert import *

coor = None
pipeline = init_color_camera()
try:
    while True:

        frames = pipeline.wait_for_frames()
        color_frame = frames.get_color_frame()
        if not color_frame:
            continue
        color_image = np.asanyarray(color_frame.get_data())
        color_image = cv2.flip(color_image, 0)
        
        cap = detect_cap(color_image)
        coor = get_axis(cap)
        for one_cap in cap:
            color_image = cv2.circle(color_image, (one_cap[0], one_cap[1]), one_cap[2], (0, 255, 0))
        if coor is not None:
            print(coor, end='\r')
        else:
            print('{0} CAP(S) DETECTED                 '.format(len(cap)), end='\r')
    
        # Show images
        cv2.namedWindow('RealSense', cv2.WINDOW_AUTOSIZE)
        cv2.imshow('RealSense', color_image)
        key = cv2.waitKey(100)
        if key == 27:
            break
finally:

    # Stop streaming
    cv2.destroyAllWindows()
    pipeline.stop()

    with open('coordinate.pkl', 'wb') as f:
        pickle.dump(coor, f, pickle.HIGHEST_PROTOCOL)