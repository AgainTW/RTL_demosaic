from hw5_utils import path_set, read_img, img_show_gray
from math import floor
import cv2
import numpy as np
import matplotlib.pyplot as plt

if __name__=='__main__':
	# input test
	path, data_name = path_set()
	img = read_img(path+data_name[0])
	RGB = np.zeros((128*128, 3), np.dtype('uint16'))

	# cycle
	inpt = 0
	for k in range(128*128):
		i = k//128
		j = k%128
		if( (((i%2)==0) and ((j%2)==0)) or (((i%2)==1) and ((j%2)==1)) ):
			RGB[k, 1] = img[k]
		elif( (i%2)==1 ):
			RGB[k, 2] = img[k]
		else:
			RGB[k, 0] = img[k]

	for k in range(128*128):
		i = k//128
		j = k%128
		if( (i==0) and (j==0) ):			# 左上，type_0
			RGB[k, 0] = RGB[128*(i)+(j+1), 0]
			RGB[k, 2] = RGB[128*(i+1)+(j), 2]
		elif( (i==0) and (j==127) ):		# 右上，type_2
			RGB[k, 1] = floor( (RGB[128*(i)+(j-1), 1] + RGB[128*(i+1)+(j), 1]) / 2 )
			RGB[k, 2] = RGB[128*(i+1)+(j-1), 2]
		elif( (i==127) and (j==0) ):		# 左下，type_6
			RGB[k, 0] = RGB[128*(i-1)+(j+1), 0]	
			RGB[k, 1] = floor( (RGB[128*(i-1)+(j), 1] + RGB[128*(i)+(j+1), 1]) / 2 )
		elif( (i==127) and (j==127) ):		# 右下，type_8
			RGB[k, 0] = RGB[128*(i-1)+(j), 0]
			RGB[k, 2] = RGB[128*(i)+(j-1), 2]
		elif( (i==0) and ((j%2)==0) ):		# 上排G，type_1
			RGB[k, 0] = floor( (RGB[128*(i)+(j-1), 0] + RGB[128*(i)+(j+1), 0]) / 2 )
			RGB[k, 2] = RGB[128*(i+1)+(j), 2]
		elif( (i==0) and ((j%2)==1) ):		# 上排R，type_1
			RGB[k, 1] = floor( (RGB[128*(i)+(j-1), 1] + RGB[128*(i)+(j+1), 1] + RGB[128*(i+1)+(j), 1]) / 3 )
			RGB[k, 2] = floor( (RGB[128*(i+1)+(j-1), 2] + RGB[128*(i+1)+(j+1), 2]) / 2 )
		elif( ((i%2)==0) and (j==0) ):		# 左排G，type_3
			RGB[k, 0] = RGB[128*(i)+(j+1), 0]
			RGB[k, 2] = floor( (RGB[128*(i-1)+(j), 2] + RGB[128*(i+1)+(j), 2]) / 2 )
		elif( ((i%2)==1) and (j==0) ):		# 左排B，type_3
			RGB[k, 0] = floor( (RGB[128*(i-1)+(j+1), 0] + RGB[128*(i+1)+(j+1), 0]) / 2 )
			RGB[k, 1] = floor( (RGB[128*(i-1)+(j), 1] + RGB[128*(i+1)+(j), 1] + RGB[128*(i)+(j+1), 1]) / 3 )
		elif( ((i%2)==0) and (j==127) ):	# 右排R，type_5
			RGB[k, 1] = floor( (RGB[128*(i-1)+(j), 1] + RGB[128*(i+1)+(j), 1] + RGB[128*(i)+(j-1), 1]) / 3 )
			RGB[k, 2] = floor( (RGB[128*(i-1)+(j-1), 2] + RGB[128*(i+1)+(j-1), 2]) / 2 )
		elif( ((i%2)==1) and (j==127) ):	# 右排G，type_5
			RGB[k, 0] = floor( (RGB[128*(i-1)+(j), 0] + RGB[128*(i+1)+(j), 0]) / 2 )
			RGB[k, 2] = RGB[128*(i)+(j-1), 2]
		elif( (i==127) and ((j%2)==0) ):	# 下排B，type_7
			RGB[k, 0] = floor( (RGB[128*(i-1)+(j-1), 0] + RGB[128*(i-1)+(j+1), 0]) / 2 )
			RGB[k, 1] = floor( (RGB[128*(i)+(j-1), 1] + RGB[128*(i)+(j+1), 1] + RGB[128*(i-1)+(j), 1]) / 3 )
		elif( (i==127) and ((j%2)==1) ):	# 下排G，type_7
			RGB[k, 0] = RGB[128*(i-1)+(j), 0]
			RGB[k, 2] = floor( (RGB[128*(i)+(j-1), 2] + RGB[128*(i)+(j+1), 2]) / 2 )
		elif( ((i%2)==1) and ((j%2)==0) ):	# 種類b, 中心藍色
			RGB[k, 0] = floor( (RGB[128*(i-1)+(j-1), 0] + RGB[128*(i+1)+(j-1), 0] + RGB[128*(i-1)+(j+1), 0] + RGB[128*(i+1)+(j+1), 0]) / 4 )
			RGB[k, 1] = floor( (RGB[128*(i-1)+(j), 1] + RGB[128*(i+1)+(j), 1] + RGB[128*(i)+(j-1), 1] + RGB[128*(i)+(j+1), 1]) / 4 )			
		elif( ((i%2)==0) and ((j%2)==0) ):	# 種類d, 中心綠色
			RGB[k, 0] = floor( (RGB[128*(i)+(j-1), 0] + RGB[128*(i)+(j+1), 0]) / 2 )
			RGB[k, 2] = floor( (RGB[128*(i-1)+(j), 2] + RGB[128*(i+1)+(j), 2]) / 2 )
		elif( ((i%2)==1) and ((j%2)==1) ):	# 種類a, 中心綠色
			RGB[k, 0] = floor( (RGB[128*(i-1)+(j), 0] + RGB[128*(i+1)+(j), 0]) / 2 )
			RGB[k, 2] = floor( (RGB[128*(i)+(j-1), 2] + RGB[128*(i)+(j+1), 2]) / 2 )
		elif( ((i%2)==0) and ((j%2)==1) ):	# 種類c, 中心紅色
			RGB[k, 1] = floor( (RGB[128*(i-1)+(j), 1] + RGB[128*(i+1)+(j), 1] + RGB[128*(i)+(j-1), 1] + RGB[128*(i)+(j+1), 1]) / 4 )	
			RGB[k, 2] = floor( (RGB[128*(i-1)+(j-1), 2] + RGB[128*(i+1)+(j-1), 2] + RGB[128*(i-1)+(j+1), 2] + RGB[128*(i+1)+(j+1), 2]) / 4 )	

	RGB = RGB.reshape((128,128,3))
	plt.imshow(RGB)
	plt.show()