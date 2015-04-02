#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <iostream>
#include <gputimer.h>
using namespace std;

const int arraySize = 1024;

__device__ int getGlobalIdx_3D_3D(){
	int blockId = blockIdx.x + blockIdx.y * gridDim.x
		+ gridDim.x * gridDim.y * blockIdx.z;
	int threadId = blockId * (blockDim.x * blockDim.y * blockDim.z)
		+ (threadIdx.z * (blockDim.x * blockDim.y))
		+ (threadIdx.y * blockDim.x) + threadIdx.x;
	return threadId;
}

__global__ void matrix_add(float *a, float *b, float *c)
{
	int globalId = getGlobalIdx_3D_3D();
	c[globalId] = a[globalId] + b[globalId];
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
	matrix_add<<<1, 1024>>>(d_a, d_b, d_c);
	timer.Stop();
	cout << timer.Elapsed() << "\n";

	// copy to host
	/*cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);
	for (int i=0; i<arraySize; i++)
	{
		cout << " " << h_c[i];
	}*/


	scanf("%d", NULL);
	return 0;
	return 0;
}

