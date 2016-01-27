#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h> 
#include <iostream>
using namespace std;

const int arraySize = 100;

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

__global__ void increment_counter(float *a, int len)
{
	int globalId = getGlobalIdx_2D_2D();
	int id = globalId % len;
	atomicAdd(&a[id], 1);
}

void test1(int g, int b)
{
	float *h_a;
	float *d_a;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	increment_counter<<<g, b>>>(d_a, arraySize);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	/*cudaMemcpy(h_a, d_a, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << h_a[i] << " ";
	}	
	cout << "\n";*/
}

int main()
{
	test1(1, 1024);
	test1(64, 1024);
	test1(512, 1024);
	test1(1024, 1024);
	scanf("%d", NULL);
	return 0;
}