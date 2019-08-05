import math, cv2, time
import numpy as np
import pyrealsense2 as rs

def detect_cap(frame):

    return_list = []

    # Define the upper and lower boundaries for a color to be considered "Blue"
    blueLower = np.array([100,150,0])
    blueUpper = np.array([140,255,255])

    # Define a 5x5 kernel for erosion and dilation
    kernel = np.ones((5, 5), np.uint8)

    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

    # Determine which pixels fall within the blue boundaries and then blur the binary image
    blueMask = cv2.inRange(hsv, blueLower, blueUpper)
    blueMask = cv2.erode(blueMask, kernel, iterations=2)
    blueMask = cv2.morphologyEx(blueMask, cv2.MORPH_OPEN, kernel)
    blueMask = cv2.dilate(blueMask, kernel, iterations=1)

    # Find contours (bottle cap in my case) in the image
    cnts, _ = cv2.findContours(blueMask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Check to see if any contours were found
    if len(cnts) > 0:
        # Sort the contours and find the largest one -- we
        # will assume this contour correspondes to the area of the bottle cap
        cnts = sorted(cnts, key = cv2.contourArea, reverse = True)
        for cnt in cnts:
            # Get the radius of the enclosing circle around the found contour
            ((x, y), radius) = cv2.minEnclosingCircle(cnt)
            # Draw the circle around the contour
            return_list.append((int(x), int(y), int(radius)))

    return return_list

def init_color_camera():
    # Configure color streams
    pipeline = rs.pipeline()
    config = rs.config()
    config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)

    # Start streaming
    pipeline.start(config)
    time.sleep(2)
    return pipeline

def take_picture(pipeline, filename):
    frames = pipeline.wait_for_frames()
    color_frame = frames.get_color_frame()
    color_image = np.asanyarray(color_frame.get_data())
    
    color_image = cv2.flip(color_image, 0)
    cv2.imwrite(filename, color_image)

def distance(c1, c2):
    return math.sqrt((c1[0] - c2[0])**2 + (c1[1] - c2[1])**2)

def area(a, b, c):
    p = (a + b + c) / 2
    S = (p * (p - a)*(p - b)*(p - c))** 0.5
    return  S

def get_axis(circles):
    if len(circles) != 3:
        return None
    
    coor = dict()
    distances = []
    
    for i in range(2):
        for j in range(i+1, 3):
            distances.append(distance(circles[i], circles[j]))
    
    for i in range(3):
        if max(distances) == distances[i]:
            coor['o'] = circles[2 - i]
            circles.remove(circles[2 - i])

    if circles[0] > circles[1]:
        coor['x'] = circles[1]
        coor['y'] = circles[0]
    else:
        coor['x'] = circles[0]
        coor['y'] = circles[1]
    
    return coor

def convert_coor(coor, current):
    dist = math.fabs(coor['o'][0] - coor['x'][0]) / 10
    x = 2 * area(distance(coor['o'], coor['y']), 
            distance(current, coor['o']),
            distance(current, coor['y'])) / distance(coor['o'], coor['y'])
    y = 2 * area(distance(coor['o'], coor['x']), 
            distance(current, coor['o']),
            distance(current, coor['x'])) / distance(coor['o'], coor['x'])
    vector_c = (current[0] - coor['o'][0], current[1] - coor['o'][1])
    vector_x = (coor['x'][0] - coor['o'][0], coor['x'][1] - coor['o'][1])
    vector_result = vector_c[0] * vector_x[0] + vector_c[1] * vector_x[1]
    if vector_result < 0:
        x *= -1
    return (x/dist, y/dist)