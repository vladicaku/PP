#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
using namespace std;

__device__ int getGlobalIdx_2D_2D()
{
	int blockId = blockIdx.x + blockIdx.y * gridDim.x;
	int threadId = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;
	return threadId;
}

__device__ int getGlobalIdx_1D_1D() 
{
	return blockIdx.x * blockDim.x + threadIdx.x;
}

__global__ void dot_product(float *a, float *b, float *total, int N)
{
	extern __shared__  float temp[];
	int threadId = getGlobalIdx_1D_1D();

	if (threadId < N) 
	{
		temp[threadIdx.x] = a[threadId] * b[threadId];
	}

	__syncthreads();

	// reduction
	int i  = blockDim.x / 2 ;
	while (i != 0)
	{
		if (threadIdx.x < i)
		{
			temp[threadIdx.x] += temp[threadIdx.x + i];
		}
		__syncthreads();
		i /= 2;
	}

	//__syncthreads();
	

	// atomic add sum from each block
	if (threadIdx.x == 0)
	{
		atomicAdd(total, temp[threadIdx.x]);
	}
}

void test(int g, int b, int kernel, int arraySize, bool showOutput)
{
	float *h_a, *h_b, *h_total;
	float *d_a, *d_b, *d_total;
	int bytes = arraySize * sizeof(float);
	GpuTimer timer;

	h_a = (float*) malloc(bytes);
	h_b = (float*) malloc(bytes);
	h_total = (float*) malloc(sizeof(float));

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes);
	cudaMalloc((void **) &d_total, sizeof(float));

	// init host arrays
	for (int i=0; i<arraySize; i++) 
	{
		h_a[i] = i+1;
		h_b[i] = i+1;
	}
	h_total[0] = 0;

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);
	cudaMemset(d_total, 0, sizeof(float));

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_total, h_total, sizeof(float), cudaMemcpyHostToDevice);

	// kernel call
	if (kernel == 0)
	{
		timer.Start();
		dot_product<<<g, b, b*sizeof(float)>>>(d_a, d_b, d_total, arraySize);
		timer.Stop();
	}
	
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	cudaMemcpy(h_total, d_total, sizeof(float), cudaMemcpyDeviceToHost);

	// show output
	if (showOutput) 
	{
		cout << h_total[0] << "\n";
	}

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_total);
}


int main()
{
	// g, b, kernel, arraySize, showOutput
	cout << "Array size 2048" << "\n" << "\n";
	test(2, 1024, 0, 2048, true); 
	cout << "\n";
	test(4, 512, 0, 2048, true); 
	cout << "\n";
	test(8, 256, 0, 2048, true); 
	cout << "\n";
	test(16, 128, 0, 2048, true); 
	cout << "\n";
	test(32, 64, 0, 2048, true); 
	cout << "\n";

	cout << "\n";
	cout << "\n";
	cout << "Array size 16384" << "\n" << "\n";
	test(16, 1024, 0, 16384, true); 
	cout << "\n";
	test(32, 512, 0, 16384, true); 
	cout << "\n";
	test(64, 256, 0, 16384, true); 
	cout << "\n";
	test(128, 128, 0, 16384, true); 
	cout << "\n";

	scanf("%d", NULL);
    return 0;
}

