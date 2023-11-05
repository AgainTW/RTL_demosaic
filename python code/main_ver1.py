from hw5_utils import path_set, read_img, img_show_gray
from math import floor
import cv2
import numpy as np
import matplotlib.pyplot as plt

if __name__=='__main__':
	# input test
	path, data_name = path_set()
	img = read_img(path+data_name[0])
	img = img.reshape((128,128))

	# 
	RGB = np.zeros((128, 128, 3), np.dtype('uint16'))

	# 
	for i in range(128):
		for j in range(128):
			if( ((i%2)==0) and ((j%2)==0) or ((i%2)==1) and ((j%2)==1) ):
				RGB[i, j, 1] = img[i, j]
			elif( (i%2)==1 ):
				RGB[i, j, 2] = img[i, j]
			else:
				RGB[i, j, 0] = img[i, j]

	# Bilinear Interpolation
	count = 0
	for i in range(128):
		for j in range(128):
			if( (i==0) and (j==0) ):			# 左上
				RGB[i, j, 0] = RGB[i, j+1, 0]
				RGB[i, j, 2] = RGB[i+1, j, 2]

				count = count+1
			elif( (i==0) and (j==127) ):		# 右上
				RGB[i, j, 1] = floor( (RGB[i, j-1, 1] + RGB[i+1, j, 1]) / 2 )
				RGB[i, j, 2] = RGB[i+1, j-1, 2]

				count = count+1
			elif( (i==127) and (j==0) ):		# 左下
				RGB[i, j, 0] = RGB[i-1, j+1, 0]	
				RGB[i, j, 1] = floor( (RGB[i-1, j, 1] + RGB[i, j+1, 1]) / 2 )

				count = count+1
			elif( (i==127) and (j==127) ):		# 右下
				RGB[i, j, 0] = RGB[i-1, j, 0]
				RGB[i, j, 2] = RGB[i, j-1, 2]

				count = count+1
			elif( (i==0) and ((j%2)==0) ):		# 上排G
				RGB[i, j, 0] = floor( (RGB[i, j-1, 0] + RGB[i, j+1, 0]) / 2 )
				RGB[i, j, 2] = RGB[i+1, j, 2]

				count = count+1
			elif( (i==0) and ((j%2)==1) ):		# 上排R
				RGB[i, j, 1] = floor( (RGB[i, j-1, 1] + RGB[i, j+1, 1] + RGB[i+1, j, 1]) / 3 )
				RGB[i, j, 2] = floor( (RGB[i+1, j-1, 2] + RGB[i+1, j+1, 2]) / 2 )

				count = count+1
			elif( ((i%2)==0) and (j==0) ):		# 左排G
				RGB[i, j, 0] = RGB[i, j+1, 0]
				RGB[i, j, 2] = floor( (RGB[i-1, j, 2] + RGB[i+1, j, 2]) / 2 )

				count = count+1
			elif( ((i%2)==1) and (j==0) ):		# 左排B
				RGB[i, j, 0] = floor( (RGB[i-1, j+1, 0] + RGB[i+1, j+1, 0]) / 2 )
				RGB[i, j, 1] = floor( (RGB[i-1, j, 1] + RGB[i+1, j, 1] + RGB[i, j+1, 1]) / 3 )

				count = count+1
			elif( ((i%2)==0) and (j==127) ):	# 右排R
				RGB[i, j, 1] = floor( (RGB[i-1, j, 1] + RGB[i+1, j, 1] + RGB[i, j-1, 1]) / 3 )
				RGB[i, j, 2] = floor( (RGB[i-1, j-1, 2] + RGB[i+1, j-1, 2]) / 2 )

				count = count+1
			elif( ((i%2)==1) and (j==127) ):	# 右排G
				RGB[i, j, 0] = floor( (RGB[i-1, j, 0] + RGB[i+1, j, 0]) / 2 )
				RGB[i, j, 2] = RGB[i, j-1, 2]

				count = count+1
			elif( (i==127) and ((j%2)==0) ):	# 下排B
				RGB[i, j, 0] = floor( (RGB[i-1, j-1, 0] + RGB[i-1, j+1, 0]) / 2 )
				RGB[i, j, 1] = floor( (RGB[i, j-1, 1] + RGB[i, j+1, 1] + RGB[i-1, j, 1]) / 3 )

				count = count+1
			elif( (i==127) and ((j%2)==1) ):	# 下排G
				RGB[i, j, 0] = RGB[i-1, j, 0]
				RGB[i, j, 2] = floor( (RGB[i, j-1, 2] + RGB[i, j+1, 2]) / 2 )

				count = count+1
			elif( ((i%2)==0) and ((j%2)==0) ):	# 種類d, 中心綠色
				RGB[i, j, 0] = floor( (RGB[i, j-1, 0] + RGB[i, j+1, 0]) / 2 )
				RGB[i, j, 2] = floor( (RGB[i-1, j, 2] + RGB[i+1, j, 2]) / 2 )

				count = count+1
			elif( ((i%2)==1) and ((j%2)==1) ):	# 種類a, 中心綠色
				RGB[i, j, 0] = floor( (RGB[i-1, j, 0] + RGB[i+1, j, 0]) / 2 )
				RGB[i, j, 2] = floor( (RGB[i, j-1, 2] + RGB[i, j+1, 2]) / 2 )

				count = count+1
			elif( ((i%2)==1) and ((j%2)==0) ):	# 種類b, 中心藍色
				RGB[i, j, 0] = floor( (RGB[i-1, j-1, 0] + RGB[i+1, j-1, 0] + RGB[i-1, j+1, 0] + RGB[i+1, j+1, 0]) / 4 )
				RGB[i, j, 1] = floor( (RGB[i-1, j, 1] + RGB[i+1, j, 1] + RGB[i, j-1, 1] + RGB[i, j+1, 1]) / 4 )

				count = count+1
			elif( ((i%2)==0) and ((j%2)==1) ):	# 種類c, 中心紅色
				RGB[i, j, 1] = floor( (RGB[i-1, j, 1] + RGB[i+1, j, 1] + RGB[i, j-1, 1] + RGB[i, j+1, 1]) / 4 )	
				RGB[i, j, 2] = floor( (RGB[i-1, j-1, 2] + RGB[i+1, j-1, 2] + RGB[i-1, j+1, 2] + RGB[i+1, j+1, 2]) / 4 )	

				count = count+1
				
	print(count)

	plt.imshow(RGB)
	plt.show()