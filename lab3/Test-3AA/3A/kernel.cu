#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <iostream>
using namespace std;


__global__ void rgba_to_greyscale(const uchar4* const rgbaImage, unsigned char* const greyImage, int numRows, int numCols)
{
	//threadId = threadIdx.x + threadIdx.y * blockDim.x;
}

__global__ void rgba_to_greyscalel(const uchar4* const rgbaImage, unsigned char* const greyImage, int numRows, int numCols)
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

	printf("[%d, %d] %d \n", blockIdx.x, blockIdx.y, i);/*
	if (blockIdx.x * blockDim.x > numCols)
	{
	}
	else if (blockIdx.y * blockDim.y > numRows)
	{
		
	}
	else 
	{
		int threadId = threadIdx.x + threadIdx.y * blockDim.x;
		int qusi_blockId = blockIdx.y * numCols * blockDim.y + blockIdx.x * blockDim.x * blockDim.y;
		int globalId = qusi_blockId + threadId;
		greyImage[globalId] = .299f * rgbaImage[globalId].x + .587f * rgbaImage[globalId].y + .114f * rgbaImage[globalId].z;
	}*/
}

int main()
{
	rgba_to_greyscalel<<<dim3(2,1,1), 1>>>(100);
	cudaDeviceReset();
	scanf("%d", NULL);
    return 0;
}

