#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "gputimer.h"
#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
using namespace std;

const int matrixSize = 1024;
const int numberOfColors = 2;

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

__global__ void histogram(unsigned int *a, unsigned int *b)
{
	int globalId = getGlobalIdx_1D_1D();
	atomicAdd(&b[a[globalId]], 1);
}

void test1(int g, int b)
{
	unsigned int *h_a, *d_a;
	unsigned int *h_b, *d_b;
	unsigned int bytes = matrixSize * matrixSize * sizeof(unsigned int);
	unsigned int bytes1 = numberOfColors * sizeof(unsigned int);
	GpuTimer timer;

	h_a = (unsigned int*) malloc(bytes);
	h_b = (unsigned int*) malloc(bytes1);

	cudaMalloc((void **) &d_a, bytes);
	cudaMalloc((void **) &d_b, bytes1);

	// init host arrays
	srand(time(NULL));
	for (int i=0; i<matrixSize; i++) 
	{
		for (int j=0; j<matrixSize; j++)
		{
			h_a[i*matrixSize + j] = rand() % numberOfColors;
		}
	}

	for (int i=0; i<numberOfColors; i++)
	{
		h_b[i] = 0;
	}

	// init gpu arrays
	cudaMemset(d_a, 0, bytes);
	cudaMemset(d_b, 0, bytes);

	// copy to gpu
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes1, cudaMemcpyHostToDevice);


	// kernel call
	timer.Start();
	histogram<<<g, b>>>(d_a, d_b);
	timer.Stop();
	cout << timer.Elapsed() << "\t<<<" << g << ", " << b << ">>> " << "\n";

	// copy to host
	/*cudaMemcpy(h_b, d_b, bytes1, cudaMemcpyDeviceToHost);
	for (int i=0; i<numberOfColors; i++)
	{
		cout << h_b[i] << " ";
	}	
	cout << "\n";*/
}

int main()
{
	test1(1024, 1024);
	scanf("%d", NULL);
	return 0;
}