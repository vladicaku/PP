#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void rgba_to_greyscale_strided(const uchar4* const rgbaImage, unsigned char* const greyImage, int numRows, int numCols)
{
	int abs_x = blockIdx.x * blockDim.x + threadIdx.x;
	int abs_y = blockIdx.y * blockDim.y + threadIdx.y;
	int globalId;

	if (abs_x <= numCols && abs_y <= numRows)
	{
		globalId = abs_x + abs_y * numCols;
		greyImage[globalId] = .299f * rgbaImage[globalId].x + .587f * rgbaImage[globalId].y + .114f * rgbaImage[globalId].z;
		//rgba_to_greyscale(rgbaImage, greyImage, numRows, numCols);
	}
}
// 0.033376 ms 


__device__ int getGlobalIdx_2D_2D() 
{
		int blockId = blockIdx.x + blockIdx.y * gridDim.x;
		int threadId = blockId * (blockDim.x * blockDim.y)
			+ (threadIdx.y * blockDim.x) + threadIdx.x;
		return threadId;
}


__global__ void rgba_to_greyscale_naive_coalesced(const uchar4* const rgbaImage, unsigned char* const greyImage, int len)
{
	int globalId = getGlobalIdx_2D_2D();

	if (globalId < len) {
		greyImage[globalId] = .299f * rgbaImage[globalId].x + .587f * rgbaImage[globalId].y + .114f * rgbaImage[globalId].z;
	}
}
/*
0.029856 ms 
const dim3 blockSize(20, 20, 1);  //TODO
const dim3 gridSize(numCols/20 + 1, numRows/20 + 1, 1);  //TODO
*/

__global__ void rgba_to_greyscale_noif_coalesced(const uchar4* const rgbaImage, unsigned char* const greyImage)
{
	int globalId = getGlobalIdx_2D_2D();
	greyImage[globalId] = .299f * rgbaImage[globalId].x + .587f * rgbaImage[globalId].y + .114f * rgbaImage[globalId].z;
}

int main()
{
	return 0;
}

