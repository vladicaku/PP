#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include <stdio.h>
#include <stdlib.h> 
#include <iostream>
using namespace std;

const int arraySize = 2048;

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

__global__ void vector_add_global(float *a, float *b, float *c)
{
    int globalId = getGlobalIdx_1D_1D();
    c[globalId] = a[globalId] + b[globalId];
}

__global__ void vector_add_shared(float *a, float *b, float *c)
{
	extern __shared__ float sum[];
    int globalId = getGlobalIdx_1D_1D();
	int inBlockId = threadIdx.x + threadIdx.y * blockDim.x;
	
	sum[inBlockId] = a[globalId];
	sum[inBlockId] += b[globalId];
    c[globalId] = sum[inBlockId];
}

int main()
{
	float *h_a, *h_b, *h_c;	
	float *d_a, *d_b, *d_c;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);
	h_c = (float*) malloc(bytes);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);
	cudaMalloc((void **) &d_c, bytes);

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
			h_a[i] = i;
			h_b[i] = i;
			h_c[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);
	cudaMemset(d_c, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);
	
	
	// kernel call
	timer.Start();
	//vector_add_global<<<8, 256>>>(d_a, d_b, d_c);
	vector_add_shared<<<2, 1024, 1024*sizeof(float)>>>(d_a, d_b, d_c);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	vector_add_shared<<<4, 512, 512*sizeof(float)>>>(d_a, d_b, d_c);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	timer.Start();
	vector_add_shared<<<8, 256, 256*sizeof(float)>>>(d_a, d_b, d_c);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	// copy to host
	cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_c[i];
	}


	scanf("%d", NULL);
    return 0;
}

