
# coding: utf-8

# In[1]:


import pynq
import numpy as np
import copy
import math
import cv2
import socket
import threading
import time, warnings
import matplotlib.pyplot as plt
warnings.filterwarnings('ignore')
from pynq.overlays.base import BaseOverlay
from pynq.lib import AxiGPIO
from pynq import Overlay
from pynq.lib.video import *
from pynq import allocate
from time import sleep
from pynq import Clocks
from PIL import Image


# In[2]:


overlay = Overlay("sobel_gpio.bit")


# In[3]:


get_ipython().magic('pinfo overlay')


# In[4]:


hex(overlay.ip_dict["buttons"]["phys_addr"])


# In[5]:


buttons_instance = overlay.ip_dict['buttons']
buttons = AxiGPIO(buttons_instance).channel1

switches_instance = overlay.ip_dict['switches']
switches = AxiGPIO(switches_instance).channel1

led_instance = overlay.ip_dict['leds']
led = AxiGPIO(led_instance).channel1


# In[6]:


buttons.read()


# In[7]:


switches.read()


# In[8]:


led[0:4].write(0x3)
sleep(1)
led[0:4].write(0x7)
sleep(1)
led[0:4].write(0xf)


# In[9]:


led[0:4].off()


# In[10]:


sobel = overlay.sobel_0
dma = overlay.axi_dma_0


# In[11]:


def reset_all_dma():
    def dma_reset(dma):
        dma.sendchannel.stop()
        dma.recvchannel.stop()
        dma.sendchannel.start()
        dma.recvchannel.start()
    dma_reset(dma)
reset_all_dma()


# In[12]:


resolution=(640,480)
padd=int((max(resolution)-min(resolution))/2)
recive_head=0+padd
recive_tail=recive_head+min(resolution)
buffer_shape=max(resolution)


# In[13]:


input_buffer = allocate(shape=(buffer_shape,buffer_shape), dtype=np.uint8)
output_buffer = allocate(shape=(buffer_shape,buffer_shape), dtype=np.uint8)


# In[14]:


def run_sobel():
    reset_all_dma()
    dma.sendchannel.transfer(input_buffer)
    dma.recvchannel.transfer(output_buffer)
    sobel.write(0x10,buffer_shape)
    sobel.write(0x18,buffer_shape)
    sobel.write(0x00,0x81) 
    dma.sendchannel.wait()
    dma.recvchannel.wait()


# In[15]:


frame_in_w, frame_in_h = resolution
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, frame_in_w);
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_in_h);
cap.isOpened()


# In[16]:


frame_out_w,frame_out_h = resolution
Mode = VideoMode(frame_out_w,frame_out_h,8)
hdmi_out = overlay.video.hdmi_out
hdmi_out.configure(Mode,PIXEL_GRAY)
hdmi_out.start()


# # With PL accelerate

# In[17]:


start=time.time()
num_frames=50
readError=0
while (buttons.read()==0):
    fstime=time.time()
    frame, image=cap.read()
    if (frame):
        #image=cv2.GaussianBlur(image,(3,3),0)
        image=cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
        image= cv2.copyMakeBorder(image,padd,padd,0,0,cv2.BORDER_CONSTANT,value=[0,0,0])
        input_buffer[:,:] = image
        run_sobel()
        outframe=hdmi_out.newframe()
        outframe=output_buffer[recive_head:recive_tail,:]
        cv2.putText(outframe,"FPS:"+str(round(1/(time.time()-fstime),4)),(1,20),0,0.8,(255,255,255),1)
        hdmi_out.writeframe(outframe)
        num_frames+=1
    else:
        readError+=1
end=time.time()

print("Break signal...")
print("Frames per second: " + str((num_frames-readError) / (end - start)))
print("Number of read errors: " + str(readError))


# # Using OpenCV (without PL accelerate)

# In[ ]:


frame_out_w,frame_out_h = resolution
Mode = VideoMode(frame_out_w,frame_out_h,24)
hdmi_out = overlay.video.hdmi_out
hdmi_out.configure(Mode,PIXEL_BGR)
hdmi_out.start()

start=time.time()
num_frames=0
readError=0
while (overlay.buttons[3].read()==0):
    fstime=time.time()
    ret, frame_vga = cap.read()
    if (ret):
        outframe = hdmi_out.newframe()
        laplacian_frame = cv2.Laplacian(frame_vga, cv2.CV_8U,ksize=3, dst=outframe)
        cv2.putText(outframe,"FPS:"+str(round(1/(time.time()-fstime),4)),(10,20),0,0.8,(255,255,255),1)
        hdmi_out.writeframe(outframe)
        num_frames+=1
    else:
        readError += 1
end = time.time()
#hdmi_out.close()
print("Break signal...")
print("Frames per second: " + str((num_frames-readError) / (end - start)))
print("Number of read errors: " + str(readError))


