#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
using namespace std;

const int arraySize = 1024;

__device__ int getGlobalIdx_2D_2D()
{
	int blockId = blockIdx.x + blockIdx.y * gridDim.x;
	int threadId = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;
	return threadId;
}

__device__ int getGlobalIdx_1D_1D() 
{
	return blockIdx.x *blockDim.x + threadIdx.x;
}

__global__ void find_max(int *a, int *b)
{
	int globalId = getGlobalIdx_2D_2D();
	atomicMax(b, a[globalId]);
}



void test1(int g, int b)
{
	int *h_a, *h_b;
	int *d_a, *d_b;
	int bytes = arraySize * sizeof(int);
	GpuTimer timer;

	h_a = (int*) malloc(bytes);
	h_b = (int*) malloc(sizeof(int));

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, sizeof(int));

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i;
	}
	h_b[0] = 0;

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, sizeof(int));

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, sizeof(int), cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	find_max<<<g, b>>>(d_a, d_b);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	cudaMemcpy(h_b, d_b, sizeof(int), cudaMemcpyDeviceToHost);
	for (int i=0; i<1; i++)
	{
		cout << h_b[i] << " ";
	}	
	cout << "\n";
}

int main()
{
	test1(1, 1024);
	test1(2, 512);
	test1(4, 256);
	test1(8, 128);
	test1(512, 2);
	scanf("%d", NULL);
	return 0;
}
