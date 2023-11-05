import math
import cv2
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Path and filename settings
def path_set():
	path = "C:/AG/course notes/111_2/IC design/HW5/HW5/file/mosaic/"
	data_name = []
	for i in range(6):
		data_name.append("test"+str(i+1)+".dat")
	return path, data_name

# Hexadecimal to decimal
def H2D(num_str):
	return int(num_str, 16)

# read data(pd) and transfer to np
def read_img(path):
	img_pd = pd.read_csv(path, sep=" ", names=["pixel"])
	img_pd = img_pd.to_numpy()
	img_np = []
	for i in range(img_pd.shape[0]):
		img_np.append(H2D(str(img_pd[i])[2:-2]))
	return np.array(img_np)

# image show
def img_show_gray(img):
	plt.imshow(img,"gray")
	plt.show()

def psnr(img1, img2):
   mse = np.mean( (img1/255. - img2/255.) ** 2 )
   if mse < 1.0e-10:
      return 100
   PIXEL_MAX = 1
   return 20 * math.log10(PIXEL_MAX / math.sqrt(mse))

if __name__=='__main__':
	print(0)