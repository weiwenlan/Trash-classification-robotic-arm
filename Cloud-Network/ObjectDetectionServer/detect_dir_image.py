#tensorflow模型中object_detection目录
OBJECT_DETECTION_DIR = '/Users/coconutnut/.pyenv/versions/3.5.7/lib/python3.5/site-packages/tensorflow/models/research/object_detection'
#之前训练的模型
MODEL_NAME = '/Users/coconutnut/TREE/Midgard/GarbageClassification/model'
#标签目录
PATH_TO_LABELS = '/Users/coconutnut/TREE/Midgard/GarbageClassification/annotations/label_map.pbtxt'
#标签类别数
NUM_CLASSES = 6
#服务器存储文件路径
SERVER_PATH = '/Users/coconutnut/TREE/Midgard/GarbageClassification'
#输出文件目录
OUTPUT_PATH = '/Users/coconutnut/TREE/Midgard/GarbageClassification'
#测试图片目录
PATH_TO_TEST_IMAGES_DIR = '/Users/coconutnut/TREE/Midgard/GarbageClassification/testimg'
#输出score阈值
THRESHOLD = 0.3

import time
import numpy as np
import os
import six.moves.urllib as urllib
import sys
import tarfile
import tensorflow as tf
import zipfile
import cv2

from collections import defaultdict
from io import StringIO
from matplotlib import pyplot as plt
from PIL import Image
from prompt_utils import *

#Object detection imports
from object_detection.utils import label_map_util
from object_detection.utils import visualization_utils as vis_util

start = time.time()
#对应的Frozen model位置
# Path to frozen detection graph. This is the actual model that is used for the object detection.
PATH_TO_CKPT = MODEL_NAME + '/frozen_inference_graph.pb'

#Load a (frozen) Tensorflow model into memory.
detection_graph = tf.Graph()
with detection_graph.as_default():
    od_graph_def = tf.GraphDef()
    with tf.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
        serialized_graph = fid.read()
        od_graph_def.ParseFromString(serialized_graph)
        tf.import_graph_def(od_graph_def, name='')

#Loading label map
label_map = label_map_util.load_labelmap(PATH_TO_LABELS)
categories = label_map_util.convert_label_map_to_categories(label_map, max_num_classes=NUM_CLASSES, use_display_name=True)
category_index = label_map_util.create_category_index(categories)

#Helper code
def load_image_into_numpy_array(image):
    (im_width, im_height) = image.size
    return np.array(image.getdata()).reshape((im_height, im_width, 3)).astype(np.uint8)

os.chdir(SERVER_PATH)

# Size, in inches, of the output images.
IMAGE_SIZE = (12, 8)

os.chdir(PATH_TO_TEST_IMAGES_DIR)
TEST_IMAGE_PATHS = os.listdir(PATH_TO_TEST_IMAGES_DIR)

with detection_graph.as_default():
    with tf.Session(graph=detection_graph) as sess:
        # Definite input and output Tensors for detection_graph
        image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
        # Each box represents a part of the image where a particular object was detected.
        detection_boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
        # Each score represent how level of confidence for each of the objects.
        # Score is shown on the result image, together with the class label.
        detection_scores = detection_graph.get_tensor_by_name('detection_scores:0')
        detection_classes = detection_graph.get_tensor_by_name('detection_classes:0')
        num_detections = detection_graph.get_tensor_by_name('num_detections:0')
        
        for image_path in TEST_IMAGE_PATHS:
            prompt('image_path:'+image_path,'BLUE')
            
            if image_path[0]=='.':
                prompt('pass')
            
            image = cv2.imread(image_path, 1)
            width, height = Image.fromarray(cv2.cvtColor(image,cv2.COLOR_BGR2RGB)).size
            
            # Expand dimensions since the model expects images to have shape: [1, None, None, 3]
            image_np_expanded = np.expand_dims(image, axis=0)
            # Actual detection.
            (boxes, scores, classes, num) = sess.run(
                [detection_boxes, detection_scores,detection_classes, num_detections],
                feed_dict={image_tensor: image_np_expanded})
        
            #选取分数高于阈值的块
            s_boxes = boxes[scores > THRESHOLD]
            s_scores = scores[scores > THRESHOLD]
            s_classes = classes[scores > THRESHOLD]
            
            prompt('s_classes:'+str(s_classes),'BLUE')
            prompt('s_scores:'+str(s_scores),'BLUE')
            prompt('s_boxes:'+str(s_boxes),'BLUE')
            
            # Visualization of the results of a detection.
            vis_util.visualize_boxes_and_labels_on_image_array(
                image,
                np.squeeze(s_boxes),
                np.squeeze(s_classes).astype(np.int32),
                np.squeeze(s_scores),
                category_index,
                use_normalized_coordinates=True,
                line_thickness=8)
            
            #保存识别结果图片
            cv2.imwrite(image_path.split('.')[0]+'_out_'+str(THRESHOLD)+'.jpg',image)

        num = len(s_scores)
        
        # 结果保存到字符串
        lenstr=""
        for i in range(num):
            lenstr = str(s_boxes[i][0]*height) + '|' + str(s_boxes[i][1]*width) + '|' + str(s_boxes[i][2]*height) + '|' + str(s_boxes[i][3]*width) + '|' + str(s_scores[i]) + '|' + str(s_classes[i]) + '|'


        prompt('lenstr:'+str(lenstr),'BLUE')

end =  time.time()
prompt("Execution Time: ", end - start)

